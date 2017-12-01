

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

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillBecomeActive)
												 name:NSApplicationWillBecomeActiveNotification
											   object:nil];

	// Clear the content arrays:
	// 'projectKeys' are the left column contents
	// 'projectValues' are the right column contents
	// 'deviceKeys' are the left column contents
	// 'deviceValues' are the middle column contents

	projectKeys = [[NSMutableArray alloc] init];
	projectValues = [[NSMutableArray alloc] init];
	deviceKeys = [[NSMutableArray alloc] init];
	deviceValues = [[NSMutableArray alloc] init];

	// Set up date handling

	inLogDef = [[NSDateFormatter alloc] init];
	inLogDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ";
	inLogDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

	outLogDef = [[NSDateFormatter alloc] init];
	outLogDef.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZZ";
	outLogDef.timeZone = [NSTimeZone localTimeZone];

	// Set up the main tables

	infoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;
	[self setProject:nil];

	deviceInfoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;
	[self setDevice:nil];

#ifdef DEBUG
	//infoTable.gridStyleMask = NSTableViewSolidVerticalGridLineMask  | NSTableViewSolidHorizontalGridLineMask;
	//deviceInfoTable.gridStyleMask = NSTableViewSolidVerticalGridLineMask  | NSTableViewSolidHorizontalGridLineMask;
#endif

	nswsw = NSWorkspace.sharedWorkspace;

	// Stop the HUD panel from floating above all windows

	NSPanel *panel = (NSPanel *)self.view.window;
	[panel setFloatingPanel:NO];

	// Position the window to the right of screen

	mainWindowFrame = [NSScreen mainScreen].frame;

	[self positionWindow];

	// Hide the tables when there's nothing to show

	infoTable.hidden = YES;
	deviceInfoTable.hidden = YES;
	field.stringValue = @"No project selected";

	// Set up the tabs

	[inspectorTabView selectTabViewItemAtIndex:1];
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
		// No room next to the main window, so put the panel above it

		wframe.origin.x = ms.frame.size.width - 340;
	}

	wframe.origin.y = mainWindowFrame.origin.y + mainWindowFrame.size.height - wframe.size.height;

	[self.view.window setFrame:wframe display:YES];
}



- (void)appWillBecomeActive
{
	if (self.view.window.isVisible) [self.view.window makeKeyAndOrderFront:self];
}



#pragma mark - Button Action Methods


- (IBAction)link:(id)sender
{
	// Link buttons in the Inspector panel come here when clicked

	NSButton *linkButton = (NSButton *)sender;
	InspectorButtonTableCellView *cellView = (InspectorButtonTableCellView *)linkButton.superview;
	NSInteger row = cellView.index;
	NSString *path = [projectValues objectAtIndex:row];

	if (row < 5)
	{
		// This will be the location of the project file, which is already open,
		// so just reveal it in Finder

		[nswsw selectFile:[NSString stringWithFormat:@"%@/%@", project.path, project.filename] inFileViewerRootedAtPath:project.path];
		return;
	}

	for (NSInteger i = row ; i >= 0 ; --i)
	{
		// Step back up the content array until we get the object whose location button has
		// been clicked. It will be a model, a library or a file. This gives us the filename
		// and we can construct the path to it and use that to open the file

		NSString *key = [projectKeys objectAtIndex:i];

		if ([key containsString:@"Model"] || [key containsString:@"Library"] || [key containsString:@"File"])
		{
			path = [path stringByAppendingFormat:@"/%@", [projectValues objectAtIndex:i]];
			[nswsw openFile:path];
			break;
		}
	}
}



- (IBAction)goToURL:(id)sender
{
	// Link buttons in the Inspector panel come here when clicked

	NSButton *linkButton = (NSButton *)sender;
	InspectorButtonTableCellView *cellView = (InspectorButtonTableCellView *)linkButton.superview;
	NSInteger row = cellView.index;

	// Open the URL
	
	[nswsw openURL:[NSURL URLWithString:[deviceValues objectAtIndex:row]]];
}



#pragma mark - Data Setter Methods


