//
//  Created by Roberto Seidenberg
//  All rights reserved
//

// Apple
#import <Foundation/Foundation.h>

@interface LocalizableStrings : NSObject
// MARK: Properties
@property (strong) NSString *localeIdentifier;

// MARK: Init
- (id)initWithLocaleIdentifier:(NSString *)identifer error:(NSError *__autoreleasing *)error;

// MARK: Setters
- (void)setString:(NSString *)string forKey:(NSString *)key;

// MARK: Utility
- (NSString *)localizableStrings;
@end