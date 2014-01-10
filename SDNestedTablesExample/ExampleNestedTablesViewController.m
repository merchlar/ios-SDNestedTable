//
//  ExampleNestedTablesViewController.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 27/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExampleNestedTablesViewController.h"
#import "WatiBParseManager.h"
#import <Parse/Parse.h>

@interface ExampleNestedTablesViewController ()

@end

@implementation ExampleNestedTablesViewController

- (id) init
{
    if (self = [super initWithNibName:@"SDNestedTableView" bundle:nil])
    {
        // do init stuff
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [self fetchData];
}

#pragma mark - Methods

- (void)fetchData {
    
    [[WatiBParseManager sharedManager] startDownloadPlayerInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //        HUD.mode = MBProgressHUDModeIndeterminate;
        //        HUD.labelText = @"Chargement";
        
        
        if (!error) {
            //Download finish
            NSLog(@"Download Player Sucess");
            self.items = objects;
            [self.tableView reloadData];
        }
        else {
            //Error download
            NSLog(@"Download Player Error %@", error);
            
        }
        
        
    }];
    
}

#pragma mark - Nested Tables methods

- (NSInteger)mainTable:(UITableView *)mainTable numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (NSInteger)mainTable:(UITableView *)mainTable numberOfSubItemsforItem:(SDGroupCell *)item atIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject * artist = [self.items objectAtIndex:indexPath.row];
    
    NSArray * songs = [artist objectForKey:@"songs"];
    
    NSLog(@"%d songs for artist %@", [songs count], [artist objectForKey:@"name"]);
    
    return [songs count];
    
//    if (item.cellIndexPath.row == 0) {
//        return 3;
//    }
//    else if (item.cellIndexPath.row == 1) {
//        return 2;
//    }
//    else if (item.cellIndexPath.row == 2) {
//        return 4;
//    }
//    else if (item.cellIndexPath.row == 3) {
//        return 6;
//    }
//    
//    return 3; 
}

- (SDGroupCell *)mainTable:(UITableView *)mainTable setItem:(SDGroupCell *)item forRowAtIndexPath:(NSIndexPath *)indexPath
{
    item.itemText.text = [NSString stringWithFormat:@"My Main Item %u", indexPath.row +1];
    return item;
}

- (SDSubCell *)item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * songTitle = [[[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSNumber * songOrder = [[[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] objectAtIndex:indexPath.row] objectForKey:@"order"];

    subItem.itemText.text = [NSString stringWithFormat:@"%d - %@", [songOrder intValue], songTitle];
    return subItem;
}

- (void) mainTable:(UITableView *)mainTable itemDidChange:(SDGroupCell *)item
{
    SelectableCellState state = item.selectableCellState;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:item];
    switch (state) {
        case Checked:
            NSLog(@"Changed Item at indexPath:%@ to state \"Checked\"", indexPath);
            break;
        case Unchecked:
            NSLog(@"Changed Item at indexPath:%@ to state \"Unchecked\"", indexPath);
            break;
        case Halfchecked:
            NSLog(@"Changed Item at indexPath:%@ to state \"Halfchecked\"", indexPath);
            break;
        default:
            break;
    }
}

- (void) item:(SDGroupCell *)item subItemDidChange:(SDSelectableCell *)subItem
{
    SelectableCellState state = subItem.selectableCellState;
    NSIndexPath *indexPath = [item.subTable indexPathForCell:subItem];
    switch (state) {
        case Checked:
            NSLog(@"Changed Sub Item at indexPath:%@ to state \"Checked\"", indexPath);
            break;
        case Unchecked:
            NSLog(@"Changed Sub Item at indexPath:%@ to state \"Unchecked\"", indexPath);
            break;
        default:
            break;
    }
}

- (void)expandingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Expanded Item at indexPath: %@", indexPath);
}

- (void)collapsingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath 
{
    NSLog(@"Collapsed Item at indexPath: %@", indexPath);
}

@end