- (void)setProject:(Project *)aProject
{
	// This is the 'project' property setter, which we use to populate
	// the two content arrays and trigger regeneration of the table view

	project = aProject;

	[projectKeys removeAllObjects];
	[projectValues removeAllObjects];

	[projectKeys addObject:@" "];
	[projectValues addObject:@" "];

	// If project does equal nil, we ignore the content creation section
	// and reload the table with empty data

	if (project != nil)
	{
		infoTable.hidden = NO;
		field.hidden = YES;

		[projectKeys addObject:@"Project Name "];
		[projectValues addObject:project.name];

		if (project.description != nil && project.description.length > 0)
		{
			[projectKeys addObject:@"Description "];
			[projectValues addObject:project.description];
		}

		if (products == nil || products.count == 0 || project.pid == nil)
		{
			[projectKeys addObject:@"ID "];
			[projectValues addObject:(project.pid != nil ? project.pid : @"Project not linked to a product")];
		}
		else
		{
			for (NSDictionary *product in products)
			{
				NSString *apid = [product objectForKey:@"id"];

				if ([apid compare:project.pid] == NSOrderedSame)
				{
					[projectKeys addObject:@"Product "];
					[projectValues addObject:[product valueForKeyPath:@"attributes.name"]];
				}
			}
		}

		[projectKeys addObject:@"Path "];

		if (project.path != nil)
		{
			[projectValues addObject:[NSString stringWithFormat:@"%@/%@", project.path, project.filename]];
		}
		else
		{
			[projectValues addObject:@"Project has not yet been saved"];
		}

		if (project.devicegroups != nil && project.devicegroups.count > 0)
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

						[projectKeys addObject:[NSString stringWithFormat:@"Source File %li ", (long)modcount]];
						[projectValues addObject:model.filename];
						[projectKeys addObject:@"Type "];
						[projectValues addObject:model.type];
						[projectKeys addObject:@"Path "];
						[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :model.path], model.filename]];

						[projectKeys addObject:@"Uploaded "];
						NSString *date = model.updated;

						if (date != nil && date.length > 0)
						{
							date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
							date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
							date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
							[projectValues addObject:date];
						}
						else
						{
							[projectValues addObject:@"No code uploaded"];
						}

						[projectKeys addObject:@"SHA "];
						[projectValues addObject:(model.sha != nil && model.sha.length > 0 ? model.sha : @"No code uploaded")];

						if (model.libraries != nil && model.libraries.count > 0)
						{
							NSUInteger libcount = 1;

							for (File *library in model.libraries)
							{
								[projectKeys addObject:[NSString stringWithFormat:@"Library %li ", (long)libcount]];
								[projectValues addObject:library.filename];
								[projectKeys addObject:@"Path "];
								[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :library.path], library.filename]];

								++libcount;
							}
						}
						else
						{
							[projectKeys addObject:@"Libraries "];
							[projectValues addObject:@"No local libraries imported"];
						}

						if (model.files != nil && model.files.count > 0)
						{
							NSUInteger filecount = 1;

							for (File *file in model.files)
							{
								[projectKeys addObject:[NSString stringWithFormat:@"File %li ", (long)filecount]];
								[projectValues addObject:file.filename];
								[projectKeys addObject:@"Path "];
								[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :file.path], file.filename]];

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

	[infoTable reloadData];

	infoTable.needsDisplay = YES;
}



- (void)setDevice:(NSMutableDictionary *)aDevice
{
	// This is the 'device' property setter, which we use to populate
	// the two content arrays and trigger regeneration of the table view

	device = aDevice;

	[deviceKeys removeAllObjects];
	[deviceValues removeAllObjects];

	[deviceKeys addObject:@" "];
	[deviceValues addObject:@" "];

	// If device does equal nil, we ignore the content creation section
	// and reload the table with empty data

	if (device != nil)
	{
		deviceInfoTable.hidden = NO;
		field.hidden = YES;

		[deviceKeys addObject:@"Device Name "];
		[deviceValues addObject:[device valueForKeyPath:@"attributes.name"]];
		[deviceKeys addObject:@"ID "];
		[deviceValues addObject:[device objectForKey:@"id"]];


		NSString *type = [device valueForKeyPath:@"attributes.imp_type"];
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
		[deviceValues addObject:(string != nil ? [@"https://agent.electricimp.com/" stringByAppendingString:string] : @"No agent")];

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"BlinkUp Info "];
		[deviceValues addObject:@" "];

		NSString *date = [device valueForKeyPath:@"attributes.last_enrolled_at"];
		if ((NSNull *)date == [NSNull null]) date = nil;
		[deviceKeys addObject:@"Last Enrolled "];

		if (date != nil)
		{
			date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
			date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
			[deviceValues addObject:date];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}

		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Device Group "];
		[deviceValues addObject:@" "];

		NSDictionary *dg = [device valueForKeyPath:@"relationships.devicegroup"];
		if ((NSNull *)dg == [NSNull null]) dg = nil;
		if (dg != nil)
		{
			NSString *dgid = [dg objectForKey:@"id"];
			BOOL got = NO;

			for (Devicegroup *devicegroup in project.devicegroups)
			{
				if ([devicegroup.did compare:dgid] == NSOrderedSame)
				{
					[deviceKeys addObject:@"Name "];
					[deviceValues addObject:devicegroup.name];
					got = YES;
					break;
				}
			}

			if (!got)
			{
				[deviceKeys addObject:@"ID "];
				[deviceValues addObject:dgid];
			}
		}
		else
		{
			[deviceKeys addObject:@"ID "];
			[deviceValues addObject:@"Unassigned"];
		}
	}

	[deviceInfoTable reloadData];

	deviceInfoTable.needsDisplay = YES;
}



