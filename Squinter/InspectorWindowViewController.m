

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import "InspectorWindowViewController.h"

@interface InspectorWindowViewController ()

@end

@implementation InspectorWindowViewController

@synthesize project, products, devices, mainWindowFrame;


#pragma mark - ViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Clear the content arrays:
	// 'keys' are the left column contents
	// 'values' are the right column contents

	keys = [[NSMutableArray alloc] init];
	values = [[NSMutableArray alloc] init];

	// Set up the main table

	infoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;
	[self setProject:nil];

	// Position the window to the right of screen

	mainWindowFrame = [NSScreen mainScreen].frame;

	[self positionWindow];
}



- (void)positionWindow
{
	// Position the window to the right of screen

	NSScreen *ms = [NSScreen mainScreen];
	NSRect wframe = self.view.window.frame;

	if (ms.frame.size.width - (mainWindowFrame.origin.x + mainWindowFrame.size.width) > 420)
	{
		// There's room to put the inspector next to the main window

		wframe.origin.x = mainWindowFrame.origin.x + mainWindowFrame.size.width + 1;
	}
	else
	{
		wframe.origin.x = ms.frame.size.width - 420;
	}

	wframe.origin.y = mainWindowFrame.origin.y + mainWindowFrame.size.height - wframe.size.height;

	[self.view.window setFrame:wframe display:YES];
}



- (void)setProject:(Project *)aProject
{
	// This is the 'project' property setter, which we use to
	// trigger regeneration of the table view

	project = aProject;

	[keys removeAllObjects];
	[values removeAllObjects];

	[keys addObject:@" "];
	[values addObject:@" "];

	// If project does equal nil, we ignore the content creation section
	// and reload the table with empty data

	if (project != nil)
	{
		[keys addObject:@"Project Name "];
		[values addObject:project.name];

		if (project.description != nil && project.description.length > 0)
		{
			[keys addObject:@"Description "];
			[values addObject:project.description];
		}

		[keys addObject:@"ID "];
		[values addObject:(project.pid != nil ? project.pid : @"Undefined")];
		[keys addObject:@"Location "];
		[values addObject:project.path];

		if (project.devicegroups.count > 0)
		{
			NSUInteger dgcount = 1;

			for (Devicegroup *devicegroup in project.devicegroups)
			{
				[keys addObject:@" "];
				[values addObject:@" "];

				[keys addObject:[NSString stringWithFormat:@"Device Group %li ", (long)dgcount]];
				[values addObject:devicegroup.name];
				[keys addObject:@"ID "];

				if (devicegroup.did != nil && devicegroup.did.length > 0)
				{
					[values addObject:devicegroup.did];
				}
				else
				{
					[values addObject:@"Not uploaded"];
				}

				[keys addObject:@"Type "];
				[values addObject:devicegroup.type];

				if (devicegroup.description != nil && devicegroup.description.length > 0)
				{
					[keys addObject:@"Description "];
					[values addObject:devicegroup.description];
				}

				if (devicegroup.models.count > 0)
				{
					NSUInteger modcount = 1;

					for (Model *model in devicegroup.models)
					{
						[keys addObject:@" "];
						[values addObject:@" "];

						[keys addObject:[NSString stringWithFormat:@"Model %li ", (long)modcount]];
						[values addObject:model.filename];
						[keys addObject:@"Type "];
						[values addObject:model.type];
						[keys addObject:@"Location "];
						[values addObject:[self getAbsolutePath:project.path :model.path]];
						[keys addObject:@"Uploaded "];
						[values addObject:model.updated];
						[keys addObject:@"SHA "];
						[values addObject:model.sha];

						if (model.libraries.count > 0)
						{
							NSUInteger libcount = 1;

							for (File *library in model.libraries)
							{
								[keys addObject:@" "];
								[values addObject:@" "];

								[keys addObject:[NSString stringWithFormat:@"Library %li ", (long)libcount]];
								[values addObject:library.filename];
								[keys addObject:@"Location "];
								[values addObject:[self getAbsolutePath:project.path :library.path]];

								++libcount;
							}
						}
						else
						{
							[keys addObject:@"Libraries "];
							[values addObject:@"No local libraries imported"];
						}

						if (model.files.count > 0)
						{
							NSUInteger filecount = 1;

							for (File *file in model.files)
							{
								[keys addObject:@" "];
								[values addObject:@" "];

								[keys addObject:[NSString stringWithFormat:@"File %li ", (long)filecount]];
								[values addObject:file.filename];
								[keys addObject:@"Location "];
								[values addObject:[self getAbsolutePath:project.path :file.path]];

								++filecount;
							}
						}
						else
						{
							[keys addObject:@"Files "];
							[values addObject:@"No local files imported"];
						}

						++modcount;
					}
				}
				++dgcount;
			}
		}
		else
		{
			[keys addObject:@"Device Groups "];
			[values addObject:@"None"];
		}
	}
	else
	{
		// There is no project info to display, so set up
		// some basic keys to show
		[keys addObject:@"Project Name "];
		[values addObject:@" "];
		[keys addObject:@"Description "];
		[values addObject:@" "];
		[keys addObject:@"ID "];
		[values addObject:@" "];
		[keys addObject:@"Location "];
		[values addObject:@" "];
	}

	[infoTable reloadData];

	infoTable.needsDisplay = YES;
}



