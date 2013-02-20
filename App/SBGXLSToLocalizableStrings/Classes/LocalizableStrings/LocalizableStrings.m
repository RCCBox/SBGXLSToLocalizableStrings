//
//  Created by Roberto Seidenberg
//  All rights reserved
//

// Header
#import "LocalizableStrings.h"

@interface LocalizableStrings()
@property (strong) NSDictionary *localeDictionary;
@property (weak)   NSError      *error;
@end

@implementation LocalizableStrings

// MARK: Init
- (id)initWithLocaleIdentifier:(NSString *)identifer error:(NSError *__autoreleasing *)error {
	
	// It's not allowed to call this method with a nil argument
	if (!identifer) return nil;
	
	self = [super init];
	if (self) {
		
		// Store identifier
		self.localeIdentifier = identifer;
		
		// Init mutable dictionary
		self.localeDictionary = [NSMutableDictionary dictionary];
	}
	return self;
}

// MARK: Setters
- (void)setString:(NSString *)string forKey:(NSString *)key {
	
	// It's not allowed to call this method with a nil argument
	ZAssert(string, @"VIOLATION: Method argument (NSString *)string: %@", string);
	ZAssert(key, @"VIOLATION: Method argument (NSString *)key: %@", key);
	
	[self.localeDictionary setValue:string forKey:key];
}

// MARK: Utility
- (NSString *)localizableStrings {
	
	// Returned string
	NSMutableString *mStr = [NSMutableString string];
	
	// Iterate over keys
	for (NSString *key in [self.localeDictionary allKeys]) {
		
		// Append prefix
		[mStr appendFormat:@"%@=\"", key];
	
		// Get string
		NSString *str = [self.localeDictionary valueForKey:key];
		
		// Replace forbidden characters
		// Newline, Quotes
		NSString *escapedNewlines = [[str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"\\n"];
		NSString *esapedQuotes    = [escapedNewlines stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		[mStr appendString:esapedQuotes];
		
		// Appends suffix
		[mStr appendString:@"\";\n"];
	}
	
	// Return
	return [mStr copy];
}
@end