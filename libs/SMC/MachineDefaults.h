//
//  MachineDefaults.h
//  MacStats
//
//  Created by Tymur Pysarevych on 24.11.20.
//

#ifndef MachineDefaults_h
#define MachineDefaults_h

#import <Cocoa/Cocoa.h>
#import "smcWrapper.h"


@interface MachineDefaults : NSObject {
    NSString *machine;
    NSArray *supported_machines;
    Boolean supported;
    int machine_num;
}

+ (NSString *)computerModel;
- (instancetype)init:(NSString*)p_machine ;

@property (NS_NONATOMIC_IOSONLY, getter=get_machine_defaults, readonly, copy) NSDictionary *_machine_defaults;

@end

#endif /* MachineDefaults_h */
