//
//  WatiBParseManager.h
//  Wati-B
//
//  Created by Alcaraz François-Julien on 12/5/2013.
//  Copyright (c) 2013 Merchlar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WatiBConstants.h"

@interface WatiBParseManager : NSObject

+ (id)sharedManager;

- (void)startDownloadARInBackgroundWithBlock:(__strong WatiBARResultBlock)resultBlock
                       progressBlock:(__strong WatiBARProgressBlock)progressBlock;

- (void)startDownloadTIInBackgroundWithBlock:(__strong WatiBTIResultBlock)resultBlock;

- (void)startDownloadPlayerInBackgroundWithBlock:(__strong WatiBPlayerResultBlock)resultBlock;


@end
