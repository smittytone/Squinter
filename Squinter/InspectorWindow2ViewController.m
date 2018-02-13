

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import "InspectorWindow2ViewController.h"

@interface InspectorWindow2ViewController ()

@end

@implementation InspectorWindow2ViewController

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
	
	[self setProject:nil];
	[self setDevice:nil];
	
	nswsw = NSWorkspace.sharedWorkspace;
	
	// Stop the HUD panel from floating above all windows
	
	NSPanel *panel = (NSPanel *)self.view.window;
	[panel setFloatingPanel:NO];
	
	// Hide the tables when there's nothing to show
	
	deviceOutlineView.hidden = YES;
	deviceOutlineView.delegate = self;
	//deviceOutlineView.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
	
	// Set up the tabs
	
	panelSelector.selectedSegment = 0;
	tabIndex = 0;
	field.stringValue = @"No project selected";
	field.hidden = NO;
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
	
	[self.view.window setFrame:wframe display:NO];
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
	InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;
	NSInteger row = cellView.index;
	NSString *path = [projectValues objectAtIndex:row];
	
	if (row < 5)
	{
		// This will be the location of the project file, which is already open,
		// so just reveal it in Finder
		
		[nswsw selectFile:[NSString stringWithFormat:@"%@/%@", project.path, project.filename] inFileViewerRootedAtPath:project.path];
		return;
	}
	
	// Open the file
	
	[nswsw openFile:path];
}



- (IBAction)goToURL:(id)sender
{
	// Link buttons in the Inspector panel come here when clicked
	
	NSButton *linkButton = (NSButton *)sender;
	InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;
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
	
	// If project does equal nil, we ignore the content creation section
	// and reload the table with empty data
	
	if (project != nil)
	{
		deviceOutlineView.hidden = NO;
		field.hidden = YES;
		
		[projectKeys addObject:@"Project Info"];
		[projectValues addObject:@""];
		
		[projectKeys addObject:@"Project Name"];
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
		
		[projectKeys addObject:@" "];
		[projectValues addObject:@" "];
		[projectKeys addObject:@"Device Group Info"];
		[projectValues addObject:@""];
		
		if (project.devicegroups != nil && project.devicegroups.count > 0)
		{
			NSUInteger dgcount = 1;
			
			for (Devicegroup *devicegroup in project.devicegroups)
			{
				if (dgcount > 1)
				{
					[projectKeys addObject:@" "];
					[projectValues addObject:@" "];
				}
				
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
				[projectValues addObject:[self convertDevicegroupType:devicegroup.type :NO]];
				
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
						if (modcount > 0)
						{
							[projectKeys addObject:@" "];
							[projectValues addObject:@" "];
						}
						
						NSString *typeString = [model.type compare:@"agent"] == NSOrderedSame ? @"Agent" : @"Device";
						
						if ([typeString compare:@"Agent"] == NSOrderedSame)
						{
							[projectKeys addObject:@"Agent Code Info"];
						}
						else
						{
							[projectKeys addObject:@"Device Code Info"];
						}
						
						[projectValues addObject:@""];
						
						[projectKeys addObject:[NSString stringWithFormat:@"%@ Code File ", typeString]];
						[projectValues addObject:model.filename];
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
	
	tabIndex = 0;
	panelSelector.selectedSegment = 0;
	
	reloadCounter = 0;
	[deviceOutlineView reloadData];
	[deviceOutlineView setNeedsDisplay];
}



- (void)setDevice:(NSMutableDictionary *)aDevice
{
	// This is the 'device' property setter, which we use to populate
	// the two content arrays and trigger regeneration of the table view
	
	device = aDevice;
	
	[deviceKeys removeAllObjects];
	[deviceValues removeAllObjects];
	
	// If device does equal nil, we ignore the content creation section
	// and reload the table with empty data
	
	if (device != nil)
	{
		deviceOutlineView.hidden = NO;
		field.hidden = YES;
		
		[deviceKeys addObject:@"Device Info"];
		[deviceValues addObject:@""];
		[deviceKeys addObject:@"Name "];
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
		[deviceValues addObject:@""];
		[deviceKeys addObject:@"Network Info"];
		[deviceValues addObject:@""];
		
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
			NSNumber *ip = [device valueForKeyPath:@"attributes.ip_address"];
			if ((NSNull *)ip == [NSNull null]) ip = nil;
			[deviceValues addObject:(ip != nil ? ip : @"Unknown")];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}
		
		[deviceKeys addObject:@" "];
		[deviceValues addObject:@" "];
		[deviceKeys addObject:@"Agent Info"];
		[deviceValues addObject:@""];
		
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
		[deviceKeys addObject:@"BlinkUp Info"];
		[deviceValues addObject:@""];
		
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
		[deviceKeys addObject:@"Device Group Info"];
		[deviceValues addObject:@""];
		
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
	
	tabIndex = 1;
	panelSelector.selectedSegment = 1;
	
	reloadCounter = 0;
	[deviceOutlineView reloadData];
	[deviceOutlineView setNeedsDisplay];
}



#pragma mark - Misc Methods


- (void)setTab:(NSUInteger)aTab
{
	// This is the 'tabIndex' setter method, which we trap in order
	// to trigger a switch to the implicitly requested tab
	
	if (aTab > panelSelector.segmentCount) return;
	
	panelSelector.selectedSegment = aTab;
	[self switchTable:nil];
}



- (IBAction)switchTable:(id)sender
{
	NSInteger aTab = panelSelector.selectedSegment;
	tabIndex = aTab;
	
	if (tabIndex == 0)
	{
		if (projectKeys.count == 0)
		{
			deviceOutlineView.hidden = YES;
			field.stringValue = @"No project selected";
			field.hidden = NO;
		}
		else
		{
			field.hidden = YES;
			deviceOutlineView.hidden = NO;
		}
	}
	else
	{
		if (deviceKeys.count == 0)
		{
			deviceOutlineView.hidden = YES;
			field.stringValue = @"No device selected";
			field.hidden = NO;
		}
		else
		{
			field.hidden = YES;
			deviceOutlineView.hidden = NO;
		}
	}
	
	reloadCounter = 0;
	[deviceOutlineView reloadData];
	[deviceOutlineView setNeedsDisplay];
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
	if ([value containsString:@"https:"]) return YES;
	return NO;
}



#pragma mark - NSOutlineView Delegate and DataSource Methods


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return NO;
}



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return NO;
}



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return (item == nil ? (tabIndex == 0 ? projectKeys.count : deviceKeys.count) : 0);
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	//return (tabIndex == 0 ? [projectKeys objectAtIndex:index] : [deviceKeys objectAtIndex:index]);
	return [NSNumber numberWithInteger:index];
}



- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
	return (panelSelector.selectedSegment == 1 ? @"DD" : @"PP");
}



- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(nonnull id)item
{
	id cellView = nil;
	
	//NSString *title = (NSString *)item;
	NSNumber *num = (NSNumber *)item;
	NSInteger index = num.integerValue;
	
	NSInteger count = 0;
	NSMutableArray *valueArray = nil;
	NSMutableArray *keyArray = nil;
	
	if (panelSelector.selectedSegment == 1)
	{
		keyArray = deviceKeys;
		valueArray = deviceValues;
		count = deviceKeys.count;
	}
	else
	{
		keyArray = projectKeys;
		valueArray = projectValues;
		count = projectKeys.count;
	}
	
	
	NSString *key = [keyArray objectAtIndex:index];
	NSString *value = [valueArray objectAtIndex:index];
			
	if (value.length == 0)
	{
		// Header
		
		NSTableCellView *cv = [outlineView makeViewWithIdentifier:@"header.cell" owner:self];
		cv.textField.stringValue = [key uppercaseString];
		cellView = cv;
	}
	else
	{
		// Data row
		
		InspectorDataCellView *cv = [outlineView makeViewWithIdentifier:@"data.cell" owner:self];
		cv.title.stringValue = key;
		cv.data.stringValue = value;
		
		if (panelSelector.selectedSegment == 1)
		{
			if ([self isURLRow:index])
			{
				[cv.goToButton setTarget:self];
				[cv.goToButton setAction:@selector(goToURL:)];
				[cv.goToButton setHidden:NO];
				cv.index = index;
			}
			else
			{
				[cv.goToButton setHidden:YES];
			}
		}
		else
		{
			if ([self isLinkRow:index])
			{
				[cv.goToButton setTarget:self];
				[cv.goToButton setAction:@selector(link:)];
				[cv.goToButton setHidden:NO];
				cv.index = index;
			}
			else
			{
				[cv.goToButton setHidden:YES];
			}
		}
		
		
		cellView = cv;
	}
	
	/*
	for (NSUInteger i = reloadCounter ; i < count ; i++)
	{
		NSString *key = [keyArray objectAtIndex:i];
		
		if ([key compare:title] == NSOrderedSame)
		{
			reloadCounter = i;
			NSString *value = [valueArray objectAtIndex:i];
			
			if (value.length == 0)
			{
				// Header
				
				NSTableCellView *cv = [outlineView makeViewWithIdentifier:@"header.cell" owner:self];
				cv.textField.stringValue = [key uppercaseString];
				cellView = cv;
			}
			else
			{
				// Data row
				
				InspectorDataCellView *cv = [outlineView makeViewWithIdentifier:@"data.cell" owner:self];
				cv.title.stringValue = key;
				cv.data.stringValue = value;
				
				if (panelSelector.selectedSegment == 1)
				{
					if ([self isURLRow:i])
					{
						[cv.goToButton setTarget:self];
						[cv.goToButton setAction:@selector(goToURL:)];
						[cv.goToButton setHidden:NO];
						cv.index = i;
					}
					else
					{
						[cv.goToButton setHidden:YES];
					}
				}
				else
				{
					if ([self isLinkRow:i])
					{
						[cv.goToButton setTarget:self];
						[cv.goToButton setAction:@selector(link:)];
						[cv.goToButton setHidden:NO];
						cv.index = i;
					}
					else
					{
						[cv.goToButton setHidden:YES];
					}
				}
				
				
				cellView = cv;
			}
			
			break;
		}
	}
	*/
	
	return cellView;
}



- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	//NSString *title = (NSString *)item;
	NSNumber *num = (NSNumber *)item;
	NSInteger index = num.integerValue;
	
	// Data rows - this is determined by the 'values' - 'keys' and 'links' will only be 14 high
	
	NSMutableArray *valueArray = nil;
	NSMutableArray *keyArray = nil;
	
	if (panelSelector.selectedSegment == 1)
	{
		keyArray = deviceKeys;
		valueArray = deviceValues;
	}
	else
	{
		keyArray = projectKeys;
		valueArray = projectValues;
	}
	
	// Spacer row
	
	NSString *title = [keyArray objectAtIndex:index];
	if (title.length == 1) return 10;
	
	NSString *value = [valueArray objectAtIndex:index];
		
	if (value.length > 2)
	{
		// Get the rendered height of the text - it's drawn into
		// an area as wide as the data column, ie. 172px
		
		CGFloat renderHeight = [self renderedHeightOfString:value];
		
		// 20 is the height of one standard line
		if (renderHeight < 20) renderHeight = 20;
		
		// Calculate the maximum, dealing with a fudge factor
		if (renderHeight > 20 && fmod(renderHeight, 20) > 0)
		{
			renderHeight = renderHeight - fmod(renderHeight, 20) + 20;
		}
		
		return renderHeight;
	}
	
	/*
	for (NSUInteger i = reloadCounter ; i < keyArray.count ; i++)
	{
		NSString *key = [keyArray objectAtIndex:i];
		
		if ([key compare:title] == NSOrderedSame)
		{
			reloadCounter = i;
			if (i == keyArray.count - 1) reloadCounter = 0;
			NSString *value = [valueArray objectAtIndex:i];
			
			if (value.length > 2)
			{
				// Get the rendered height of the text - it's drawn into
				// an area as wide as the data column, ie. 172px
				
				CGFloat renderHeight = [self renderedHeightOfString:value];
				
				// 20 is the height of one standard line
				if (renderHeight < 20) renderHeight = 20;
				
				// Calculate the maximum, dealing with a fudge factor
				if (renderHeight > 20 && fmod(renderHeight, 20) > 0)
				{
					renderHeight = renderHeight - fmod(renderHeight, 20) + 20;
				}
				
				return renderHeight;
			}
		}
	}
	*/
	
	return 20;
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
	NSFont *font = [NSFont systemFontOfSize:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	NSLog(@"  %f - %@", [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width, string);
	return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}



- (CGFloat)renderedHeightOfString:(NSString *)string
{
	NSTextField *nstf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 172, 400)];
	nstf.cell.wraps = YES;
	nstf.cell.lineBreakMode = NSLineBreakByWordWrapping; //NSLineBreakByCharWrapping;
	NSFont *font = [NSFont systemFontOfSize:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	nstf.attributedStringValue = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	return [nstf.cell cellSizeForBounds:nstf.bounds].height;
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
	NSArray *dgtypes = @[ @"production_devicegroup", @"factoryfixture_devicegroup", @"development_devicegroup",
						  @"pre_factoryfixture_devicegroup", @"pre_production_devicegroup"];
	NSArray *dgnames = @[ @"Production", @"Factory Fixture", @"Development", @"Factory Test", @"Production Test"];
	
	for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
	{
		NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];
		
		if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
	}
	
	if (!back) return @"Unknown";
	return @"development_devicegroup";
}


@end

