

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import "InspectorWindowViewController.h"

@interface InspectorWindowViewController ()

@end

@implementation InspectorWindowViewController

@synthesize project, products, devices;


- (void)viewDidLoad
{
    [super viewDidLoad];

	keys = [[NSMutableArray alloc] init];
	values = [[NSMutableArray alloc] init];

	// self.view.window.backgroundColor = [NSColor colorWithWhite:0.0 alpha:7.0];
	// self.view.window.alphaValue = 1.0;
	// self.view.window.opaque = YES;

	infoTable.rowSizeStyle = NSTableViewRowSizeStyleCustom;

	NSScreen *ms = [NSScreen mainScreen];
	NSRect wframe = self.view.window.frame;
	wframe.origin.x = ms.frame.size.width - 420;
	wframe.origin.y = (ms.frame.size.height - wframe.size.height) / 2;
	[self.view.window setFrame:wframe display:YES];
}


- (void)setProject:(Project *)aProject
{
	project = aProject;

	[keys removeAllObjects];
	[values removeAllObjects];
	[keys addObject:@" "];
	[values addObject:@" "];

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

	[infoTable reloadData];

	infoTable.needsDisplay = YES;
}



- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath
{
	// Expand a relative path that is relative to the base path to an absolute path

	NSString *absolutePath = [basePath stringByAppendingFormat:@"/%@", relativePath];
	absolutePath = [absolutePath stringByStandardizingPath];
	return absolutePath;
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

		if (cell != nil) {
			//cell.textField.maximumNumberOfLines = 10;
			cell.textField.preferredMaxLayoutWidth = 280;
			// cell.textField.stringValue = [values objectAtIndex:row];

			NSString *string = [values objectAtIndex:row];
			CGFloat width = [self widthOfString:string];
			CGFloat height = width > 280 ? ((width / 280) + 1) * 17 : 17;
			[cell setFrameSize:NSMakeSize(280, height)];
			cell.textField.stringValue = string;
		}

		return cell;
	}

	return nil;
}



- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSString *string = [values objectAtIndex:row];
	CGFloat width = [self widthOfString:string];

	if (width > 280)
	{
		CGFloat height = ((width / 280) + 1) * 17;
		return height;
	}

	if (width < 5) return 10;

	return 17;
}



- (CGFloat)widthOfString:(NSString *)string
{
	NSFont *font = [NSFont fontWithName:@"System Bold" size:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


@end
