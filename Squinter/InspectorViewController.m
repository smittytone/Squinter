

//  Created by Tony Smith
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import "InspectorViewController.h"

@interface InspectorViewController ()

@end

@implementation InspectorViewController

@synthesize project, device, products, tabIndex, loggingDevices, projectArray, pathType;


#pragma mark - ViewController Methods


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Remove (almost) the indentation on the outline view

    deviceOutlineView.indentationPerLevel = 1.0;

    // Clear the content arrays:
    // 'projectData' is the project outline view data
    // 'deviceData' is the device outline view data

    projectData = [[NSMutableArray alloc] init];
    deviceData = [[NSMutableArray alloc] init];

    // Set up date handling

    inLogDef = [[NSDateFormatter alloc] init];
    inLogDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ";
    inLogDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    outLogDef = [[NSDateFormatter alloc] init];
    outLogDef.dateFormat = @"yyyy-MM-dd\nHH:mm:ss.SSS ZZZZZ";
    outLogDef.timeZone = [NSTimeZone localTimeZone];

    nswsw = NSWorkspace.sharedWorkspace;

    // Hide the tables when there's nothing to show

    deviceOutlineView.hidden = YES;
    deviceOutlineView.delegate = self;

    // Set up the tabs

    panelSelector.selectedSegment = 0;

    [self setNilProject];
}



#pragma mark - Button Action Methods


- (IBAction)link:(id)sender
{
    // Project path buttons in the Inspector panel come here when clicked

    NSButton *linkButton = (NSButton *)sender;
    InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;
    NSString *path = cellView.path;

    if (cellView.row < 5)
    {
        // This will be the location of the project file, which is already open,
        // so just reveal it in Finder...

        [nswsw selectFile:[NSString stringWithFormat:@"%@/%@", project.path, project.filename] inFileViewerRootedAtPath:project.path];
        return;
    }

    // ...otherwise open the file

    [nswsw openFile:path];
}



- (IBAction)goToURL:(id)sender
{
    // Agent URL buttons in the Inspector panel come here when clicked

    NSButton *linkButton = (NSButton *)sender;
    InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;

    // Open the URL

    [nswsw openURL:[NSURL URLWithString:cellView.path]];
}



#pragma mark - Data Setter Methods

