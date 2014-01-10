//
//  WatiBParseManager.m
//  Wati-B
//
//  Created by Alcaraz François-Julien on 12/5/2013.
//  Copyright (c) 2013 Merchlar. All rights reserved.
//

#import "WatiBParseManager.h"
#import <Parse/Parse.h>


@interface WatiBParseManager ()

@property (nonatomic, copy) WatiBARProgressBlock currentARProgressBlock;
@property (nonatomic, copy) WatiBARResultBlock currentARResultBlock;
@property (nonatomic, copy) WatiBTIResultBlock currentTIResultBlock;
@property (nonatomic, copy) WatiBPlayerResultBlock currentPlayerResultBlock;

@property (nonatomic,assign) float arXMLPercentage;
@property (nonatomic,assign) float arDATPercentage;
@property (nonatomic,assign) BOOL downloadedXML;
@property (nonatomic,assign) BOOL downloadedDAT;
@property (nonatomic,assign) BOOL failedXML;
@property (nonatomic,assign) BOOL failedDAT;

@end

@implementation WatiBParseManager

+ (id)sharedManager {
    static WatiBParseManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}



#pragma mark Public methods


- (void)startDownloadARInBackgroundWithBlock:(__strong WatiBARResultBlock)resultBlock
                               progressBlock:(__strong WatiBARProgressBlock)progressBloc {
    
    self.currentARProgressBlock = progressBloc;
    self.currentARResultBlock = resultBlock;
    
    [self startDownloadAR];
    
}

//- (void)startDownloadTargetImagesInBackgroundWithBlock:(__strong WatiBTIResultBlock)resultBlock
//                               progressBlock:(__strong WatiBTIProgressBlock)progressBloc {
//    
//    self.currentARProgressBlock = progressBloc;
//    self.currentARResultBlock = resultBlock;
//    
//    [self startDownloadAR];
//    
//}

- (void)startDownloadTIInBackgroundWithBlock:(__strong WatiBTIResultBlock)resultBlock{
    
    self.currentTIResultBlock = resultBlock;
    
    [self startDownloadTI];
    
}

- (void)startDownloadPlayerInBackgroundWithBlock:(__strong WatiBPlayerResultBlock)resultBlock {
    
    self.currentPlayerResultBlock = resultBlock;
    
    [self startDownloadPlayer];
    
    
}

#pragma mark Player Download methods

- (void)startDownloadPlayer {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"PlayerArtists"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query includeKey:@"songs"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"WatiBParseManager : DownloadPlayer Successfully retrieved %d objects.", objects.count);
            
            NSMutableArray * temp = [NSMutableArray array];
            
            for (PFObject * obj in objects) {
                [temp addObject:obj];
                
            }
            
            
            
            self.currentPlayerResultBlock(objects, error);
            
        } else {
            // Log details of the failure
            NSLog(@"WatiBParseManager : DownloadTI Error: %@ + %@", error, [error userInfo]);
            
            self.currentPlayerResultBlock(nil, error);
            
        }
    }];
    
    
}

#pragma mark Target images Download methods

- (void)startDownloadTI {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"ARTargetImages"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"WatiBParseManager : DownloadTI Successfully retrieved %d objects.", objects.count);
            
            NSMutableArray * temp = [NSMutableArray array];
            
            for (PFObject * obj in objects) {
                [temp addObject:obj];

            }
            
            
            
            self.currentTIResultBlock(temp, error);
            
        } else {
            // Log details of the failure
            NSLog(@"WatiBParseManager : DownloadTI Error: %@ + %@", error, [error userInfo]);
            
            self.currentTIResultBlock(nil, error);
            
        }
    }];

    
}

#pragma mark AR Download methods

- (void)startDownloadAR {
    
    self.arDATPercentage = 0.0f;
    self.arXMLPercentage = 0.0f;

    self.downloadedDAT = NO;
    self.downloadedXML = NO;
    self.failedDAT = NO;
    self.failedXML = NO;
    
    //Show loader
//    [self showLoader];
    
    //Start download
    [self downloadARDataSets];
    
}

