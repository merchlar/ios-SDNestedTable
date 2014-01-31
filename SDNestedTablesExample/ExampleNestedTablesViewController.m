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
#import "UIImageView+WebCache.h"
#import "WatiBAppStoreButton.h"
#import "Flurry.h"

@interface ExampleNestedTablesViewController ()

@end

@implementation ExampleNestedTablesViewController

@synthesize isAlreadyShowing;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [Flurry logEvent:@"WATI_SONS_VIEW"];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    

    [self.navigationController setNavigationBarHidden:YES animated:YES];

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
            [self showCustomErrorWithText:@"Impossible de recevoir les données du serveur. SVP vérifier votre connexion et ressayer."];
        }
        
        
    }
   customErrorBlock:^(NSString *type, NSString *text, NSString *appStoreURL) {
       
       self.items = nil;
       
       // HANDLE CUSTOM ERRORS HERE
       
       if ([type isEqualToString:@"update-app"]) {
           [self showUpdateAppWithText:text andURL:appStoreURL];
       }
       else if ([type isEqualToString:@"custom"]) {
           [self showCustomErrorWithText:text];

       }
       
       
   }];
    
}

- (void)showCustomErrorWithText:(NSString *)errorText {
    
    UIView * errorView = [[[NSBundle mainBundle] loadNibNamed:@"WatiBPlayerError" owner:self options:nil] objectAtIndex:0];
    
    UILabel * errorLabel = (UILabel *)[errorView viewWithTag:1];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:errorText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [errorText length])];
    errorLabel.attributedText = attributedString;
    
//    [errorLabel setText:errorText];
    
    WatiBAppStoreButton * appStoreButton = (WatiBAppStoreButton *)[errorView viewWithTag:2];
    
    appStoreButton.hidden = YES;
    
    [errorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [self.tableView addSubview:errorView];
    
    [errorView setFrame:self.tableView.bounds];
    
}

- (void)showUpdateAppWithText:(NSString *)updateText andURL:(NSString *)appStoreURL {
    
    UIView * errorView = [[[NSBundle mainBundle] loadNibNamed:@"WatiBPlayerError" owner:self options:nil] objectAtIndex:0];
    
    UILabel * errorLabel = (UILabel *)[errorView viewWithTag:1];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:updateText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [updateText length])];
    errorLabel.attributedText = attributedString;
    
//    [errorLabel setText:updateText];
    
    WatiBAppStoreButton * appStoreButton = (WatiBAppStoreButton *)[errorView viewWithTag:2];
    
    appStoreButton.appStoreURL = appStoreURL;
    
    [errorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [self.tableView addSubview:errorView];
    
    [errorView setFrame:self.tableView.bounds];
    
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
    
    if ([songs count] == 0) {
        return 1;
    }
    
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
    PFObject * object = [self.items objectAtIndex:indexPath.row];

    item.artistObject = object;
    
    NSString * url = [(PFFile *)[object objectForKey:@"banner_iphone"] url];

    
    [item.artistImageView setImageWithURL:[NSURL URLWithString:url]
                    placeholderImage:nil
                             options:SDWebImageRetryFailed
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               NSLog(@"completed !");
//                               if ([self.loader isAnimating]) {
//                                   [self.loader stopAnimating];
//                               }
                               if (error) {
                                   [self showCustomErrorWithText:@"Impossible de télécharger les images. SVP vérifier votre connexion et ressayer."];
                               }
                               
                           }];
    
    item.itemText.text = [NSString stringWithFormat:@"My Main Item %u", indexPath.row +1];
    return item;
}

- (SDSubCell *)item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] count] == 0) {
        subItem.itemText.text = @"Pas de musiques disponible pour cet artiste.";
    }
    else {
        NSString * songTitle = [[[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSNumber * songOrder = [[[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] objectAtIndex:indexPath.row] objectForKey:@"order"];

        subItem.itemText.text = [NSString stringWithFormat:@"%d   %@", [songOrder intValue], songTitle];
        subItem.songObject = [[[self.items objectAtIndex:item.cellIndexPath.row] objectForKey:@"songs"] objectAtIndex:indexPath.row];
    }
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

#pragma mark Loader methods

- (void)showLoader {
    if (!isAlreadyShowing) {
        //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.animationType = MBProgressHUDAnimationFade;
        
        HUD.delegate = self;
        
        
        [HUD show:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        isAlreadyShowing = YES;
        
    }
    
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Chargement";
    
    //    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    //    HUD.labelText = @"Téléchargement";
}

- (void)hideLoader {
    isAlreadyShowing = NO;
    
    [HUD hide:YES];
    
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
    //	[HUD release];
	HUD = nil;
}

@end
