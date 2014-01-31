//
//  ExampleNestedTablesViewController.h
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 27/06/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "SDNestedTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"


@interface ExampleNestedTablesViewController : SDNestedTableViewController <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@property BOOL isAlreadyShowing;

@property (nonatomic, strong) NSArray * items;

-(void)showLoader;
-(void)hideLoader;

@end