- (void)downloadARDataSets {
    //Fetch data
    PFQuery *query = [PFQuery queryWithClassName:@"ARDatasets"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"WatiBParseManager : downloadDataSets Successfully retrieved %d objects.", objects.count);
            
            PFObject * dataset;
            
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"WatiBParseManager : %@ for xml file url : %@\n dat file url : %@", object.objectId, [(PFFile *)[object objectForKey:@"file_xml"] url], [(PFFile *)[object objectForKey:@"file_dat"] url]);
                
                
                dataset = object;
                
            }
            
            //start progress both at 0
//            self.currentARProgressBlock(self.arXMLPercentage, self.arDATPercentage);
            [self updateProgressBlockForXML:self.arXMLPercentage andDAT:self.arDATPercentage];

            //Then start download video file
            [self downloadXMLFile:(PFFile *)[dataset objectForKey:@"file_xml"] andDATFile:(PFFile *)[dataset objectForKey:@"file_dat"]];
            
        } else {
            // Log details of the failure
            NSLog(@"WatiBParseManager : downloadVideoData Error: %@ + %@", error, [error userInfo]);
            
            self.currentARResultBlock(nil, error);

        }
    }];
}

- (void)downloadXMLFile:(PFFile*)xmlfile andDATFile:(PFFile*)datfile {
    
    
    //Download XML file
    [xmlfile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            NSLog(@"WatiBParseManager : downloadXMLFile Successfully %d for file %@", data.length, xmlfile.name);
            
            //Store in document folder
            [self writeFileIntoDocumentDirectory:data withName:@"DataSet.xml" andPath:@""];
            self.downloadedXML = YES;
            
            if (self.downloadedDAT){
                //Start download videos
                [self downloadARVideos];
            }
            
            if (self.failedDAT){
                return;
            }
            
        }
        else {
            
            // Log details of the failure
            NSLog(@"WatiBParseManager : downloadXMLFile Error: %@ + %@", error, [error userInfo]);
            
            self.currentARResultBlock(nil, error);
            self.failedXML = YES;

        }
        
        
    } progressBlock:^(int percentDone) {
        
        // Update your progress spinner here. percentDone will be between 0 and 100.
        NSLog(@"WatiBParseManager : downloadXMLFile progressBlock %d for file %@", percentDone, xmlfile.name);
        
        self.arXMLPercentage = percentDone;
//        self.currentARProgressBlock(self.arXMLPercentage, self.arDATPercentage);
        [self updateProgressBlockForXML:self.arXMLPercentage andDAT:self.arDATPercentage];

    }];
    
    
    
    //Download DAT file
    [datfile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            NSLog(@"WatiBParseManager : downloadDATFile Successfully %d for file %@", data.length, datfile.name);

            //Store in document folder
            [self writeFileIntoDocumentDirectory:data withName:@"DataSet.dat" andPath:@""];
            self.downloadedDAT = YES;
            
            if (self.downloadedXML){
                //Start download videos
                [self downloadARVideos];
            }
            
            if (self.failedXML){
                return;
            }
            
        }
        else {
            
            // Log details of the failure
            NSLog(@"WatiBParseManager : downloadDATFile Error: %@ + %@", error, [error userInfo]);
            
            self.currentARResultBlock(nil, error);
            self.failedDAT = YES;
        }
        
    } progressBlock:^(int percentDone) {
        
        // Update your progress spinner here. percentDone will be between 0 and 100.
        NSLog(@"WatiBParseManager : downloadDATFile progressBlock %d for file %@", percentDone, datfile.name);
        
        self.arDATPercentage = percentDone;
//        self.currentARProgressBlock(self.arXMLPercentage, self.arDATPercentage);
        [self updateProgressBlockForXML:self.arXMLPercentage andDAT:self.arDATPercentage];

    }];
    
    
    
    
}





