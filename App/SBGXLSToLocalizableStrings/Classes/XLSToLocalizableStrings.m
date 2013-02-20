//
//  Created by Roberto Seidenberg
//  All rights reserved
//

// Header
#import "XLSToLocalizableStrings.h"

// App classes
#import "LocalizableStrings.h"

// Vendor
#import "DHxlsReaderIOS.h"

// MARK:Constants
// Parser strings
static NSString* const kXLSToLocalizableStringsParserComment = @"//";
static NSString* const kXLSToLocalizableStringsParserIgnore  = @"XLSToLocalizableStringsIgnore";
// Errors
static NSString* const kXLSToLocalizableStringsErrorDomain               = @"com.elisabit.XLSToLocalizableStrings";
static NSString* const kXLSToLocalizableStringsErrorLanguageCodeExpected = @"Row:%i / Col:%s - Language code expected";
static NSString* const kXLSToLocalizableStringsErrorLanguageKeyExpected  = @"Row:%i / Col:%s - Language key expected";
static NSString* const kXLSToLocalizableStringsErrorTranslationExpected  = @"Row:%i / Col:%s - Translation expected";

@implementation XLSToLocalizableStrings

// MARK: Parsing
- (BOOL)parseFileAtPath:(NSString *)sourceFilePath outputDirectory:(NSString *)outputDirectory error:(NSError *__autoreleasing *)error {
	
	// Return values
	BOOL success;
	
	// Init xls parser
	DHxlsReader *reader = [DHxlsReader xlsReaderFromFile:sourceFilePath];
	
	// Start parsing
	[reader startIterator:0];
	DHcell *cell = [reader nextCell];
	
	// Parsing tags
	NSUInteger lastCol = 0; NSString *lastColStr;
	
	// Parsed objects storage
	NSMutableArray *mLocalizedKeys    = [NSMutableArray array];
	NSMutableArray *mLocalizedStrings = [NSMutableArray array];
	
	// Parse positions
	// Relative row position equals absolute row position minus commented rows
	// This allows to have any number of commented rows in the file
	NSUInteger relativeRow = 0;
	NSUInteger commentedRows = 0;
	
	// Iterate over cells
	while(cell) {
		
		// Cancel if last cell reached
		if(cell.type == cellBlank) break;
		
		// This row is a comment
		if ((cell.col == 1) && ([cell.str isEqualToString:kXLSToLocalizableStringsParserComment])) {
			
			// Skip row
			++commentedRows;
			NSUInteger row = cell.row;
			while (row == cell.row) cell = [reader nextCell];
			
		// This row is not a comment
		} else {
			
			// Parse language codes
			// Codes start from relative row 0, begining at column 3
			if ((relativeRow == 0) && (cell.col >= 3)) {
				
				// Code found
				if ([cell.str length]) {
					
					// Init localizable string object with found code
					LocalizableStrings *locStr = [[LocalizableStrings alloc] initWithLocaleIdentifier:cell.str error:error];
					
					// Object succesfully initialized
					if (locStr) {
						
						// Add object to localizable strings array
						[mLocalizedStrings addObject:locStr];
						
						// Error initializing object
					} else {
						
						// Build error dict
						NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
						NSString *errorString = [NSString stringWithFormat:kXLSToLocalizableStringsErrorLanguageCodeExpected, cell.row, cell.colStr];
						[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
						*error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
						
						// Cancel parsing
						success = NO;
						break;
					};
					
				// No code found
				} else {
					
					// Build error dict
					NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
					NSString *errorString = [NSString stringWithFormat:kXLSToLocalizableStringsErrorLanguageCodeExpected, cell.row, cell.colStr];
					[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
					
					// Cancel parsing
					success = NO;
					break;
				}
				
			// Parse keys
			// Keys start from relative row 1, fixed to column 2
			} else if ((relativeRow >= 1) && (cell.col == 2)) {
				
				// Key found
				if ([cell.str length]) {
					
					// Add key to keys array
					[mLocalizedKeys addObject:cell.str];
					
				// Key missing
				} else {
					
					// Build error dict
					NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
					NSString *errorString = [NSString stringWithFormat:kXLSToLocalizableStringsErrorLanguageKeyExpected, cell.row, cell.colStr];
					[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
					
					// Cancel parsing
					success = NO;
					break;
				}
				
			// Parse translation strings
			// Translations start from relative row 1 beginning at column 3
			} else if ((relativeRow >= 1) && (cell.col >= 3)) {
				
				// Missing translation?
				if (cell.col != 3) {
					if (lastCol+1 != cell.col) {
						NSLog(@"WARNING: Missing translation Row:%i / Col:%@", cell.row, lastColStr);
					}
				}
				lastCol    = cell.col;
				lastColStr = [NSString stringWithCString:cell.colStr encoding:NSUTF8StringEncoding];
				
				// Translation found
				if ([cell.str length]) {
					
					// Find corresponding LocalizedStrings object
					LocalizableStrings *locStr = [mLocalizedStrings objectAtIndex:cell.col-3];
					
					// Find corresponding key
					NSString *key = [mLocalizedKeys objectAtIndex:relativeRow-1];
					
					// Set key and translation
					[locStr setString:cell.str forKey:key];
					
				// Translation missing
				} else {
					
					// Build error dict
					NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
					NSString *errorString = [NSString stringWithFormat:kXLSToLocalizableStringsErrorTranslationExpected, cell.row, cell.colStr];
					[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
					
					// Cancel parsing
					success = NO;
					break;
				}
			}

			// Next cell
			NSUInteger previousRow = cell.row;
			cell                   = [reader nextCell];
			if (previousRow < cell.row) ++relativeRow;
		}
	}
	
	// Save files in appropriate directorys
	for (LocalizableStrings *strings in mLocalizedStrings) {
		
		// Build path and create directory
		NSString *localizationFileDirectory = [outputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lproj", [strings localeIdentifier]]];
		success = [[NSFileManager defaultManager] createDirectoryAtPath:localizationFileDirectory withIntermediateDirectories:YES attributes:nil error:error];

		// Path valid
		if (success) {
			
			// Save file
			success = [[strings localizableStrings] writeToFile:[localizationFileDirectory stringByAppendingPathComponent:@"Localizable.strings"] atomically:YES encoding:NSUTF8StringEncoding error:error];
			
			// Cancel on error
			if (!success) break;
		}
	}
	
	// Return state
	return success;
}
@end