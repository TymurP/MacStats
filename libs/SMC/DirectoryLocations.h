//
//  DirectoryLocations.h
//  MacStats
//
//  Created by Tymur Pysarevych on 24.11.20.
//

#ifndef DirectoryLocations_h
#define DirectoryLocations_h

#import <Foundation/Foundation.h>

//
// DirectoryLocations is a set of global methods for finding the fixed location
// directoriess.
//
@interface NSFileManager (DirectoryLocations)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
    inDomain:(NSSearchPathDomainMask)domainMask
    appendPathComponent:(NSString *)appendComponent
    error:(NSError **)errorOut;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *applicationSupportDirectory;

@end

#endif /* DirectoryLocations_h */
