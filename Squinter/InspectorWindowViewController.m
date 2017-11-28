

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import "InspectorWindowViewController.h"

@interface InspectorWindowViewController ()

@end

@implementation InspectorWindowViewController

@synthesize project, device, products, devices, mainWindowFrame, tabIndex;


#pragma mark - ViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Clear the content arrays:
	// 'projectKeys' are the left column contents
	// 'projectValues' are the right column contents
	// 'deviceKeys' are the left column contents
	// 'deviceValues' are the right column contents

	projectKeys = [[NSMutableArray alloc] init];
	projectValues = [[NSMutableArray alloc] init];
	deviceKeys = [[NSMutableArray alloc] init];
	deviceValues = [[NSMutableArray alloc] init];

	// Set up the main tables

	infoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;
	[self setProject:nil];

	deviceInfoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;
	[self setDevice:nil];

	// Position the window to the right of screen

	mainWindowFrame = [NSScreen mainScreen].frame;

	[self positionWindow];
}



- (void)positionWindow
{
	// Position the window to the right of screen

	NSScreen *ms = [NSScreen mainScreen];
	NSRect wframe = self.view.window.frame;

	if (ms.frame.size.width - (mainWindowFrame.origin.x + mainWindowFrame.size.width) > 340)
	{
		// There's room to put the inspector next to the main window

		wframe.origin.x = mainWindowFrame.origin.x + mainWindowFrame.size.width + 1;
	}
	else
	{
		wframe.origin.x = ms.frame.size.width - 340;
	}

	wframe.origin.y = mainWindowFrame.origin.y + mainWindowFrame.size.height - wframe.size.height;

	[self.view.window setFrame:wframe display:YES];
}



- (void)setProject:(Project *)aProject
{
	// This is the 'project' property setter, which we use to
	// trigger regeneration of the table view

	project = aProject;

	[projectKeys removeAllObjects];
	[projectValues removeAllObjects];

	[projectKeys addObject:@" "];
	[projectValues addObject:@" "];

	// If project does equal nil, we ignore the content creation section
	// and reload the table with empty data

	if (project != nil)
	{
		[projectKeys addObject:@"Project Name "];
		[projectValues addObject:project.name];

		if (project.description != nil && project.description.length > 0)
		{
			[projectKeys addObject:@"Description "];
			[projectValues addObject:project.description];
		}

		[projectKeys addObject:@"ID "];
		[projectValues addObject:(project.pid != nil ? project.pid : @"Undefined")];
		[projectKeys addObject:@"Location "];
		[projectValues addObject:project.path];

		if (project.devicegroups.count > 0)
		{
			NSUInteger dgcount = 1;

			for (Devicegroup *devicegroup in project.devicegroups)
			{
				[projectKeys addObject:@" "];
				[projectValues addObject:@" "];

				[projectKeys addObject:[NSString stringWithFormat:@"Device Group %li ", (long)dgcount]];
				[projectValues addObject:devicegroup.name];
				[projectKeys addObject:@"ID "];

				if (devicegroup.did != nil && devicegroup.did.length > 0)
				{
					[projectValues addObject:devicegroup.did];
				}
				else
				{
					[projectValues addObject:@"Not uploaded"];
				}

				[projectKeys addObject:@"Type "];
				[projectValues addObject:devicegroup.type];

				if (devicegroup.description != nil && devicegroup.description.length > 0)
				{
					[projectKeys addObject:@"Description "];
					[projectValues addObject:devicegroup.description];
				}

				if (devicegroup.models.count > 0)
				{
					NSUInteger modcount = 1;

					for (Model *model in devicegroup.models)
					{
						[projectKeys addObject:@" "];
						[projectValues addObject:@" "];

						[projectKeys addObject:[NSString stringWithFormat:@"Model %li ", (long)modcount]];
						[projectValues addObject:model.filename];
						[projectKeys addObject:@"Type "];
						[projectValues addObject:model.type];
						[projectKeys addObject:@"Location "];
						[projectValues addObject:[self getAbsolutePath:project.path :model.path]];
						[projectKeys addObject:@"Uploaded "];
						[projectValues addObject:model.updated];
						[projectKeys addObject:@"SHA "];
						[projectValues addObject:model.sha];

						if (model.libraries.count > 0)
						{
							NSUInteger libcount = 1;

							for (File *library in model.libraries)
							{
								[projectKeys addObject:@" "];
								[projectValues addObject:@" "];

								[projectKeys addObject:[NSString stringWithFormat:@"Library %li ", (long)libcount]];
								[projectValues addObject:library.filename];
								[projectKeys addObject:@"Location "];
								[projectValues addObject:[self getAbsolutePath:project.path :library.path]];

								++libcount;
							}
						}
						else
						{
							[projectKeys addObject:@"Libraries "];
							[projectValues addObject:@"No local libraries imported"];
						}

						if (model.files.count > 0)
						{
							NSUInteger filecount = 1;

							for (File *file in model.files)
							{
								[projectKeys addObject:@" "];
								[projectValues addObject:@" "];

								[projectKeys addObject:[NSString stringWithFormat:@"File %li ", (long)filecount]];
								[projectValues addObject:file.filename];
								[projectKeys addObject:@"Location "];
								[projectValues addObject:[self getAbsolutePath:project.path :file.path]];

								++filecount;
							}
						}
						else
						{
							[projectKeys addObject:@"Files "];
							[projectValues addObject:@"No local files imported"];
						}

						++modcount;
					}
				}
				++dgcount;
			}
		}
		else
		{
			[projectKeys addObject:@"Device Groups "];
			[projectValues addObject:@"None"];
		}
	}
	else
	{
		// There is no project info to display, so set up
		// some basic projectKeys to show
		[projectKeys addObject:@"Project Name "];
		[projectValues addObject:@" "];
		[projectKeys addObject:@"Description "];
		[projectValues addObject:@" "];
		[projectKeys addObject:@"ID "];
		[projectValues addObject:@" "];
		[projectKeys addObject:@"Location "];
		[projectValues addObject:@" "];
	}

	[infoTable reloadData];

	infoTable.needsDisplay = YES;
}



