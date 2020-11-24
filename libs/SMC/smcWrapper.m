//
//  smcWrapper.m
//  MacStats
//
//  Created by Tymur Pysarevych on 24.11.20.
//

#import <Foundation/Foundation.h>
#import "smcWrapper.h"
#import <CommonCrypto/CommonDigest.h>
#import "MachineDefaults.h"

NSArray *allSensors;

UInt8 fanNum[] = "0123456789ABCDEFGHIJ";

@implementation smcWrapper
io_connect_t conn;

+(void)start{
    SMCOpen(&conn);
}
+(void)cleanUp{
    SMCClose(conn);
}

+(int)convertToNumber:(SMCVal_t) val
{
    float fval = -1.0f;
    
    if (strcmp(val.dataType, DATATYPE_FLT) == 0 && val.dataSize == 4) {
        memcpy(&fval,val.bytes,sizeof(float));
    }
    else if (strcmp(val.dataType, DATATYPE_FPE2) == 0 && val.dataSize == 2) {
        fval = _strtof(val.bytes, val.dataSize, 2);
    }
    else if (strcmp(val.dataType, DATATYPE_UINT16) == 0 && val.dataSize == 2) {
        fval = (float)_strtoul((char *)val.bytes, val.dataSize, 10);
    }
    else if (strcmp(val.dataType, DATATYPE_UINT8) == 0 && val.dataSize == 1) {
        fval = (float)val.bytes[0];
    }
    else if (strcmp(val.dataType, DATATYPE_SP78) == 0 && val.dataSize == 2) {
        fval = ((val.bytes[0] * 256 + val.bytes[1]) >> 2)/64;
    }
    
    return (int)fval;
}

+(float)readTempSensors
{
    float retValue;
    SMCVal_t      val;
    NSString *sensor = @"TC0P";
    SMCReadKeyWithConn((char*)[sensor UTF8String], &val, conn);
    retValue = [self convertToNumber:val];
    allSensors = [NSArray arrayWithObjects: @"TA0P", @"TC0D", @"TC0H", @"TC0P", @"TG0D", @"TG0H", @"TG0P", @"TH0P", @"TL0P", @"TO0P", @"TW0P", @"Tm0P", @"Tp0P" ,nil];
    if (retValue <= 0 || floor(retValue) == 129 ) { //workaround for some iMac Models
        for (NSString *sensor in allSensors) {
            SMCReadKeyWithConn((char*)[sensor UTF8String], &val, conn);
            retValue= [self convertToNumber:val];
            if (retValue>0 && floor(retValue) != 129 ) {
                NSLog(@"Found temp val in %@", sensor);
                break;
            }
        }
    }
    return retValue;
}

+(float) getMainTemp{
    float retValue;
    NSRange range_pro=[[MachineDefaults computerModel] rangeOfString:@"MacPro"];
    if (range_pro.length > 0) {
        retValue = [smcWrapper getMpTemp];
        if (retValue<=0 || floor(retValue) == 129 ) {
            retValue = [smcWrapper readTempSensors];
        }
    } else {
        retValue = [smcWrapper readTempSensors];
    }
    return retValue;
}


//temperature-readout for MacPro contributed by Victor Boyer
+(float) getMpTemp{
    UInt32Char_t  keyA;
    UInt32Char_t  keyB;
    SMCVal_t      valA;
    SMCVal_t      valB;
    // kern_return_t resultA;
    // kern_return_t resultB;
    sprintf(keyA, "TCAH");
    SMCReadKeyWithConn(keyA, &valA, conn);
    sprintf(keyB, "TCBH");
    SMCReadKeyWithConn(keyB, &valB, conn);
    float c_tempA= [self convertToNumber:valA];
    float c_tempB= [self convertToNumber:valB];
    int i_tempA, i_tempB;
    if (c_tempA < c_tempB)
    {
        i_tempB = round(c_tempB);
        return i_tempB;
    }
    else
    {
        i_tempA = round(c_tempA);
        return i_tempA;
    }
}

+(int) getFanRpm:(int)fan_number{
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cAc", fanNum[fan_number]);
    SMCReadKeyWithConn(key, &val,conn);
    int running= [self convertToNumber:val];
    return running;
}

+(int) getFanNum{
    //    kern_return_t result;
    SMCVal_t      val;
    int           totalFans;
    SMCReadKeyWithConn("FNum", &val, conn);
    totalFans = [self convertToNumber:val];
    return totalFans;
}