- (void)setProject:(Project *)aProject
{
    // This is the 'project' property setter, which we use to populate
    // the two content arrays and trigger regeneration of the table view

    // Record the current project for comparison at the end of the method

    Project *oProject = project;
    project = aProject;

    // Clear the data array

    [projectData removeAllObjects];

    // If project does equal nil, we ignore the content creation section
    // and reload the table with empty data

    if (project != nil)
    {
        // Project Information Header

        TreeNode *pnode = [[TreeNode alloc] init];
        pnode.key = @"Project Information";
        [projectData addObject:pnode];

        // Project Name

        TreeNode *node = [[TreeNode alloc] init];
        node.key = @"Name";
        node.value = project.name;
        [projectData addObject:node];

        // Project Description

        if (project.description != nil && project.description.length > 0)
        {
            node = [[TreeNode alloc] init];
            node.key = @"Description";
            node.value = project.description;
            [projectData addObject:node];
        }

        // Project Product Name or ID

        if (products == nil || products.count == 0 || project.pid == nil)
        {
            node = [[TreeNode alloc] init];
            node.key = @"ID";
            node.value = project.pid.length > 0 ? project.pid : @"Project not linked to a product";
            [projectData addObject:node];
        }
        else
        {
            for (NSDictionary *product in products)
            {
                NSString *apid = [product objectForKey:@"id"];

                if ([apid compare:project.pid] == NSOrderedSame)
                {
                    node = [[TreeNode alloc] init];
                    node.key = @"Product Name";
                    
                    NSString *name = [product valueForKeyPath:@"attributes.name"];
                    if ((NSNull *)name == [NSNull null]) name = nil;
                    if (name != nil)
                    {
                        node.value = name;
                        [projectData addObject:node];
                    }
                }
            }
        }

        // Project Account ID

        if (project.aid != nil && project.aid.length > 0)
        {
            if (project.cid != nil && project.cid.length > 0)
            {
                node = [[TreeNode alloc] init];
                node.key = @"Creator ID";
                node.value = project.cid;
                [projectData addObject:node];

                if ([project.cid compare:project.aid] != NSOrderedSame)
                {
                    node = [[TreeNode alloc] init];
                    node.key = @"Account ID";
                    node.value = project.aid;
                    [projectData addObject:node];
                }
            }
            else
            {
                node = [[TreeNode alloc] init];
                node.key = @"Account ID";
                node.value = project.aid;
                [projectData addObject:node];
            }
        }
        else
        {
            node = [[TreeNode alloc] init];
            node.key = @"Account ID";
            node.value = @"Project not associated with an account";
            [projectData addObject:node];
        }

        // Project File Path

        node = [[TreeNode alloc] init];
        node.key = @"Path";

        if (project.path != nil && project.path.length > 0)
        {
            node.value = [NSString stringWithFormat:@"%@/%@", project.path, project.filename];
            node.flag = YES;
        }
        else
        {
            node.value = @"Project has not yet been saved";
        }

        [projectData addObject:node];

        // Device Groups Information Header

        node = [[TreeNode alloc] init];
        node.key = @"Device Group Information";
        [projectData addObject:node];

        if (project.devicegroups != nil && project.devicegroups.count > 0)
        {
            NSUInteger dgcount = 1;

            for (Devicegroup *devicegroup in project.devicegroups)
            {
                // Device Group x Header

                pnode = [[TreeNode alloc] init];
                pnode.key = [NSString stringWithFormat:@"Device Group %li", (long)dgcount];
                pnode.value = devicegroup.name;
                pnode.dg = devicegroup;
                pnode.expanded = pnode.dg.isExpanded;
                pnode.children = [[NSMutableArray alloc] init];
                [projectData addObject:pnode];

                // Device Group x ID

                node = [[TreeNode alloc] init];
                node.key = @"ID";
                node.value = (devicegroup.did != nil && devicegroup.did.length > 0) ? devicegroup.did : @"Not uploaded";
                [pnode.children addObject:node];

                // Device Group x Type

                node = [[TreeNode alloc] init];
                node.key = @"Type";
                node.value = [self convertDevicegroupType:devicegroup.type :NO];
                [pnode.children addObject:node];

                // Device Group x Description

                if (devicegroup.description != nil && devicegroup.description.length > 0)
                {
                    node = [[TreeNode alloc] init];
                    node.key = @"Description";
                    node.value = devicegroup.description;
                    [pnode.children addObject:node];
                }

                // Device Group x Models

                if (devicegroup.models.count > 0)
                {
                    NSUInteger modcount = 1;

                    for (Model *model in devicegroup.models)
                    {
                        NSString *typeString = [model.type compare:@"agent"] == NSOrderedSame ? @"Agent" : @"Device";

                        // Device Group x Model y Header

                        node = [[TreeNode alloc] init];
                        node.key = [NSString stringWithFormat:@"%@ Code File", typeString];
                        node.value = model.filename;
                        [pnode.children addObject:node];

                        // Device Group x Model y Path

                        node = [[TreeNode alloc] init];
                        node.key = @"Path";
                        
                        // FROM 2.3.128 Check for unsaved model files
                        
                        if ([model.filename compare:@"UNSAVED"] == NSOrderedSame)
                        {
                            node.value = @"Model file not yet saved";
                        }
                        else
                        {
                            node.value = [NSString stringWithFormat:@"%@/%@", [self getDisplayPath:model.path], model.filename];
                            node.flag = YES;
                        }
                        
                        [pnode.children addObject:node];

                        // Device Group x Model y Uploaded Date

                        node = [[TreeNode alloc] init];
                        node.key = @"Uploaded";
                        NSString *date = model.updated;

                        if (date != nil && date.length > 0)
                        {
                            date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
                            date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
                            date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
                            node.value = date;
                        }
                        else
                        {
                            node.value = @"No code uploaded";
                        }

                        [pnode.children addObject:node];

                        // Device Group x Model y SHA

                        node = [[TreeNode alloc] init];
                        node.key = @"SHA";
                        node.value = model.sha != nil && model.sha.length > 0 ? model.sha : @"No code uploaded";
                        [pnode.children addObject:node];

                        // Device Group x Model y Libraries and Files Header

                        if (model.libraries != nil && model.libraries.count > 0)
                        {
                            NSUInteger libcount = 1;

                            // Device Group x Model y Library z Data

                            node = [[TreeNode alloc] init];
                            node.key = @"Libraries";
                            node.value = [NSString stringWithFormat:@"%li local %@ imported", (long)model.libraries.count, (model.libraries.count > 1 ? @"libraries" : @"library")];
                            [pnode.children addObject:node];

                            for (File *library in model.libraries)
                            {
                                // Device Group x Model y Library z Path

                                node = [[TreeNode alloc] init];
                                node.key = [NSString stringWithFormat:@"Library %li", (long)libcount];

                                if (project.path == nil || project.path.length == 0)
                                {
                                    node.value = [library.path stringByAppendingFormat:@"/%@", library.filename];
                                }
                                else
                                {
                                    node.value = [NSString stringWithFormat:@"%@/%@", [self getDisplayPath:library.path], library.filename];
                                }

                                node.flag = YES;
                                [pnode.children addObject:node];

                                ++libcount;
                            }
                        }
                        else
                        {
                            node = [[TreeNode alloc] init];
                            node.key = @"Libraries";
                            node.value = @"No local libraries imported";
                            [pnode.children addObject:node];
                        }

                        if (model.files != nil && model.files.count > 0)
                        {
                            NSUInteger filecount = 1;

                            // Device Group x Model y File z Data

                            node = [[TreeNode alloc] init];
                            node.key = @"Files";
                            node.value = [NSString stringWithFormat:@"%li local %@ imported", (long)model.files.count, (model.files.count > 1 ? @"files" : @"file")];
                            [pnode.children addObject:node];

                            for (File *file in model.files)
                            {
                                // Device Group x Model y File z Path

                                node = [[TreeNode alloc] init];
                                node.key = [NSString stringWithFormat:@"File %li", (long)filecount];

                                if (project.path == nil || project.path.length == 0)
                                {
                                    node.value = [file.path stringByAppendingFormat:@"/%@", file.filename];
                                }
                                else
                                {
                                    node.value = [NSString stringWithFormat:@"%@/%@", [self getDisplayPath:file.path], file.filename];
                                }


                                node.flag = YES;
                                [pnode.children addObject:node];

                                ++filecount;
                            }
                        }
                        else
                        {
                            node = [[TreeNode alloc] init];
                            node.key = @"Files";
                            node.value = @"No local files imported";
                            [pnode.children addObject:node];
                        }

                        ++modcount;
                    }
                }

                ++dgcount;
            }
        }
        else
        {
            node = [[TreeNode alloc] init];
            node.key = @"Device Groups";
            node.value = @"None";
            [pnode.children addObject:node];
        }
    }

    if (panelSelector.selectedSegment == 0)
    {
        // The Project 'tab' is already selected, so update
        // the NSOutlineView to reflect the new project

        [deviceOutlineView reloadData];
        [deviceOutlineView setNeedsDisplay];
        
        if (projectData.count > 0)
        {
            // FROM 2.3.128 expand children based on recorded 'isExpanded' data
            // NOTE This is not currently saved
            
            for (TreeNode *node in projectData)
            {
                if (node.expanded)
                {
                    if (![deviceOutlineView isItemExpanded:node]) [deviceOutlineView expandItem:node expandChildren:YES];
                }
                else
                {
                     if ([deviceOutlineView isItemExpanded:node]) [deviceOutlineView collapseItem:node collapseChildren:YES];
                }
            }
        }
        
        if (oProject != nil && aProject != nil && deviceOutlineView.isHidden)
        {
            // Only show the NSOutlineView if it is already hidden
            // AND both the old and new projects are not nil

            deviceOutlineView.hidden = NO;

            [self showNilItems:NO];
        }

        if (aProject == nil)
        {
            deviceOutlineView.hidden = YES;

            [self setNilProject];
            [self showNilItems:YES];
        }
    }
}