- (void)setDevice:(NSMutableDictionary *)aDevice
{
	// This is the 'device' property setter, which we use to
	// trigger regeneration of the table view

	device = aDevice;

	[deviceKeys removeAllObjects];
	[deviceValues removeAllObjects];

	[deviceKeys addObject:@" "];
	[deviceValues addObject:@" "];

	// If device does equal nil, we ignore the content creation section
	// and reload the table with empty data

	if (device != nil)
	{
		[deviceKeys addObject:@"Device Name "];
		[deviceValues addObject:[device valueForKeyPath:@"attributes.name"]];
		[deviceKeys addObject:@"ID "];
		[deviceValues addObject:[device objectForKey:@"id"]];


		NSString *type = [device valueForKeyPath:@"attributes.type"];
		if ((NSNull *)type == [NSNull null]) type = nil;
		if (type != nil )
		{
			[deviceKeys addObject:@"Type "];
			[deviceValues addObject:type];
		}

		NSString *version = [device valueForKeyPath:@"attributes.swversion"];
		if ((NSNull *)version == [NSNull null]) version = nil;
		[deviceKeys addObject:@"impOS "];
		if (version != nil )
		{
			NSArray *parts = [version componentsSeparatedByString:@" - "];
			parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"-"];

			[deviceValues addObject:[parts objectAtIndex:1]];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}

		NSNumber *number = [device valueForKeyPath:@"attributes.free_memory"];
		if ((NSNull *)number == [NSNull null]) number = nil;
		[deviceKeys addObject:@"Free RAM "];
		[deviceValues addObject:(number != nil ? [NSString stringWithFormat:@"%@KB", number] : @"Unknown")];

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Network Info "];
		[deviceValues addObject:@" "];

		NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
		mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
		[deviceKeys addObject:@"MAC "];
		[deviceValues addObject:mac];

		NSNumber *boolean = [device valueForKeyPath:@"attributes.device_online"];
		NSString *string = (boolean.boolValue) ? @"Online" : @"Offline";
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:string];
		[deviceKeys addObject:@"IP "];

		if ([string compare:@"Online"] == NSOrderedSame)
		{
			[deviceValues addObject:[device valueForKeyPath:@"attributes.ip_address"]];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Agent Info "];
		[deviceValues addObject:@" "];

		boolean = [device valueForKeyPath:@"attributes.agent_running"];
		string = (boolean.boolValue) ? @"Online" : @"Offline";
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:string];

		string = [device valueForKeyPath:@"attributes.agent_id"];
		if ((NSNull *)string == [NSNull null]) string = nil;
		[deviceKeys addObject:@"Agent URL "];
		[deviceValues addObject:(string != nil ? string : @"No agent")];

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"BlinkUp Info "];
		[deviceValues addObject:@" "];

		NSString *date = [device valueForKeyPath:@"attributes.last_enrolled_at"];
		if ((NSNull *)date == [NSNull null]) date = nil;
		[deviceKeys addObject:@"Last Enrolled "];
		[deviceValues addObject:(date != nil ? date : @"Unknown")];

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Device Group "];
		[deviceValues addObject:@" "];

		NSDictionary *dg = [device valueForKeyPath:@"relationships.devicegroup"];
		if ((NSNull *)dg == [NSNull null]) dg = nil;
		if (dg != nil)
		{
			NSString *dgid = [dg objectForKey:@"id"];
			[deviceKeys addObject:@"ID "];
			[deviceValues addObject:(dgid != nil ? dgid : @"Unassigned")];
		}
	}
	else
	{
		// There is no project info to display, so set up
		// some basic projectKeys to show
		[deviceKeys addObject:@"Device Name "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"ID "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Type "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"impOS "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Free RAM "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Network Info "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"MAC "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"IP "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Agent Info "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Agent URL "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"BlinkUp Info "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Last Enrolled "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Device Group "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"ID "];
		[deviceValues addObject:@" "];
	}

	[deviceInfoTable reloadData];

	deviceInfoTable.needsDisplay = YES;
}



