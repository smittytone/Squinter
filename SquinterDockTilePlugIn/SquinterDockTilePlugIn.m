
//  Created by Tony Smith on 17/05/2017.
//  Copyright © 2017 Tony Smith. All rights reserved.


#import "SquinterDockTilePlugIn.h"


@implementation SquinterDockTilePlugIn



- (NSMenu *)dockMenu
{
	if (dockMenu == nil)
	{
		// Create the menu

		dockMenu = [[NSMenu alloc] init];
		dockMenu.autoenablesItems = NO;
	}
	else
	{
		[dockMenu removeAllItems];
	}

	NSMenuItem *item = nil;
	NSArray *array = nil;
	wd = nil;

	// Synchronize with Squinter's prefs

	CFPreferencesAppSynchronize(CFSTR("com.bps.Squinter"));

	// Read in the saved list of recent files, casting to an NSArray

	array = CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("com.bps.squinter.recentFiles"), CFSTR("com.bps.Squinter")));
	wd = CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("com.bps.squinter.workingdirectory"), CFSTR("com.bps.Squinter")));

	// NOTE These menu items REQUIRE their target property to be set

	if (array != nil && array.count > 0)
	{
		// Load and display recent .squirrelproj files

		item = [[NSMenuItem alloc] initWithTitle:@"Recent Projects"
										  action:@selector(dockMenuOpenRecent:)
								   keyEquivalent:@""];
		item.target = self;
		item.enabled = NO;
		item.tag = -1;
		[dockMenu addItem:item];

		for (NSDictionary *file in array)
		{
			item = [[NSMenuItem alloc] initWithTitle:[file objectForKey:@"name"]
											  action:@selector(dockMenuOpenRecent:)
									   keyEquivalent:@""];
			item.representedObject = file;
			item.image = [NSImage imageNamed:@"docpic.png"];
			item.target = self;
			item.tag = -1;
			[dockMenu addItem:item];
		}

		item = [NSMenuItem separatorItem];
		[dockMenu addItem:item];
	}

	// Add a link to the current working directory

	item = [[NSMenuItem alloc] initWithTitle:@"Working Directory" action:@selector(dockMenuAction:) keyEquivalent:@""];
	item.tag = 99;
	item.target = self;
	[dockMenu addItem:item];

	item = [NSMenuItem separatorItem];
	[dockMenu addItem:item];

	// Add links to Squinter, Squirrel and EI information

	item = [[NSMenuItem alloc] initWithTitle:@"Squinter Information" action:@selector(dockMenuAction:) keyEquivalent:@""];
	item.tag = 1;
	item.target = self;
	[dockMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:@"Electric Imp Dev Center" action:@selector(dockMenuAction:) keyEquivalent:@""];
	item.tag = 2;
	item.target = self;
	[dockMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:@"The Electric Imp Forum" action:@selector(dockMenuAction:) keyEquivalent:@""];
	item.tag = 3;
	item.target = self;
	[dockMenu addItem:item];
	
	return dockMenu;
}



- (void)dockMenuAction:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;

	if (item.tag != -1)
	{
		// Launch the website based on the selected menu item - indicated by its tag

		switch(item.tag)
		{
			case 1:
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/version2/"]];
				break;

			case 2:
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://electricimp.com/docs/"]];
				break;

			case 3:
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://forums.electricimp.com/"]];
				break;

			default:
				[[NSWorkspace sharedWorkspace] openFile:wd withApplication:nil andDeactivate:YES];
		}
	}
}



- (void)dockMenuOpenRecent:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;

	if (item.representedObject != nil)
	{
		NSDictionary *data = item.representedObject;
		NSData *bookmark = [data valueForKey:@"bookmark"];

		// Check that the file exists at the recoreded location
		// We do this here (it will be checked in 'openSquirrelProject:' too) so that we can update the
		// recent files list and menu if the file has gone missing

		NSURL *url = [self urlForBookmark:bookmark];

		// Open the file at the path provided by the passed-in menu's representedObject

		[[NSWorkspace sharedWorkspace] openFile:url.path];
	}
}



- (void)setDockTile:(NSDockTile *)dockTile
{
	// This has to be implemented to avoid a warning, but doesn't have to do anything
	// as we're not (yet) changing the look of the icon
}



- (NSURL *)urlForBookmark:(NSData *)bookmark
{
	NSError *error = nil;
	BOOL isStale = NO;
	NSURL *url = [NSURL URLByResolvingBookmarkData: bookmark
										   options: NSURLBookmarkResolutionWithoutUI
									 relativeToURL: nil
							   bookmarkDataIsStale: &isStale
											 error: &error];

	// There was an error, so return 'nil' as a warning

	if (error != nil) return nil;
	stale = isStale;
	return url;
}



@end