- (void)setDevice:(NSMutableDictionary *)aDevice
{
    // This is the 'device' property setter, which we use to populate
    // the two content arrays and trigger regeneration of the table view

    // Record the current device for comparison at the end of the method

    NSMutableDictionary *oDevice = device;
    device = aDevice;

    // Clear the data arrays

    [deviceData removeAllObjects];

    // If device does equal nil, we ignore the content creation section
    // and reload the table with empty data

    if (device != nil)
    {
        // Device Information Header

        TreeNode *dnode = [[TreeNode alloc] init];
        dnode.key = @"Device Information";
        [deviceData addObject:dnode];

        // Device Name

        NSString *name = [device valueForKeyPath:@"attributes.name"];
        if ((NSNull *)name == [NSNull null]) name = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Name";
        dnode.value = name != nil ? name : @"Not set";
        [deviceData addObject:dnode];

        // Device ID

        dnode = [[TreeNode alloc] init];
        dnode.key = @"ID";
        dnode.value = [device objectForKey:@"id"];
        [deviceData addObject:dnode];

        // Device Type

        NSString *type = [device valueForKeyPath:@"attributes.imp_type"];
        if ((NSNull *)type == [NSNull null]) type = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Type";
        dnode.value = type != nil ? type : @"Unknown";
        [deviceData addObject:dnode];

        // Device impOS Version

        NSString *version = [device valueForKeyPath:@"attributes.swversion"];
        if ((NSNull *)version == [NSNull null]) version = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"impOS";

        if (version != nil)
        {
            NSArray *parts = [version componentsSeparatedByString:@" - "];
            parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"-"];
            dnode.value = [parts objectAtIndex:1];
        }
        else
        {
            dnode.value = @"Unknown";
        }

        [deviceData addObject:dnode];

        // Device Free Memory

        NSNumber *number = [device valueForKeyPath:@"attributes.free_memory"];
        if ((NSNull *)number == [NSNull null]) number = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Free RAM";
        dnode.value = number != nil ? [NSString stringWithFormat:@"%@KB", number] : @"Unknown";
        [deviceData addObject:dnode];

        // Network Information Header

        dnode = [[TreeNode alloc] init];
        dnode.key = @"Network Information";
        [deviceData addObject:dnode];

        // Device MAC Address

        NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
        if ((NSNull *)mac == [NSNull null]) mac = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"MAC";
        dnode.value = mac != nil ? [mac stringByReplacingOccurrencesOfString:@":" withString:@""] : @"Unknown";
        [deviceData addObject:dnode];

        // Device Status

        NSNumber *num = [device valueForKeyPath:@"attributes.device_online"];
        if ((NSNull *)num == [NSNull null]) num = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Status";
        NSString *string = num != nil && num.boolValue ? @"Online" : @"Offline";
        dnode.value = string;
        [deviceData addObject:dnode];

        // Device IP Address

        dnode = [[TreeNode alloc] init];
        dnode.key = @"IP";
        if ([string compare:@"Online"] == NSOrderedSame)
        {
            NSNumber *ip = [device valueForKeyPath:@"attributes.ip_address"];
            if ((NSNull *)ip == [NSNull null]) ip = nil;
            dnode.value = ip != nil ? [NSString stringWithFormat:@"%@", ip] : @"Unknown";
        }
        else
        {
            dnode.value = @"Unknown";
        }

        [deviceData addObject:dnode];

        // Device RSSI

        NSNumber *rssi = [device valueForKeyPath:@"attributes.rssi"];
        if ((NSNull *)rssi != [NSNull null] && rssi.integerValue != 0)
        {
            dnode = [[TreeNode alloc] init];
            dnode.key = @"RSSI";
            dnode.value = [NSString stringWithFormat:@"%i", rssi.intValue];
            [deviceData addObject:dnode];
        }

        // Agent Information Header

        dnode = [[TreeNode alloc] init];
        dnode.key = @"Agent Information";
        [deviceData addObject:dnode];

        // Agent Status

        num = [device valueForKeyPath:@"attributes.agent_running"];
        if ((NSNull *)num == [NSNull null]) num = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Status";
        dnode.value = num != nil && num.boolValue ? @"Online" : @"Offline";
        [deviceData addObject:dnode];

        // Agent URL

        string = [device valueForKeyPath:@"attributes.agent_id"];
        if ((NSNull *)string == [NSNull null]) string = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Agent URL";
        dnode.value = string != nil ? [@"https://agent.electricimp.com/" stringByAppendingString:string] : @"No agent";
        dnode.flag = YES;
        [deviceData addObject:dnode];

        // BlinkUp Information Header

        dnode = [[TreeNode alloc] init];
        dnode.key = @"BlinkUp Information";
        [deviceData addObject:dnode];

        // BlinkUp Date

        NSString *date = [device valueForKeyPath:@"attributes.last_enrolled_at"];
        if ((NSNull *)date == [NSNull null]) date = nil;
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Last Enrolled";
        dnode.value = @"Unknown";

        if (date != nil)
        {
            date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
            date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
            date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
            dnode.value = date;
        }

        [deviceData addObject:dnode];

        // Device Group Information Header

        dnode = [[TreeNode alloc] init];
        dnode.key = @"Device Group Information";
        [deviceData addObject:dnode];

        // Device Group Name or ID

        dnode = [[TreeNode alloc] init];
        dnode.key = @"ID";
        dnode.value = @"Unassigned";
        NSDictionary *dg = [device valueForKeyPath:@"relationships.devicegroup"];
        if ((NSNull *)dg == [NSNull null]) dg = nil;
        
        if (dg != nil)
        {
            NSString *dgid = [dg objectForKey:@"id"];
            BOOL got = NO;
            
            if (projectArray.count > 0)
            {
                for (Project *project in projectArray)
                {
                    for (Devicegroup *devicegroup in project.devicegroups)
                    {
                        if ([devicegroup.did compare:dgid] == NSOrderedSame)
                        {
                            dnode.key = @"Name";
                            dnode.value = devicegroup.name;
                            got = YES;
                            break;
                        }
                    }
                    
                    if (got) break;
                }
            }

            if (!got) dnode.value = dgid;
        }

        [deviceData addObject:dnode];
        
        // Logging Information Header
        
        dnode = [[TreeNode alloc] init];
        dnode.key = @"Logging Information";
        [deviceData addObject:dnode];
        
        // Device Group Name or ID
        
        dnode = [[TreeNode alloc] init];
        dnode.key = @"State";
        dnode.value = @"Not logging";
        
        if (loggingDevices != nil)
        {
            BOOL got = NO;
            
            if (loggingDevices.count > 0)
            {
                NSString *devID = [device objectForKey: @"id"];
                
                for (NSString *aDevID in loggingDevices)
                {
                    if ([aDevID compare:devID] == NSOrderedSame)
                    {
                        got = YES;
                        break;
                    }
                }
            }
            
            dnode.value = got ? @"Logging" : @"Not logging";
        }
        else
        {
            dnode.value = @"Unknown";
        }
        
        [deviceData addObject:dnode];
    }

    if (panelSelector.selectedSegment == 1)
    {
        // The Device 'tab' is already selected, so update
        // the NSOutlineView to reflect the new device

        [deviceOutlineView reloadData];
        [deviceOutlineView setNeedsDisplay];

        if (oDevice != nil && aDevice != nil && deviceOutlineView.isHidden)
        {
            // Only show the NSOutlineView if it is already hidden
            // AND both the old and new devices are not nil
            deviceOutlineView.hidden = NO;
            field.hidden = YES;
            subfield.hidden = YES;
            image.hidden = YES;
        }

        if (aDevice == nil)
        {
            deviceOutlineView.hidden = YES;

            [self setNilDevice];

            field.hidden = NO;
            subfield.hidden = NO;
            image.hidden = NO;
        }
    }
}