- (void)setTab:(NSUInteger)aTab
{
	if (aTab > inspectorTabView.numberOfTabViewItems) return;

	tabIndex = aTab;
	[inspectorTabView selectTabViewItemAtIndex:tabIndex];
}



#pragma mark - NSTableView Delegate and DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if (tableView == infoTable)
	{
		return (projectKeys != nil ? projectKeys.count : 0);
	}
	else
	{
		return (deviceKeys != nil ? deviceKeys.count : 0);
	}
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return NO;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier compare:@"infoheadcolumn"] == NSOrderedSame || [tableColumn.identifier compare:@"deviceinfoheadcolumn"] == NSOrderedSame)
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:(tableView == infoTable ? @"infoheadcell" : @"deviceinfoheadcell") owner:nil];

		if (cell != nil) cell.textField.stringValue = tableView == infoTable ? [projectKeys objectAtIndex:row] : [deviceKeys objectAtIndex:row];

		return cell;
	}
	else if ([tableColumn.identifier compare:@"infotextcolumn"] == NSOrderedSame || [tableColumn.identifier compare:@"deviceinfotextcolumn"] == NSOrderedSame)
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:(tableView == infoTable ? @"infotextcell" : @"deviceinfotextcell") owner:nil];

		if (cell != nil)
		{
			NSString *string = tableView == infoTable ? [projectValues objectAtIndex:row] : [deviceValues objectAtIndex:row];
			CGFloat width = string.length > 0 ? [self widthOfString:string] : 10.0;
			CGFloat height = width > 204 ? ((width / 204) + 1) * 14.0: 14.0;
			[cell setFrameSize:NSMakeSize(204, height)];
			//cell.textField.preferredMaxLayoutWidth = 204;
			cell.textField.stringValue = string;
		}

		return cell;
	}

	return nil;
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSString *value = tableView == infoTable ? [projectValues objectAtIndex:row] : [deviceValues objectAtIndex:row];
	NSString *key = tableView == infoTable ? [projectKeys objectAtIndex:row] : [deviceKeys objectAtIndex:row];

	if (value.length < 2 && key.length < 2) return 10;

	CGFloat width = value.length > 0 ? [self widthOfString:value] : 10.0;
	CGFloat height = width > 204 ? ((width / 204) + 1) * 17.0: 17.0;
	return height;
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
	NSFont *font = [NSFont fontWithName:@"System" size:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


@end
