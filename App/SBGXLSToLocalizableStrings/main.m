//
//  Created by Roberto Seidenberg
//  All rights reserved
//

// Apple
#import <Foundation/Foundation.h>

// App classes
#import "XLSToLocalizableStrings.h"

int main(int argc, const char * argv[]) {
	
	@autoreleasepool {
		
		// Returned values
		NSError *error = nil;
		BOOL success   = NO;
	    
		// Arguments mismatch
		if (argc != 3) {
			
			// Build error dict
			NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
			NSString *errorString          = @"USAGE: XLSToLocalizableStrings <sourcefile> <output directory>";
			[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
			error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
			
			// Arguments match
		} else {
			
			// File does exist
			NSString *sourceFilePath = [NSString stringWithUTF8String:argv[1]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
				
				// Find output directory
				NSString *outputDirectory = [NSString stringWithUTF8String:argv[2]];
				BOOL isDirectory; BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:outputDirectory isDirectory:&isDirectory];
				
				// File exists that is not a directory
				if (exists && !isDirectory) {
					
					// Build error dict
					NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
					NSString *errorString = [NSString stringWithFormat:@"<output directory> name exists but is not a directory"];
					[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
					error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
					
				} else {
					
					// Directory does not exist
					if  (!exists) {
						
						// Create output directory
						NSError *error        = nil;
						exists = [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory withIntermediateDirectories:YES attributes:nil error:&error];
						[[NSFileManager defaultManager] fileExistsAtPath:outputDirectory isDirectory:&isDirectory];
						
						// Creation of directory failed
						if (!exists) {
							
							// Build error dict
							NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
							NSString *errorString = [NSString stringWithFormat:@"Could not create output directory:%@", outputDirectory];
							[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
							error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
						}
					}
					
					// Output directory does exist now
					if (exists && isDirectory) {
						
						// Parse file
						success = [[[XLSToLocalizableStrings alloc] init] parseFileAtPath:sourceFilePath outputDirectory:outputDirectory error:&error];
					}
				}
				
				// File does not exist
			} else {
				
				// Build error dict
				NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
				NSString *errorString = [NSString stringWithFormat:@"Could not open file:%@", sourceFilePath];
				[errorDict setObject:errorString forKey:NSLocalizedDescriptionKey];
				error = [NSError errorWithDomain:@"com.elisabot.XLSToLocalizableStrings" code:100 userInfo:errorDict];
			}
		}
		
		// Success, exit
		if (success) {
			return 0;
			
			// Error, print and exit
		} else {
			if ([error localizedDescription]) printf("ERROR: %s\n", [[error localizedDescription] UTF8String]);
			return 1;
		}
	}
}

