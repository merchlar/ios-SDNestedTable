//
//  WatiBConstants.h
//  Wati-B
//
//  Created by Alcaraz François-Julien on 12/5/2013.
//  Copyright (c) 2013 Merchlar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WatiBARProgressBlock)(float percentDone);
typedef void (^WatiBARResultBlock)(NSArray *array, NSError *error);

typedef void (^WatiBTIResultBlock)(NSArray *array, NSError *error);

typedef void (^WatiBPlayerResultBlock)(NSArray *array, NSError *error);


typedef void (^WatiBProgressBlock)(float percentDone);
typedef void (^WatiBArrayResultBlock)(NSArray *array, NSError *error);
typedef void (^WatiBDataResultBlock)(NSData *data, NSError *error);