+(NSString*) getFanDescr:(int)fan_number{
    UInt32Char_t  key;
    char temp;
    SMCVal_t      val;
    //kern_return_t result;
    NSMutableString *desc;
    
    sprintf(key, "F%cID", fanNum[fan_number]);
    SMCReadKeyWithConn(key, &val, conn);
    
    if(val.dataSize>0){
        desc=[[NSMutableString alloc]init];
        int i;
        for (i = 0; i < val.dataSize; i++) {
            if ((int)val.bytes[i]>32) {
                temp=(unsigned char)val.bytes[i];
                [desc appendFormat:@"%c",temp];
            }
        }
    }
    else {
        //On MacBookPro 15.1/16 descriptions aren't available
        desc=[[NSMutableString alloc] initWithFormat:@"Fan #%d",fan_number+1];
    }
    return desc;
}


+(int) getMinSpeed:(int) fan_number{
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cMn", fanNum[fan_number]);
    SMCReadKeyWithConn(key, &val,conn);
    int min= [self convertToNumber:val];
    return min;
}

+(int) getMaxSpeed:(int)fan_number{
    UInt32Char_t  key;
    SMCVal_t      val;
    //kern_return_t result;
    sprintf(key, "F%cMx", fanNum[fan_number]);
    SMCReadKeyWithConn(key, &val,conn);
    int max= [self convertToNumber:val];
    return max;
}

+(int) getMode:(int)fan_number{
    UInt32Char_t  key;
    SMCVal_t      val;
    kern_return_t result;
    
    sprintf(key, "F%dMd", fan_number);
    result = SMCReadKeyWithConn(key, &val,conn);
    // Auto mode's key is not available
    if (result != kIOReturnSuccess) {
        return -1;
    }
    int mode = [self convertToNumber:val];
    return mode;
}


+ (BOOL)validateSMC:(NSString*) path {
    SecStaticCodeRef ref = NULL;
    NSURL * url = [NSURL URLWithString:path];
    OSStatus status;
    // obtain the cert info from the executable
    status = SecStaticCodeCreateWithPath((__bridge CFURLRef)url, kSecCSDefaultFlags, &ref);
    if (status != noErr) {
        return false;
    }
    @try {
        status = SecStaticCodeCheckValidity(ref, kSecCSDefaultFlags, nil);
        if (status != noErr) {
            NSLog(@"Codesign verification failed: Error id = %d",status);
            return false;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Codesign exception %@",exception);
        return false;
    }
    return true;
}

+ (NSString*)createCheckSum:(NSString*)path {
    NSData *d=[NSData dataWithContentsOfMappedFile:path];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5((void *)[d bytes], [d length], result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

//call smc binary with setuid rights and apply
// The smc binary is given root permissions in FanControl.m with the setRights method.
+ (void)setKeyExternal:(NSString *)key value:(NSString *)value{
    NSString *launchPath = [[NSBundle mainBundle]   pathForResource:@"smc" ofType:@""];
    
    NSArray *argsArray = @[@"-k",key,@"-w",value];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: launchPath];
    [task setArguments: argsArray];
    [task launch];
}

+ (void) checkRightStatus: (OSStatus) status {
    if (status != errAuthorizationSuccess) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
}

+ (void) setRights {
    NSString *smcpath = [[NSBundle mainBundle]   pathForResource:@"smc" ofType:@""];
    NSFileManager *fmanage=[NSFileManager defaultManager];
    NSDictionary *fdic = [fmanage attributesOfItemAtPath:smcpath error:nil];
    if ([[fdic valueForKey:@"NSFileOwnerAccountName"] isEqualToString:@"root"] && [[fdic valueForKey:@"NSFileGroupOwnerAccountName"] isEqualToString:@"admin"] && ([[fdic valueForKey:@"NSFilePosixPermissions"] intValue]==3437)) {
        // If the SMC binary has already been modified to run as root, then do nothing.
        return;
    }
    //TODO: Is the usage of commPipe safe?
    FILE *commPipe;
    AuthorizationRef authorizationRef;
    AuthorizationItem gencitem = { "system.privilege.admin", 0, NULL, 0 };
    AuthorizationRights gencright = { 1, &gencitem };
    int flags = kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed;
    OSStatus status = AuthorizationCreate(&gencright,  kAuthorizationEmptyEnvironment, flags, &authorizationRef);
    
    [self checkRightStatus:status];
    
    NSString *tool=@"/usr/sbin/chown";
    NSArray *argsArray = @[@"root:admin",smcpath];
    int i;
    char *args[255];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i]cString];
    }
    args[i] = NULL;
    status = AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    
    [self checkRightStatus:status];
    
    //second call for suid-bit
    tool=@"/bin/chmod";
    argsArray = @[@"6555",smcpath];
    for(i = 0;i < [argsArray count];i++){
        args[i] = (char *)[argsArray[i]cString];
    }
    args[i] = NULL;
    status = AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    
    [self checkRightStatus:status];
}

@end
