//
//  Created by Roberto Seidenberg
//  All rights reserved
//

// Apple
#import <Foundation/Foundation.h>

@interface XLSToLocalizableStrings : NSObject

// MARK: Parsing
- (BOOL)parseFileAtPath:(NSString *)sourceFilePath outputDirectory:(NSString *)outputDirectory error:(NSError *__autoreleasing *)error;
@end