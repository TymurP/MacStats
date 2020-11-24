//
//  smcWrapper.h
//  MacStats
//
//  Created by Tymur Pysarevych on 23.11.20.
//

#ifndef smcWrapper_h
#define smcWrapper_h

#import <Cocoa/Cocoa.h>
#import "smcBinary.h"

@interface smcWrapper : NSObject {
}

+(void) start;
+(void) setRights;
+(void) cleanUp;

+(int) getFanRpm:(int)fan_number;
+(float) getMainTemp;
+(float) getMpTemp;
+(int) getFanNum;
+(int) getMinSpeed:(int)fan_number;
+(int) getMaxSpeed:(int)fan_number;
+(int) getMode:(int)fan_number;
+(void)setKeyExternal:(NSString *)key value:(NSString *)value;
+(NSString*) getFanDescr:(int)fan_number;

@end

#endif /* smcWrapper_h */