- (void)downloadARVideos {
    
    //Fetch data
    PFQuery *query = [PFQuery queryWithClassName:@"ARVideos"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"WatiBParseManager : downloadARVideos Successfully retrieved %d objects.", objects.count);
            
            NSArray * finalArray = [self getArrayForVideos:objects];
            
            
            self.arDATPercentage = 100.0;
            self.arXMLPercentage = 100.0;
//            self.currentARProgressBlock(self.arXMLPercentage, self.arDATPercentage);
            [self updateProgressBlockForXML:self.arXMLPercentage andDAT:self.arDATPercentage];
            self.currentARResultBlock(finalArray, nil);
            
            
        } else {
            // Log details of the failure
            NSLog(@"WatiBParseManager : downloadARVideos Error: %@ + %@", error, [error userInfo]);
            
            self.currentARResultBlock(nil, error);

        }
    }];
    
}

- (void)updateProgressBlockForXML:(float)xmlPercent andDAT:(float)datPercent {
    
    float finalPercent = (xmlPercent + datPercent) / 2;
    
    self.currentARProgressBlock(finalPercent);

}

- (NSArray *)getArrayForVideos:(NSArray *)array {
    
    NSMutableArray * videoArray = [[NSMutableArray alloc] init];
    
    // Do something with the found objects
    for (PFObject *object in array) {
        NSLog(@"%@ for video file url : %@", object.objectId, [(PFFile *)[object objectForKey:@"video_file"] url]);
        
        NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] init];
        NSMutableArray * datasetIds = [[NSMutableArray alloc] init];
        
        for (int i =0; i < [(NSArray *)[object objectForKey:@"dataset_ids"] count] ;i++) {
            NSLog(@"dataset id : %@", [(NSArray *)[object objectForKey:@"dataset_ids"] objectAtIndex:i]);
            
            
            [datasetIds addObject:[(NSArray *)[object objectForKey:@"dataset_ids"] objectAtIndex:i]];
        }
        [objectDict setObject:datasetIds forKey:@"dataset_ids"];

        
        
        //do logic
        if ((PFFile *)[object objectForKey:@"video_file"]) {
            NSLog(@"it's a video file !");
            [objectDict setObject:[(PFFile *)[object objectForKey:@"video_file"] url] forKey:@"video_url"];
        }
        else if ((PFFile *)[object objectForKey:@"video_url"]) {
            NSLog(@"it's a video url !");
            [objectDict setObject:(PFFile *)[object objectForKey:@"video_url"] forKey:@"video_url"];
        }
        [objectDict setObject:datasetIds forKey:@"dataset_ids"];
        [objectDict setObject:[object objectForKey:@"full_screen"] forKey:@"full_screen"];
        [objectDict setObject:[object objectForKey:@"restart"] forKey:@"restart"];
        [objectDict setObject:[object objectForKey:@"name"] forKey:@"name"];

        [videoArray addObject:objectDict];
        
    }
    
    return videoArray;
}

#pragma mark Writing files methods


// Methods to write any file in the document directory
- (void)writeFileIntoDocumentDirectory:(NSData *)data withName:(NSString *)name andPath:(NSString *)path{
    
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSLog(@"documentsDirectory %@",documentsDirectory);
    
    //make a file name to write the data to using the
    //documents directory:
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:path];
//    NSLog(@"savedImagePath %@",savedImagePath);
    NSError * error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:savedImagePath]) {
//        NSLog(@"createFolder %@", path);
        [[NSFileManager defaultManager] createDirectoryAtPath:savedImagePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    
    NSString *finalPath = [savedImagePath stringByAppendingPathComponent:name];
//    NSLog(@"finalPath %@",finalPath);
    [data writeToFile:finalPath atomically:NO];
    
    
}

@end