#pragma mark - Misc Methods


- (void)setTab:(NSUInteger)aTab
{
    // This is the 'tabIndex' setter method, which we trap in order
    // to trigger a switch to the implicitly requested tab

    if ((aTab > panelSelector.segmentCount || aTab == panelSelector.selectedSegment) && !deviceOutlineView.hidden) return;
    panelSelector.selectedSegment = aTab;
    [self switchTable:nil];
}



- (IBAction)switchTable:(id)sender
{
    // This method is called when the user clicks on the NSSegmentedControl, or code
    // calls setTab: (in which case 'sender' is nil

    NSInteger aTab = panelSelector.selectedSegment;
    tabIndex = aTab;

    if (aTab == 0)
    {
        // This is the project panel. If it is empty, just show the message

        if (project == nil || projectData.count == 0)
        {
            deviceOutlineView.hidden = YES;

            [self setNilProject];
            [self showNilItems:YES];
        }
        else
        {
            [deviceOutlineView reloadData];
            [deviceOutlineView setNeedsDisplay];

            for (TreeNode *node in projectData)
            {
                if (node.expanded)
                {
                    if (![deviceOutlineView isItemExpanded:node]) [deviceOutlineView expandItem:node expandChildren:YES];
                }
                else
                {
                    if ([deviceOutlineView isItemExpanded:node]) [deviceOutlineView collapseItem:node collapseChildren:YES];
                }
            }

            deviceOutlineView.hidden = NO;

            [self showNilItems:NO];
        }
    }
    else
    {
        // This is the device panel. If it is empty, just show the message

        if (device == nil || deviceData.count == 0)
        {
            deviceOutlineView.hidden = YES;

            [self setNilDevice];
            [self showNilItems:YES];
        }
        else
        {
            [deviceOutlineView reloadData];
            [deviceOutlineView setNeedsDisplay];

            deviceOutlineView.hidden = NO;

            [self showNilItems:NO];
        }
    }
}



