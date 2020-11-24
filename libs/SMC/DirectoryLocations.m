//
//  DirectoryLocations.m
//  MacStats
//
//  Created by Tymur Pysarevych on 24.11.20.
//

#import <Foundation/Foundation.h>
#import "DirectoryLocations.h"

enum
{
    DirectoryLocationErrorNoPathFound,
    DirectoryLocationErrorFileExistsAtLocation
};
    
NSString * const DirectoryLocationDomain = @"DirectoryLocationDomain";

@implementation NSFileManager (DirectoryLocations)


/*!  Method to tie together the steps of:
    1) Locate a standard directory by search path and domain mask
    2) Select the first path in the results
    3) Append a subdirectory to that path
    4) Create the directory and intermediate directories if needed
    5) Handle errors by emitting a proper NSError object
* \         pararm searchPathDirectory - the search path passed to NSSearchPathForDirectoriesInDomains
* \         pararm domainMask - the domain mask passed to NSSearchPathForDirectoriesInDomains
* \         pararm appendComponent - the subdirectory appended
* \         pararm errorOut - any error from file operations
* \         returns returns the path to the directory (if path found and exists), nil otherwise
*/
- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
    inDomain:(NSSearchPathDomainMask)domainMask
    appendPathComponent:(NSString *)appendComponent
    error:(NSError **)errorOut
{
    // Declare an NSError first, so we don't need to check errorOut again and again
    NSError *error;
    
    if (errorOut) {
        error = *errorOut;
    }
    else {
        error = nil;
    }

    //
    // Search for the path
    //
    NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory,domainMask,YES);
    
    if ([paths count] == 0)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedStringFromTable(@"No path found for directory in domain.",@"Errors",nil),
                                    @"NSSearchPathDirectory":@(searchPathDirectory),
                                    @"NSSearchPathDomainMask":@(domainMask)};
                
        error = [NSError errorWithDomain:DirectoryLocationDomain
                                        code:DirectoryLocationErrorNoPathFound
                                    userInfo:userInfo];
        return nil;
    }
    
    //
    // Normally only need the first path returned
    //
    NSString *resolvedPath = paths[0];
    //
    // Append the extra path component
    //
    if (appendComponent)
    {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    //
    // Create the path if it doesn't exist
    //
    if ([self createDirectoryAtPath:resolvedPath withIntermediateDirectories:YES
                          attributes:nil error:&error])
        return resolvedPath;
    else
        return nil;
}


/*! applicationSupportDirectory
* \     returns The path to the applicationSupportDirectory (creating it if it doesn't exist).
*/
- (NSString *)applicationSupportDirectory
{
    NSString *executableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    
    NSError *error = nil;
    
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                               appendPathComponent:executableName
                                             error:&error];
    if (!result)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }
    return result;
}

@end