#pragma mark - Misc Methods


- (void)setTab:(NSUInteger)aTab
{
	// This is the 'tabIndex' setter method, which we trap in order
	// to trigger a switch to the implicitly requested tab

	if (aTab > inspectorTabView.numberOfTabViewItems) return;

	tabIndex = aTab;
	
	[inspectorTabView selectTabViewItemAtIndex:tabIndex];
}



- (BOOL)isLinkRow:(NSInteger)row
{
	// Does the title column of content row being displayed
	// include the word 'path'? If so the content is a link
	// so we return YES so that the table data source method knows
	// which type of NSTableCellView to use

	NSString *key = [projectKeys objectAtIndex:row];
	NSString *value = [projectValues objectAtIndex:row];
	if ([key containsString:@"Path"] && value.length > 1 ) return YES;
	return NO;
}



- (BOOL)isURLRow:(NSInteger)row
{
	// Does the content column of content row being displayed
	// include the word 'http:'? If so the content is a link
	// so we return YES so that the table data source method knows
	// which type of NSTableCellView to use

	NSString *value = [deviceValues objectAtIndex:row];
	if ([value containsString:@"http:"]) return YES;
	return NO;
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
			// Resize the cell to match the row height

			NSString *string = tableView == infoTable ? [projectValues objectAtIndex:row] : [deviceValues objectAtIndex:row];
			CGFloat width = string.length > 0 ? [self widthOfString:string] : 10.0;
			CGFloat height = width > 196 ? ((NSInteger)(width / 196) + 1) * 14.0 : 14.0;
			[cell setFrameSize:NSMakeSize(196, height)];
			cell.textField.stringValue = string;
		}

		return cell;
	}
	else if ([tableColumn.identifier compare:@"deviceinfocheckcolumn"] == NSOrderedSame)
	{
		if ([self isURLRow:row])
		{
			InspectorButtonTableCellView *linkcell = [tableView makeViewWithIdentifier:@"deviceinfocheckcell" owner:nil];

			if (linkcell != nil)
			{
				// Set the button action and save the row number in the cell

				[linkcell.link setAction:@selector(goToURL:)];
				linkcell.index = row;
			}

			return linkcell;
		}
	}
	else if ([tableColumn.identifier compare:@"infocheckcolumn"] == NSOrderedSame)
	{
		if ([self isLinkRow:row])
		{
			InspectorButtonTableCellView *linkcell = [tableView makeViewWithIdentifier:@"infocheckcell" owner:nil];

			if (linkcell != nil)
			{
				// Set the button action and save the row number in the cell

				[linkcell.link setAction:@selector(link:)];
				linkcell.index = row;
			}

			return linkcell;
		}
	}

	return nil;
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSString *value = tableView == infoTable ? [projectValues objectAtIndex:row] : [deviceValues objectAtIndex:row];
	NSString *key = tableView == infoTable ? [projectKeys objectAtIndex:row] : [deviceKeys objectAtIndex:row];

	// Spacer row

	if (value.length < 2 && key.length < 2) return 10;

	// Data rows - this is determined by the 'values' - 'keys' and 'links' will only be 14 high

	if (value.length > 0)
	{
		CGFloat renderHeight = [self altWidthOfString:value];
		renderHeight = (NSInteger)(renderHeight / 14) * 16.0;

		NSInteger stringWidth = ceil([self widthOfString:value]);
		NSInteger stringHeight = stringWidth > 196 ? (NSInteger)(stringWidth / 196) * 16 : 16;

		do
		{
			stringWidth = stringWidth - 196;
		}
		while (stringWidth > 196);

		if (stringWidth < 0) stringWidth = stringWidth * -1;
		if (renderHeight > stringHeight && stringWidth < 6) return stringHeight;

		return renderHeight;
	}

	return 16;
}



#pragma mark - NSTabviewDelegate Methods

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (tabViewItem == projectTabViewItem)
	{
		field.stringValue = @"No project selected";
		field.hidden = project != nil ? YES : NO;
	}

	if (tabViewItem == deviceTabViewItem)
	{
		field.stringValue = @"No device selected";
		field.hidden = device != nil ? YES : NO;
	}
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
	// to another location ('basePath'). Typically, this is the path to the host project

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
		}
		else
		{
			// The file path does not contain the base path, eg.
			// '/Users/smitty/downloads'
			// doesn't contain
			// '/Users/smitty/documents/github/squinter'

			theFilePath = [self getPathDelta:basePath :theFilePath];
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
	NSFont *font = [NSFont fontWithName:@"System" size:10];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}



- (CGFloat)altWidthOfString:(NSString *)string
{
	NSTextField *nstf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 196, 200)];
	nstf.cell.wraps = YES;
	nstf.cell.lineBreakMode = NSLineBreakByWordWrapping;
	nstf.stringValue = string;
	return [nstf.cell cellSizeForBounds:nstf.bounds].height;
}


@end