#pragma mark - NSTableView Delegate and DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return (keys != nil ? keys.count : 0);
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return NO;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier compare:@"infoheadcolumn"] == NSOrderedSame)
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:@"infoheadcell" owner:nil];

		if (cell != nil) cell.textField.stringValue = [keys objectAtIndex:row];
		return cell;
	}
	else if ([tableColumn.identifier compare:@"infotextcolumn"] == NSOrderedSame)
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:@"infotextcell" owner:nil];

		if (cell != nil)
		{
			NSString *string = [values objectAtIndex:row];
			CGFloat width = [self widthOfString:string];
			CGFloat height = width > 280 ? ((width / 280) + 1) * 17 : 17;
			[cell setFrameSize:NSMakeSize(280, height)];
			cell.textField.preferredMaxLayoutWidth = 280;
			cell.textField.stringValue = string;
		}

		return cell;
	}

	return nil;
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSString *value = [values objectAtIndex:row];
	NSString *key = [keys objectAtIndex:row];
	CGFloat width = [self widthOfString:value];

	if (width > 280)
	{
		CGFloat height = ((width / 280) + 1) * 17;
		return height;
	}

	if (value.length < 2 && key.length < 2) return 10;

	return 17;
}



#pragma mark - Path Manipulation Methods

- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath
{
	// Expand a relative path that is relative to the base path to an absolute path

	NSString *absolutePath = [basePath stringByAppendingFormat:@"/%@", relativePath];
	absolutePath = [absolutePath stringByStandardizingPath];
	return absolutePath;
}



- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath
{
	// This method takes an absolute location ('filePath') and returns a location relative
	// to another location ('basePath'). Typically, this is the path to the host
	// project

	basePath = [basePath stringByStandardizingPath];
	filePath = [filePath stringByStandardizingPath];

	NSString *theFilePath = filePath;

	NSInteger nf = [self numberOfFoldersInPath:theFilePath];
	NSInteger nb = [self numberOfFoldersInPath:basePath];

	if (nf > nb) // theFilePath.length > basePath.length
	{
		// The file path is longer than the base path
		NSRange r = [theFilePath rangeOfString:basePath];

		if (r.location != NSNotFound)
		{
			// The file path contains the base path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// contains
			// '/Users/smitty/documents/github/squinter'

			theFilePath = [theFilePath substringFromIndex:r.length];
			//theFilePath = [theFilePath stringByAppendingFormat:@"/%@", theFileName];
		}
		else
		{
			// The file path does not contain the base path, eg.
			// '/Users/smitty/downloads'
			// doesn't contain
			// '/Users/smitty/documents/github/squinter'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}
	else if (nf < nb) // theFilePath.length < basePath.length
	{
		NSRange r = [basePath rangeOfString:theFilePath];

		if (r.location != NSNotFound)
		{
			// The base path contains the file path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// contains
			// '/Users/smitty/documents'

			theFilePath = [basePath substringFromIndex:r.length];
			NSArray *filePathParts = [theFilePath componentsSeparatedByString:@"/"];
			//theFilePath = theFileName;

			// Add in '../' for each directory in the base path but not in the file path

			for (NSInteger i = 0 ; i < filePathParts.count - 1 ; ++i)
			{
				theFilePath = [@"../" stringByAppendingString:theFilePath];
			}
		}
		else
		{
			// The base path doesn't contains the file path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// doesn't contain
			// '/Users/smitty/downloads'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}
	else
	{
		// The two paths are the same length

		if ([theFilePath compare:basePath] == NSOrderedSame)
		{
			// The file path and the base patch are the same, eg.
			// '/Users/smitty/documents/github/squinter'
			// matches
			// '/Users/smitty/documents/github/squinter'

			theFilePath = @"";
		}
		else
		{
			// The file path and the base patch are not the same, eg.
			// '/Users/smitty/documents/github/squinter'
			// matches
			// '/Users/smitty/downloads/archive/nofiles'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}

	return theFilePath;
}



- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath
{
	NSInteger location = -1;
	NSArray *fileParts = [filePath componentsSeparatedByString:@"/"];
	NSArray *baseParts = [basePath componentsSeparatedByString:@"/"];

	for (NSUInteger i = 0 ; i < fileParts.count ; ++i)
	{
		// Compare the two paths, directory by directory, starting at the left
		// then break when they no longer match

		NSString *filePart = [fileParts objectAtIndex:i];
		NSString *basePart = [baseParts objectAtIndex:i];

		if ([filePart compare:basePart] != NSOrderedSame)
		{
			location = i;
			break;
		}
	}

	NSString *path = @"";

	for (NSUInteger i = location ; i < baseParts.count ; ++i)
	{
		// Add a '../' for every non-matching base path directory

		path = [path stringByAppendingString:@"../"];
	}

	for (NSUInteger i = location ; i < fileParts.count ; ++i)
	{
		// Then add the actual file path directries from the no matching part

		path = [path stringByAppendingFormat:@"%@/", [fileParts objectAtIndex:i]];
	}

	// Remove the final /

	path = [path substringToIndex:(path.length - 1)];

	return path;
}



- (NSInteger)numberOfFoldersInPath:(NSString *)path
{
	NSArray *parts = [path componentsSeparatedByString:@"/"];
	return (parts.count - 1);
}



- (CGFloat)widthOfString:(NSString *)string
{
	NSFont *font = [NSFont fontWithName:@"System Bold" size:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


@end
