

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegateSquinting.h"

@implementation AppDelegate(AppDelegateSquinting)


#pragma mark - Squint Methods


- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck
{
	// Compile runs through a device group's two prime source code files - agent and device - and (via subsidiary methods)
	// looks for #require, #import and #include directives. For the last two of these, it updates the project's
	// lists of recorded libraries and files, and compiles the code into an upload-ready form

	// If we have no currently selected device group, bail

	if (devicegroup == nil)
	{
		[self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	Project *thisProject;
	BOOL agentDoneFlag = NO;
	BOOL deviceDoneFlag = NO;
	NSString *output, *aPath;
	NSUInteger squinted = 0;

	[self writeStringToLog:[NSString stringWithFormat:@"Processing device group \"%@\"...", devicegroup.name] :YES];

	if (devicegroup.models.count == 0 || devicegroup.models == nil)
	{
		// This device group has no software - warn the user and bail

		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device group \"%@\" has no source code files - there is nothing to compile.", devicegroup.name] :YES];
		return;
	}

	// Get the model's parent project

	for (Project *project in projectArray)
	{
		NSMutableArray *dgs = project.devicegroups;

		for (Devicegroup *dg in dgs)
		{
			if (dg == devicegroup)
			{
				thisProject = project;
				break;
			}
		}
	}

	// Process each of the device group's models in turn

	for (Model *model in devicegroup.models)
	{
		// Clear the lists of local libraries and files found in the model
		// 'foundLibs' - all the libraries #imported or #included in the source files, each stored as a File
		// 'foundFiles' - all the non-libraries #imported or #included in the source files, each stored as a File
		// 'foundEILibs' - all the EI libraries #required in the source files, each stored as a File, with the path set to the version

		if (foundFiles != nil) foundFiles = nil;
		if (foundLibs != nil) foundLibs = nil;
		if (foundEILibs != nil) foundEILibs = nil;

		foundFiles = [[NSMutableArray alloc] init];
		foundLibs = [[NSMutableArray alloc] init];
		foundEILibs = [[NSMutableArray alloc] init];

		output = nil;

		NSInteger typeValue = ([model.type compare:@"agent"] == NSOrderedSame) ? kCodeTypeAgent : kCodeTypeDevice;

		// Get the source code full file path - model paths should be relative to the project

		aPath = [NSString stringWithFormat:@"%@/%@", model.path, model.filename];
		aPath = [self getAbsolutePath:thisProject.path :aPath];

		if (aPath != nil)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"Processing %@ code file: \"%@\"...", model.type, aPath.lastPathComponent] :YES];

			output = [self processSource:aPath :typeValue :thisProject.path :model :!justACheck];

			if (output == nil && !justACheck)
			{
				// This is a compile action, so we treat 'output == nil' as a failure

				[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Compilation halted: cannot continue due to errors in %@ code", model.type] :YES];
				model.squinted = NO;
				return;
			}

			if (!justACheck)
			{
				// We are not just checking the code for libraries and includes, so
				// save the compiled code into the model and set the compiled flags

				model.code = output;
				model.squinted = YES;

				if (typeValue == kCodeTypeAgent)
				{
					agentDoneFlag = YES;
					squinted = (squinted | 0x02);
				}

				if (typeValue == kCodeTypeDevice)
				{
					deviceDoneFlag = YES;
					squinted = (squinted | 0x01);
				}
			}

			// Wrangle the libraries and files found in this compilation

			[self processLibraries:model];
		}
	}

	if (!justACheck)
	{
		// We are not just checking the code for libraries and includes,
		// so update the UI as required

		if (agentDoneFlag || deviceDoneFlag)
		{
			// Activate compilation-related UI items

			externalOpenMenuItem.enabled = agentDoneFlag;
			externalOpenDeviceItem.enabled = deviceDoneFlag;
			externalOpenBothItem.enabled = YES;
			logDeviceCodeMenuItem.enabled = deviceDoneFlag;
			logAgentCodeMenuItem.enabled = agentDoneFlag;
		}

		// Update project's compilation status record, 'devicegroup.squinted'
		// NOTE this clears bit 4, ie. the uploaded marker is set to 'not uploaded'

		NSString *resultString = @"";

		switch(squinted)
		{
			case 0:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" has no code to compile and upload.", devicegroup.name];
				break;

			case 1:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - no agent code; device code ready to upload.", devicegroup.name];
				break;

			case 2:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - no device code; agent code ready to upload.", devicegroup.name];
				break;

			case 3:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - agent and device code ready to upload.", devicegroup.name];
		}

		[self writeStringToLog:resultString :YES];
		devicegroup.squinted = squinted;
	}

	// Update libraries menu with updated list of local, EI libraries and local files

	[self refreshMainDevicegroupsMenu];
	[self refreshLibraryMenus];
	[self refreshFilesMenu];
	[self setToolbar];
	[saveLight needSave:thisProject.haschanged];
}



- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode
{
	// Loads the contents of the source code file referenced by 'codePath' - 'codeType' indicates whether the code
	// is agent or device - and parses it for multi-line comment blocks. Only code outside these blocks is passed
	// on for further processing, ie. parsing for #require, #include or #import directives.

	// 'willReturnCode' is set to YES if we want compiled code back; if we are only parsing the code for a list
	// of included files and libraries, we can pass in NO.

	// We return nil if there is a compilation error, otherwise the processed code

	NSRange commentStartRange, commentEndRange;
	NSString *compiledCode = @"";

	// Attempt to load in the source text file's contents

	NSError *error;
	NSString *sourceCode = [NSString stringWithContentsOfFile:codePath encoding:NSUTF8StringEncoding error:&error];

	if (error)
	{
		[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Unable to load source file \"%@\" - aborting compile.", codePath] :YES];
		return nil;
	}

	// Run through the loaded source code searching for multi-line comment blocks
	// When we find one, we examine all the code between the newly found comment block
	// and the previously found one (or the start of the file). 'index' records the location
	// of the start of file or the end of the previous comment block

	NSUInteger index = 0;
	BOOL done = NO;

	while (done == NO)
	{
		commentStartRange = [sourceCode rangeOfString:@"/*" options:NSCaseInsensitiveSearch range:NSMakeRange(index, sourceCode.length - index)];

		if (commentStartRange.location != NSNotFound)
		{
			// We have found a comment block.
			// Get the code *ahead* of the comment block that has not yet been processed,
			// ie. between locations 'index' and 'commentStartRange.location'

			NSRange preCommentRange = NSMakeRange(index, commentStartRange.location - index);
			NSString *codeToProcess = [sourceCode substringWithRange:preCommentRange];

			// Check for #requires
			// 'processRequires:' finds EI libraries, so it doesn't return compiled code

			[self processRequires:codeToProcess];

			// Check for #imports

			NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :projectPath :model :willReturnCode];

			// 'processedCode' returns nil for an error, 'none' for no #imports or checks, and processed code otherwise

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			// Check for #includes

			processedCode = [self processImports:codeToProcess :@"#include" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			// 'codeToProcess' contains compiled code (or the raw code if we are not compiling), so add it to any code we have already

			compiledCode = [compiledCode stringByAppendingString:codeToProcess];

			// We have processed the block of valid code *before* the /*, so find the end of the commment block: */

			commentEndRange = [sourceCode rangeOfString:@"*/" options:NSCaseInsensitiveSearch range:NSMakeRange(commentStartRange.location + 2, sourceCode.length - commentStartRange.location - 2)];

			if (commentEndRange.location != NSNotFound)
			{
				// Found the end of the comment block and it's within the file. Add it to the compiled code store (ie. keep the comment block)
				// NOTE Can make this a preference later, ie. upload code with comments stripped

				NSRange commentRange = NSMakeRange(commentStartRange.location, (commentEndRange.location + 2 - commentStartRange.location));
				compiledCode = [compiledCode stringByAppendingString:[sourceCode substringWithRange:commentRange]];

				// Move 'index' to the end of the comment block

				index = commentStartRange.location + commentRange.length;
			}
			else
			{
				// Got to the end of the source code without finding the end of the comment block so we can ignore all of what remains

				compiledCode = [compiledCode stringByAppendingString:[sourceCode substringFromIndex:commentStartRange.location]];
				done = YES;
			}
		}
		else
		{
			// There are no comment blocks in the remaining code, so just take the remaining code and process it to the end

			NSString *codeToProcess = [sourceCode substringFromIndex:index];

			[self processRequires:codeToProcess];

			NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			processedCode = [self processImports:codeToProcess :@"#include" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			compiledCode = [compiledCode stringByAppendingString:codeToProcess];
			done = YES;
		}
	}

	// Code has been processed: any libraries and linked files that have been found are now stored
	// If we have asked to receive compiled code, return it now, or return nil

	if (willReturnCode) return compiledCode;

	return nil;
}



- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode
{
	// Parses the passed in 'sourceCode' for occurences of 'searchString' - either "#import" or "#include".
	// The value of 'codeType' indicates whether the source is agent or device code.
	// The value of 'willReturnCode' indicates whether the method should returne compiled code or not. If it is
	// being used to gather a list of #included libraries and files, 'willReturnCode' will be NO.

	// NOTE 'projectPath' should be an absolute path to the source file

	NSUInteger lineStartIndex;
	NSRange includeRange, commentRange;
	NSMutableArray *deadLibs, *deadFiles;

	NSString *returnCode = sourceCode;
	NSUInteger index = 0;
	BOOL done = NO;
	BOOL found = NO;

	while (done == NO)
	{
		/*
		 Loop through the code looking any and all appearances of 'searchString':

		 <---- codeStart ---->#import "some.lib"<---- codeEnd ---->
		 ^
		 index

		 after processing becomes

		 <---- codeStart ----><libCode><---- codeEnd ---->
		 ^
		 index
		 */

		includeRange = [returnCode rangeOfString:searchString options:NSCaseInsensitiveSearch range:NSMakeRange(index, returnCode.length - index)];

		if (includeRange.location != NSNotFound)
		{
			NSString *libPath, *libCode, *libName, *libVer;

			// We have found at least one #import or #include. Now find the line it's in,
			// then check to see if we have a comment mark ahead of the directive

			[returnCode getLineStart:&lineStartIndex end:NULL contentsEnd:NULL forRange:includeRange];
			commentRange = NSMakeRange(NSNotFound, 0);

			// Look for '//' between the start of the line and the occurence of the directive

			if (includeRange.location != lineStartIndex) commentRange = [returnCode rangeOfString:@"//" options:NSLiteralSearch range:NSMakeRange(lineStartIndex, includeRange.location - lineStartIndex)];

			if (commentRange.location == NSNotFound)
			{
				// No Comment mark found ahead of the #import on the same line, so we can get the lib's name

				NSString *codeStart, *codeEnd;

				found = YES;

				libName = [returnCode substringFromIndex:(includeRange.location + searchString.length)];
				codeStart = [returnCode substringToIndex:includeRange.location];
				commentRange = [libName rangeOfString:@"\""];
				libName = [libName substringFromIndex:(commentRange.location + 1)];
				commentRange = [libName rangeOfString:@"\""];
				codeEnd = [libName substringFromIndex:(commentRange.location + 1)];
				libName = [libName substringToIndex:commentRange.location];

				// We have a library or file name and path. Now we need to parse the path:
				// Is it absolute (/Users/smitty/GitHub/Project/file.class.nut)
				// Is it relative to home (~/GitHub/Project/file.class.nut)
				// Is it relative to the source file (../aProject/file.class.nut or subfolder/file.class.nut)

				// First, look for the presenct of path indicators

				commentRange = [libName rangeOfString:@"/" options:NSLiteralSearch];

				if (commentRange.location != NSNotFound)
				{
					// Found at least one / so there must be directory info here,
					// even if it's just ~/lib.nut or libs/lib.nut or /users/smitty/libs/lib.nut

					// Get the path component from the source file's library name info

					libPath = [libName stringByDeletingLastPathComponent];
					libPath = [libPath stringByStandardizingPath];

					// Check that the file is not in a folder below the project, eg.
					// subfolder/file.class.nut - ie. there is no prefixing /

					commentRange = [libPath rangeOfString:@"../" options:NSLiteralSearch]; 

                 	BOOL isAbsolute = [libPath hasPrefix:@"/"];
					BOOL containsParentMarker = (commentRange.location != NSNotFound);
                

					if (!isAbsolute)
					{
						// Path not absolute, ie. doesn't start with a /

						if (!containsParentMarker || (containsParentMarker && commentRange.location > 0))
						{
							// There are no relative path indicators - or none at the start - so
                       // this must be a subfolder of the project folder

							libPath = [projectPath stringByAppendingFormat:@"/%@", libPath];
						}
						else
						{
							// Path contains at least one ../

							libPath = [self getAbsolutePath:projectPath :libPath];
						}
					}
					else
					{
						// Don't need to do antything here - path is absolute
					}

					/*
					commentRange = [libPath rangeOfString:@"../" options:NSLiteralSearch];

					if (hasDoubledots)
					{
						// If we have a relative path, process it with 'getAbsolutePath:',
						// otherwise assume we have an absolute path and leave it unchanged

						libPath = [self getAbsolutePath:projectPath :libPath];
					}
					 */

					// Get the actual library name

					libName = [libName lastPathComponent];
				}
				else
				{
					// Didn't find any / characters so we can assume we just have a file name
					// eg. 'lib.class.nut' and that it's in the same folder as the source file

					libPath = projectPath;
				}

#ifdef DEBUG
				NSLog(@"Absolute Path %@", libPath);
				NSLog(@"         Name: %@", libName);

#endif

				// At this point, 'libName' should be of the form 'lib.class.nut', and
				// 'libPath' should be the ABSOLUTE path

				// Assume library or file will be added to the project

				BOOL addToCodeFlag = YES;
				BOOL addToModelFlag = YES;
				BOOL isLibraryFlag = NO;

				// Is the #include a library or a regular file? ie. check for *.class.nut and *.library.nut

				NSRange aRange = [libName rangeOfString:@"class"];
				if (aRange.location != NSNotFound) isLibraryFlag = YES;

				aRange = [libName rangeOfString:@"lib"];
				if (aRange.location != NSNotFound) isLibraryFlag = YES;

				// Attempt to load in the contents of the referenced file

				NSError *error = nil;
				libCode = [NSString stringWithContentsOfFile:[libPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

				if (libCode == nil)
				{
					// Library or file is not in the named directory, so try the source directory

					libCode = [NSString stringWithContentsOfFile:[projectPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

					if (libCode == nil)
					{
						// Library or file is not in the named directory, so try the working directory
						// Note: this is repeated test if the project is in the working directory

						libCode = [NSString stringWithContentsOfFile:[workingDirectory stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

						if (libCode == nil)
						{
							// Library or file is not in the working directory, try the saved directory, if we have one

							NSString *savedPath = nil;

							if (isLibraryFlag)
							{
								for (File *lib in model.libraries)
								{
									if (([lib.filename compare:libName] == NSOrderedSame) && ([lib.type compare:@"library"] == NSOrderedSame)) savedPath = lib.path;
								}
							}
							else
							{
								for (File *file in model.files)
								{
									if (([file.filename compare:libName] == NSOrderedSame) && ([file.type compare:@"file"] == NSOrderedSame)) savedPath = file.path;
								}
							}

							if (savedPath != nil)
							{
								// We have a saved path for this file, so try it - remember it's relative

								savedPath = [self getAbsolutePath:projectPath :savedPath];

								libCode = [NSString stringWithContentsOfFile:[savedPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

								if (libCode == nil)
								{
									// The library in not in the working directory or in its saved location, so bail if we are compiling
									// We can't really continue the compilation, but we can look for other libraries if that's all we're doing

									if (isLibraryFlag)
									{
										if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
										[deadLibs addObject:libName];
									}
									else
									{
										if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
										[deadFiles addObject:libName];
									}

									addToCodeFlag = NO;
									addToModelFlag = NO;

									// If we're compiling, bail

									if (willReturnCode) done = YES;
								}
								else
								{
									// Found the file, so use the saved path

									libPath = savedPath;
								}
							}
							else
							{
								// The library or file is not in the named or working directory, and we have no saved location for it, so bail
								// We can't really continue the compilation, but we can look for other libraries

								if (isLibraryFlag)
								{
									if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
									[deadLibs addObject:libName];
								}
								else
								{
									if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
									[deadFiles addObject:libName];
								}

								addToCodeFlag = NO;
								addToModelFlag = NO;

								// If we are compiling, however, bail

								if (willReturnCode) done = YES;
							}
						}
						else
						{
							// The library is in the working directory, so use that as its path

							libPath = workingDirectory;
						}
					}
					else
					{
						// The library is in the source directory, so use that as its path

						libPath = projectPath;
					}
				}

				libVer = [self getLibraryVersionNumber:libCode];

				BOOL match = NO;

				if (addToModelFlag)
				{
					// 'addToProjectFlag' defaults to YES, ie. if we find a library we want to
					// add it to the model. It becomes NO if a located library can't be found
					// in the file system, ie. we *can't* add it to the model

					if (isLibraryFlag)
					{
						// Item is a library or class
						// Check we haven't found it already

						if (foundLibs.count > 0)
						{
							for (File *alib in foundLibs)
							{
								if ([alib.filename compare:libName] == NSOrderedSame)
								{
									// We have match, but the library may have been included in the agent
									// code and we are now looking at the device code (agent always comes first)
									// so check this before setting 'match'

									if (codeType == kCodeTypeAgent)
									{
										if ([model.type compare:@"agent"] == NSOrderedSame)
										{
											match = YES;
										}
										else
										{
											// Library matches with a library found in a different file,
											// ie. no need to add it to the found list again BUT we DO want
											// to compile it in

											addToModelFlag = NO;
										}
									}
									else
									{
										if ([model.type compare:@"device"] == NSOrderedSame)
										{
											match = YES;
										}
										else
										{
											addToModelFlag = NO;
										}
									}
								}
							}
						}

						if (!match && addToModelFlag)
						{
							// NOTE file path at this point is still absolute - we deal with that in 'processLibraries:'

							File *newLib = [[File alloc] init];
							newLib.type = @"library";
							newLib.filename = libName;
							newLib.path = libPath;
							newLib.version = libVer;

							[foundLibs addObject:newLib];
							[self writeStringToLog:[NSString stringWithFormat:@"Local library \"%@\" found in source.", libName] :YES];
						}
					}
					else
					{
						// File name lacks neither a library or class tagging so assume it's a general file
						// Check we haven't found it already

						if (foundFiles.count > 0)
						{
							for (File *file in foundFiles)
							{
								if ([file.filename compare:libName] == NSOrderedSame) match = YES;
							}
						}

						if (!match && addToModelFlag)
						{
							// NOTE file path at this point is still absolute - we deal with that in 'processLibraries:'

							File *newFile = [[File alloc] init];
							newFile.type = @"file";
							newFile.filename = libName;
							newFile.path = libPath;

							[foundFiles addObject:newFile];
							[self writeStringToLog:[NSString stringWithFormat:@"Local file \"%@\" found in source.", libName] :YES];
						}
					}
				}

				// Compile in the code if this is required (it may not be if we're just scanning for libraries and files

				if (addToCodeFlag)
				{
					// 'addToCodeFlag' defaults to YES - we assume that if we have found a library in the
					// source code, that we want to add it to the return code. It is set to NO of the library
					// *can't* be located in the file system. NOTE 'libCode' should be valid in this case

					if (!match)
					{
						// Haven't placed the referenced code yet so do it now

						returnCode = [codeStart stringByAppendingString:libCode];
						returnCode = [returnCode stringByAppendingString:codeEnd];

						// Set 'index' to the start of the code that has yet to be checked,
						// after 'codeStart' and 'libCode'

						index = codeStart.length + libCode.length;
					}
					else
					{
						// We have placed this file already so simply remove the reference from the code

						returnCode = [codeStart stringByAppendingString:codeEnd];

						// Set 'index' to the start of the code that has yet to be checked, ie 'codeEnd'

						index = codeStart.length;
					}
				}
				else
				{
					// We couldn't locate the library/file source in the file system, so ignore the library/file and move on

					index = codeStart.length + [libPath stringByAppendingFormat:@"/%@", libName].length;
				}
			}
			else
			{
				// The #include is commented out, so move the file pointer along and look for the next library
				// 'includeRange.location' is the location of the #import or #include, so set 'index' to
				// just past the discovered #import or #include

				index = includeRange.location + searchString.length;
			}
		}
		else
		{
			// There are no more occurrences of '#import' in the rest of the file, so mark search as done

			done = YES;
		}
	}

	// If there were no #includes, we can bail

	if (!found) return @"none";

	// If any libraries / files can't be located, these are listed in 'deadLibs' / 'deadFiles'

	if (deadLibs.count > 0)
	{
		NSString *mString = nil;

		if (deadLibs.count == 1)
		{
			mString = [NSString stringWithFormat:@"1 local library, \"%@\", can’t be located in the file system.", [deadLibs firstObject]];
		}
		else
		{
			NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadLibs.count ; ++i)
			{
				dString = [dString stringByAppendingFormat:@"%@, ", [deadLibs objectAtIndex:i]];
			}

			dString = [dString substringToIndex:dString.length - 2];
			mString = [NSString stringWithFormat:@"%li local libraries - %@ - can’t be located in the file system.", deadLibs.count, dString];
		}

		[self writeErrorToLog:mString :YES];

		NSString *tString = ((codeType == kCodeTypeDevice) ? @"You should check the library locations specified in your device code." : @"You should check the library locations specified in your agent code.");
		[self writeStringToLog:tString :YES];

		// If we're compiling rather than just checking code, bail and indicate an error condition

		if (returnCode) return nil;
	}

	if (deadFiles.count > 0)
	{
		NSString *mString = nil;

		if (deadFiles.count == 1)
		{
			mString = [NSString stringWithFormat:@"1 local file, \"%@\", can’t be located in the file system.", [deadFiles firstObject]];
		}
		else
		{
			NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadFiles.count ; ++i)
			{
				dString = [dString stringByAppendingFormat:@"%@, ", [deadFiles objectAtIndex:i]];
			}

			dString = [dString substringToIndex:dString.length - 2];
			mString = [NSString stringWithFormat:@"%li local files - %@ - can’t be located in the file system.", deadLibs.count, dString];
		}

		[self writeStringToLog:mString :YES];
		[self writeStringToLog:@"You should check the file locations specified in your source code." :YES];

		if (returnCode) return nil;
	}

	// At this point, 'foundlibs' contains zero or more local libraries and 'foundFiles' contains zero or more local files
	// 'deadLibs' and 'deadFiles' will be empty - ie. there are no libraries and files included that could not be located

	if (willReturnCode == YES) return returnCode;

	return @"none";
}



- (void)processRequires:(NSString *)sourceCode
{
	// Parses the passed in 'sourceCode' for #require directives. If any are found,
	// their names and version numbers are stored in 'foundEILibs' for later processing

	NSRange requireRange, commentRange;
	NSUInteger lineStartIndex;
	NSString *libName;

	BOOL done = NO;
	NSUInteger index = 0;

	// Remove the list of currently known EI libs?

	while (done == NO)
	{
		// Look for the NEXT occurrence of the #require directive

		requireRange = [sourceCode rangeOfString:@"#require" options:NSCaseInsensitiveSearch range:NSMakeRange(index, sourceCode.length - index)];

		if (requireRange.location != NSNotFound)
		{
			// We have found at least one '#require'. Find the line it is in and then run through the
			// line char by char to see if we have a single-line comment mark ahead of the #require

			[sourceCode getLineStart:&lineStartIndex end:NULL contentsEnd:NULL forRange:requireRange];

			commentRange = NSMakeRange(NSNotFound, 0);

			// If the #require is not at the start of a line, see if it is preceded by comment marks

			if (requireRange.location != lineStartIndex) commentRange = [sourceCode rangeOfString:@"//" options:NSLiteralSearch range:NSMakeRange(lineStartIndex, requireRange.location - lineStartIndex)];

			if (commentRange.location == NSNotFound)
			{
				// No Comment mark found ahead of the #require on the same line, so we can get the EI library's name

				libName = [sourceCode substringFromIndex:(requireRange.location + 8)];
				commentRange = [libName rangeOfString:@"\""];
				libName = [libName substringFromIndex:(commentRange.location + 1)];
				commentRange = [libName rangeOfString:@"\""];
				libName = [libName substringToIndex:commentRange.location];

				// Check for spaces and remove

				libName = [libName stringByReplacingOccurrencesOfString:@" " withString:@""];

				// Separate name from version, eg. "lib.class.nut:1.0.0"

				NSArray *elements = [libName componentsSeparatedByString:@":"];

				// Add the library to the project - name and version (as string)

				File *newLib = [[File alloc] init];
				newLib.filename = elements.count > 0 ? [elements objectAtIndex:0] : nil;
				newLib.version = elements.count > 1 ? [elements objectAtIndex:1] : nil;
				newLib.type = @"eilib";

				if (newLib.filename != nil)
				{
					// Only manage the library if we've found one
					// NOTE is this belts and braces?

					// Add a warning if the library has no version value

					if (newLib.version == nil || newLib.version.length == 0)
					{
						// EI Library has no version number - which will compile here, but not in the impCloud

						[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Electric Imp Library \"%@\" included in source but has no version. Code will compile here but may be rejected by the impCloud.", newLib.filename] :YES];

						[self writeWarningToLog:@"          You should check Electric Imp Library versions to determine the latest version number." :YES];

						newLib.version = @"not set";
					}
					else
					{
						// Log and record the found library's name

						[self writeStringToLog:[NSString stringWithFormat:@"Electric Imp Library \"%@\" version %@ included in source.", newLib.filename, newLib.version] :YES];
					}

					if (foundEILibs.count == 0)
					{
						// Use the File object, just set the .path to the EI library version

						[foundEILibs addObject:newLib];
					}
					else
					{
						BOOL match = NO;

						for (File *aLib in foundEILibs)
						{
							// See if the library is already listed

							if (([aLib.filename compare:[elements objectAtIndex:0]] == NSOrderedSame) && ([aLib.path compare:[elements objectAtIndex:1]] == NSOrderedSame)) match = YES;
						}

						if (!match) [foundEILibs addObject:newLib];
					}
				}
			}

			// Move the file pointer along and look for the next library

			index = requireRange.location + 9;
		}
		else
		{
			// There are no more occurrences of '#require' in the rest of the file, so mark search as done

			done = YES;
		}
	}
}



- (void)processLibraries:(Model *)model
{
	// This method wrangles the collection of current libraries found in the source code files
	// It looks for Electric Imp links and for local files and libraries

	// Get the model's parent project

	Project *thisProject;
	//Devicegroup *thisDevicegroup;

	for (Project *project in projectArray)
	{
		if (project.devicegroups.count > 0)
		{
			for (Devicegroup *dg in project.devicegroups)
			{
				NSMutableArray *ms = dg.models;

				for (Model *m in ms)
				{
					if (m == model)
					{
						thisProject = project;
						//thisDevicegroup = dg;
						break;
					}
				}
			}
		}
	}

	if (thisProject == nil)
	{
		// WHOOPS

		NSLog(@"Found orphan model in processLibraries:");
		return;
	}

	// PROCESS EI LIBRARIES

	// Do we have any Electric Imp libraries #required in the source code?

	if (foundEILibs.count > 0 && model.impLibraries == nil) model.impLibraries = [[NSMutableArray alloc] init];

	NSMutableArray *iLibs = model.impLibraries;

	if (foundEILibs.count == 0)
	{
		// There are no EI libraries in the current code - though there may have been some included before

		if (iLibs.count > 0)
		{
			if (iLibs.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 Electric Imp library no longer included in this %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li Electric Imp libraries no longer included in this %@ code.", (long)iLibs.count, model.type] :YES];
			}

			[iLibs removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No Electric Imp libraries included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		// First, run through the contents of 'foundEILibs' to see if there is a 1:1 match with
		// the lists of known local librariess; if not, mark that the project has changed

		if (iLibs.count > 0)
		{
			for (File *aLib in foundEILibs)
			{
				NSString *match = nil;

				// Does the library name match an existing one?

				for (File *lib in iLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame)
					{
						// If there is a match, set the value of 'match' to the found library version

						match = lib.path;
					}
				}

				if (match == nil)
				{
					// There's a library here that is not in the original list

					++added;
				}
				else
				{
					// The found library does match, but we should check if its version has changed

					if ([match compare:aLib.path] != NSOrderedSame)
					{
						// Names match but the versions don't

						[self writeStringToLog:[NSString stringWithFormat:@"Electric Imp library \"%@\" has been changed from version \"%@\" to \"%@\".", aLib.filename, match, aLib.path] :YES];
					}
				}
			}

			for (File *lib in iLibs)
			{
				BOOL match = NO;

				for (File *aLib in foundEILibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match)
				{
					// There is a saved library that's no longer present

					++removed;
				}
			}
		}
		else
		{
			added = foundEILibs.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No Electric Imp libraries added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 Electric Imp library added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li Electric Imp libraries added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 Electric Imp library removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li Electric Imp libraries removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'
		// NOTE impLibraries is not saved

		model.impLibraries = foundEILibs;
	}

	// PROCESS LOCAL LIBRARIES

	// Do we have any local libraries #included or #imported in the source code?

	// Check for a disparity between the number of known libraries and those found in the compilation
	// If there is a disparity, the project has changed so set the 'need to save' flag. Note if there
	// is no disparity, there may still have been changes made - we check for these below

	// Local libraries #included or #imported in the source code will all be stored in 'foundLibs'

	if (foundLibs.count > 0 && model.libraries == nil) model.libraries = [[NSMutableArray alloc] init];

	NSMutableArray *mLibs = model.libraries;

	if (foundLibs.count == 0)
	{
		// There are no libraries #included or #imported in the current code,
		// so clear the counts and the lists stored in the project

		if (mLibs.count > 0)
		{
			if (mLibs.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 local library no longer referenced in the %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the %@ code.", (long)mLibs.count, model.type] :YES];
			}

			thisProject.haschanged = YES;
			[mLibs removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local libraries included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		// First, run through the contents of 'foundLibs' to see if there is a 1:1 match with
		// the lists of known local librariess; if not, mark that the project has changed

		if (mLibs.count > 0)
		{
			for (File *aLib in foundLibs)
			{
				BOOL match = NO;

				for (File *lib in mLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++added;
			}

			for (File *lib in mLibs)
			{
				BOOL match = NO;

				for (File *aLib in foundLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++removed;
			}
		}
		else
		{
			added = foundLibs.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local libraries added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			thisProject.haschanged = YES;

			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 local library added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li local libraries added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 local library removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li local libraries removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'

		model.libraries = foundLibs;
	}

	// PROCESS LOCAL FILES

	// Do we have any local files #included or #imported in the source code?

	// Local files #included or #imported in the source code will all be stored in 'foundFiles'
	// Clear out the recorded files lists and add in the new ones from 'foundFiles'

	if (foundFiles.count > 0 && model.files == nil) model.files = [[NSMutableArray alloc] init];

	NSMutableArray *mFiles = model.files;

	if (foundFiles.count == 0)
	{
		// There are no libraries #included or #imported in the current code,
		// so clear the counts and the lists stored in the project

		if (mFiles.count > 0)
		{
			if (mFiles.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 local file no longer referenced in the %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li local file no longer referenced in the %@ code.", (long)mFiles.count, model.type] :YES];
			}

			thisProject.haschanged = YES;
			[mFiles removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local files included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		if (mFiles.count > 0)
		{
			for (File *aFile in foundFiles)
			{
				BOOL match = NO;

				for (File *file in mFiles)
				{
					if ([aFile.filename compare:file.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++added;
			}

			for (File *file in mFiles)
			{
				BOOL match = NO;

				for (File *aFile in foundFiles)
				{
					if ([aFile.filename compare:file.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++removed;
			}
		}
		else
		{
			added = foundFiles.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local files added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			thisProject.haschanged = YES;

			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 local file added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li local files added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 local file removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li local file removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'

		model.files = foundFiles;
	}

	// Finally, clear and register the new libraries for changes
	// NOTE 'mFiles' and 'mLibs' point to the old lists

	for (File *item in mFiles) { [fileWatchQueue removePath:[self getAbsolutePath:thisProject.path :item.path]]; }
	for (File *item in mLibs) { [fileWatchQueue removePath:[self getAbsolutePath:thisProject.path :item.path]]; }

	for (File *item in model.libraries)
	{
		NSString *path = [item.path stringByAppendingFormat:@"/%@", item.filename];
		if (![fileWatchQueue isPathBeingWatched:path]) [fileWatchQueue addPath:path];
	}

	for (File *item in model.files)
	{

		NSString *path = [item.path stringByAppendingFormat:@"/%@", item.filename];
		if (![fileWatchQueue isPathBeingWatched:path]) [fileWatchQueue addPath:path];
	}

	// Finally convert paths from absolute paths to relative paths for storage

	for (File *lib in model.libraries)
	{
		lib.path = [self getRelativeFilePath:thisProject.path :lib.path];

#ifdef DEBUG
		NSLog(@"Relative Path: %@", lib.path);
		NSLog(@"         Name: %@", lib.filename);
#endif

	}

	for (File *file in model.files)
	{
		file.path = [self getRelativeFilePath:thisProject.path :file.path];

#ifdef DEBUG
		NSLog(@"Relative Path: %@", file.path);
		NSLog(@"         Name: %@", file.filename);
#endif

	}
}



- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index
{
	NSArray *lines = [[code substringToIndex:index] componentsSeparatedByString:@"\n"];
	return lines.count;
}



- (NSString *)getLibraryVersionNumber:(NSString *)libcode
{
	NSString *returnString = @"";

	if (libcode == nil) return returnString;

	NSError *err;
	NSString *pattern = @"static *VERSION *= *\"[0-9]*.[0-9]*.[0-9]*\"";
	NSRegularExpressionOptions regexOptions =  NSRegularExpressionCaseInsensitive;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&err];
	if (err) return returnString;
	NSTextCheckingResult *result = [regex firstMatchInString:libcode options:0 range:NSMakeRange(0, libcode.length)];
	NSRange vRange = (result != nil) ? result.range : NSMakeRange(NSNotFound, 0);

	// TODO check for comments

	if (vRange.location != NSNotFound)
	{
		libcode = [libcode substringFromIndex:vRange.location];
		vRange = [libcode rangeOfString:@"\"" options:NSCaseInsensitiveSearch];
		libcode = [libcode substringFromIndex:vRange.location + 1];
		NSRange eRange = [libcode rangeOfString:@"\"" options:NSCaseInsensitiveSearch];

		if (eRange.location != NSNotFound)
		{
			NSString *rString = [libcode substringToIndex:eRange.location];
			NSArray *vParts = [rString componentsSeparatedByString:@"."];

			for (NSString *part in vParts)
			{
				rString = [part stringByReplacingOccurrencesOfString:@" " withString:@""];
				if (rString.length == 0) rString = @"0";
				returnString = [returnString stringByAppendingFormat:@"%@.", rString];
			}

			returnString = [returnString substringToIndex:returnString.length - 1];
		}
	}

	return returnString;
}


@end
