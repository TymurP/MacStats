//
//  MachineDefaults.m
//  MacStats
//
//  Created by Tymur Pysarevych on 24.11.20.
//

#import <Foundation/Foundation.h>
#import "MachineDefaults.h"
#import "DirectoryLocations.h"

@implementation MachineDefaults

- (instancetype)init:(NSString*)p_machine{
    if (self = [super init]){
        machine=[MachineDefaults computerModel];
        [self refreshPlist];
    }
    return self;
}

- (void) refreshPlist {
    supported_machines=[[NSArray alloc] initWithContentsOfFile:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Machines.plist"]];
    supported=NO;
    int i;
    for(i=0;i<[supported_machines count];i++) {
        if ([machine isEqualToString:supported_machines[i][@"Machine"]]) {
            supported=YES;
            machine_num=i;
        }
    }
}

- (NSDictionary*) readFromPlist{
    if (!supported) {return nil;}
    return supported_machines[machine_num];
}

- (void) readFromSMC {
    NSUInteger num_fans=[smcWrapper getFanNum];
    NSString  *desc;
    NSNumber *min,*max;
    NSData *xmldata;
    NSString *error;
    NSMutableArray *fans=[[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < num_fans; i++) {
        min=@([smcWrapper getMinSpeed:i]);
        max=@([smcWrapper getMaxSpeed:i]);
        desc=[smcWrapper getFanDescr:i];
        [fans addObject:[[NSMutableDictionary alloc] initWithDictionary:@{@"Description": desc,@"Minspeed": min,@"Maxspeed": max,@"selspeed": min}]];
    }
    //save to plist for future
    NSMutableArray *supported_m=[[NSMutableArray alloc] initWithContentsOfFile:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Machines.plist"]];
    NSMutableDictionary *new_machine;
    if (fans == nil) {
        new_machine= [[NSMutableDictionary alloc] initWithDictionary:@{@"Fans": [NSNull null],@"NumFans": @(0),@"Machine": machine,@"Comment": @"Autogenerated",@"Minspeed": min,@"Maxspeed": max}];
    } else {
        new_machine= [[NSMutableDictionary alloc] initWithDictionary:@{@"Fans": fans,@"NumFans": @(num_fans),@"Machine": machine,@"Comment": @"Autogenerated",@"Minspeed": min,@"Maxspeed": max}];
    }
    [supported_m addObject:new_machine];
    
    //save to plist
    xmldata = [NSPropertyListSerialization dataFromPropertyList:supported_m
                                                         format:NSPropertyListXMLFormat_v1_0
                                               errorDescription:&error];
    [xmldata writeToFile:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"Machines.plist"] atomically:YES];
}




- (NSDictionary*) get_machine_defaults {
    if (!supported) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Alert!",nil)
                                         defaultButton:NSLocalizedString(@"Continue",nil) alternateButton:NSLocalizedString(@"Quit",nil) otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"smcFanControl has not been tested on this machine yet, but it should run if you follow the instructions. \n\nIf you choose to continue, please make sure you have no other FanControl-software running. Otherwise please quit, deinstall the other software, restart your machine and rerun smcFanControl!",nil)];
        NSModalResponse code=[alert runModal];
        if (code == NSAlertDefaultReturn) {
            [self readFromSMC];
            [self refreshPlist];
        } else {
            [[NSApplication sharedApplication] terminate:nil];
        }
        
    }
    
    NSDictionary *defaultsDict=[self readFromPlist];
    NSUInteger i;
    //localize fan-descriptions
    for (i=0;i<[defaultsDict[@"Fans"] count];i++) {
        NSString *newvalue=NSLocalizedString(defaultsDict[@"Fans"][i][@"Description"],nil);
        [defaultsDict[@"Fans"][i] setValue:newvalue forKey:@"Description"];
    }
    
    return defaultsDict;
}

+ (NSString *) computerModel {
    static NSString *computerModel = nil;
    if (!computerModel) {
        io_service_t pexpdev;
        if ((pexpdev = IOServiceGetMatchingService (kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")))) {
            NSData *data;
            if ((data = (id)CFBridgingRelease(IORegistryEntryCreateCFProperty(pexpdev, CFSTR("model"), kCFAllocatorDefault, 0)))) {
                computerModel = [[NSString allocWithZone:NULL]  initWithCString:[data bytes] encoding:NSASCIIStringEncoding];
            }
        }
    }
    return computerModel;
}


@end