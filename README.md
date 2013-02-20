## SBGXLSToLocalizableStrings

Replace the XCode Localizable.strings mush with a single Excel file.

## Features

* Converts localization key value pairs from Excel files to a localized directory structure and Localizable.strings files as used by Xcode.
*  Takes care of conversion of special characters (linebreaks and so on)

### Project Setup

Clone the project including submodules:

	$ git clone --recursive https://github.com/robertoseidenberg/SBGXLSToLocalizableStrings.git
	
Build and run the project using XCode.

### Exel format specifications

See the included HelloWorld.xls. 

### Usage example

Command:

	SBGXLSToLocalizableStrings HelloWorld.xls /Users/Me/.../MyProject/Localization/

HelloWorld.xls defines three language codes, therefore it generates the following directory structure:

	* /.../Localization/
		* en.lproj
			* Localizable.strings
		* es.lproj
			* Localizable.strings			
		* fr.lproj
			* Localizable.strings

### XCode integration

It is most convenient to have a single Excel file in your project and generate localization directory tree at build time. 

1. Go to Xcode project settings
2. Click: "Add Build phase"
3. Name it: "GenerateLocalizedStrings files"
4. Script: <code>{YOURPATH}/SBGXLSToLocalizableStrings {YOURPATH}/MyLocalizableStringsExcel.xls {GENERTED FILES DIR}</code>

### Acknowledgements

SBGXLSToLocalizableStrings makes heavy use these open source projects:

* [DHlibxls](https://github.com/dhoerl/DHlibxls) - An ObjectiveC Framework that can read MicroSoft Excel(TM) Files.
* [libxls](http://sourceforge.net/projects/libxls/) - Library for parsing Excel (XLS) files.