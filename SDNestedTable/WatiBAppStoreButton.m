//
//  WatiBAppStoreButton.m
//  Wati-B
//
//  Created by Alcaraz François-Julien on 1/15/2014.
//  Copyright (c) 2014 Merchlar. All rights reserved.
//

#import "WatiBAppStoreButton.h"

@implementation WatiBAppStoreButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(goToAppStore) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)goToAppStore {
    
    if (self.appStoreURL) {
        
        NSURL *myURL = [NSURL URLWithString:self.appStoreURL];
        [[UIApplication sharedApplication] openURL:myURL];
        
    }
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.cornerRadius = 5.0;
}


@end