- (BOOL)isLinkRow:(TreeNode *)node
{
    // If the node is flagged and its value is a valid string,
    // the row should show a link button

    if (node.flag && node.value.length > 1) return YES;
    return NO;
}



#pragma mark - NSOutlineView Delegate and DataSource Methods


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    return [self outlineView:outlineView isItemExpandable:item];
}



- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    // Only expand Project items

    if (panelSelector.selectedSegment == 0 && item != nil)
    {
        TreeNode *node = (TreeNode *)item;
        if (node.children != nil) return YES;
    }

    return NO;
}



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    // Nothing is selectable

    return NO;
}



- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    // This will always be the number of items in the root item, ie.
    // the number of items in the appropriate data set

    if (panelSelector.selectedSegment == 0)
    {
        if (item == nil) return projectData.count;
        TreeNode *node = (TreeNode *)item;
        return (node.children != nil ? node.children.count : 0);
    }

    return (item == nil ? deviceData.count : 0);
}



- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    // Only the Project Inspector has children

    if (panelSelector.selectedSegment == 0)
    {
        if (item == nil) return (projectData.count > 0 ? [projectData objectAtIndex:index] : [projectData objectAtIndex:0]);
        TreeNode *node = (TreeNode *)item;
        if (node.children != nil && node.children.count > 0) return [node.children objectAtIndex:index];
        return [node.children objectAtIndex:0];
    }

    if (item == nil) return (deviceData.count > 0 ? [deviceData objectAtIndex:index] : [deviceData objectAtIndex:0]);
    return [deviceData objectAtIndex:0];
}



- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
           byItem:(nullable id)item
{
    // This needs to be here or the NSOutlineView viewForColumn: method is never called

    return (panelSelector.selectedSegment == 1 ? @"DD" : @"PP");
}



- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(nullable NSTableColumn *)tableColumn
                   item:(nonnull id)item
{
    id cellView = nil;

    TreeNode *node = (TreeNode *)item;

    if (node.value.length == 0)
    {
        // This is a header row - make text all caps if 'flag' is NO
        // NOTE This is the same for both tables

        NSTableCellView *cv = [outlineView makeViewWithIdentifier:@"header.cell" owner:self];
        cv.textField.stringValue = !node.flag ? [node.key uppercaseString] : node.key;
        cellView = cv;
    }
    else
    {
        // This is a a data row

        InspectorDataCellView *cv = [outlineView makeViewWithIdentifier:@"data.cell" owner:self];
        cv.title.stringValue = node.key;
        cv.data.stringValue = node.value;

        if ([self isLinkRow:node])
        {
            // If data is a URL or a file link, make sure there's an active button at the end of the row

            cv.goToButton.target = self;

            if ([node.value compare:@"No agent"] == NSOrderedSame)
            {
                cv.goToButton.hidden = YES;
            }
            else
            {
                cv.path = node.value;

                if (panelSelector.selectedSegment == 1)
                {
                    // Button setup for the Device Inspector

                    cv.goToButton.action = @selector(goToURL:);
                    cv.goToButton.toolTip = @"Click this icon to open the displayed URL in a browser";
                }
                else
                {
                    // Button setup for the Project Inspector

                    cv.goToButton.action = @selector(link:);
                    cv.goToButton.toolTip = @"Click this icon to open the displayed file in your editor";
                    cv.row = (node.flag && [node.value hasSuffix:@"squirrelproj"]) ? 0 : 99;
                }

                cv.goToButton.hidden = NO;
            }
        }
        else
        {
            cv.goToButton.hidden = YES;
        }

        cellView = cv;
    }

    return cellView;
}



- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    // Return the appropriate height of the row, set by the deepest of the row's elements
    // This should be the main data field

    NSString *key = nil;
    NSString *value = nil;

    TreeNode *node = (TreeNode *)item;
    key = node.key;
    value = node.value;

    // Get the data of the cell we're sizing
    // Is it a spacer row — ie. 'key' and 'value' equal a single space

    if (key.length == 1 && value.length == 1) return 10;

    // Information row - but is it a header ('value' equals zero-length string) or a data row?

    if (value.length > 1)
    {
        // Get the rendered height of the data text - it's drawn into an area as wide as the data column

        CGFloat renderHeight = [self renderedHeightOfString:value];

        // 20 is the height of one standard line

        if (renderHeight < 20) renderHeight = 20;

        // Calculate the maximum, dealing with a fudge factor

        if (renderHeight > 20 && fmod(renderHeight, 20) > 0) renderHeight = renderHeight - fmod(renderHeight, 20) + 20;

        return renderHeight;
    }

    // Return the height of a header row

    return 30;
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



- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    if (panelSelector.selectedSegment == 0)
    {
        NSDictionary *ui = notification.userInfo;
        TreeNode *node = (TreeNode *)[ui objectForKey:@"NSObject"];
        
        node.expanded = YES;
        if (node.dg != nil) node.dg.isExpanded = YES;

        // Should we expand all?  Yes, if the Command Key is held down

        if (NSEventModifierFlagCommand & [NSEvent modifierFlags]) [deviceOutlineView expandItem:nil expandChildren:YES];
    }
}



- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    if (panelSelector.selectedSegment == 0)
    {
        NSDictionary *ui = notification.userInfo;
        TreeNode *node = (TreeNode *)[ui objectForKey:@"NSObject"];
        
        node.expanded = NO;
        if (node.dg != nil) node.dg.isExpanded = NO;

        // Should we collapse all? Yes, if the Command Key is held down

        if (NSEventModifierFlagCommand & [NSEvent modifierFlags]) [deviceOutlineView collapseItem:nil collapseChildren:YES];
    }
}



#pragma mark - Path Manipulation Methods


- (NSString *)getDisplayPath:(NSString *)path
{
    // ADDED IN 2.3.128
    // Convert a path string to the format required by the user's preference
    
    if (pathType == 0) path = [self getAbsolutePath:project.path :path];
    
    if (pathType == 2)
    {
        path = [self getAbsolutePath:project.path :path];
        path = [self getRelativeFilePath:[@"~/" stringByStandardizingPath] :[path stringByDeletingLastPathComponent]];
    }
    
    return path;
}



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



#pragma mark - Utility Methods


- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
    NSArray *dgtypes = @[ @"development_devicegroup", @"dut_devicegroup", @"production_devicegroup",
                          @"factoryfixture_devicegroup", @"pre_factoryfixture_devicegroup",
                          @"pre_dut_devicegroup", @"pre_production_devicegroup"];
    NSArray *dgnames = @[ @"Development", @"DUT", @"Production", @"Fixture", @"Test Fixture",
                          @"Test DUT", @"Test Production"];

    for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
    {
        NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];
        if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
    }

    if (!back) return @"Unknown";
    return @"development_devicegroup";
}



- (void)setNilProject
{
    // Set the 'no project open' imagery

    field.stringValue = @"No Project Selected";
    subfield.stringValue = @"Open or create a Project to view it here";
    image.image = [NSImage imageNamed:@"sidebar_project"];
}



- (void)setNilDevice
{
    // Set the 'no device selected' imagery

    field.stringValue = @"No Device Selected";
    subfield.stringValue = @"Log into your Electric Imp account\nto see devices here";
    image.image = [NSImage imageNamed:@"sidebar_device"];
}



- (void)showNilItems:(BOOL)shouldShow
{
    field.hidden = !shouldShow;
    subfield.hidden = !shouldShow;
    image.hidden = !shouldShow;
}



@end

