//
//  SongsAPIManager.h
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SongsAPIManagerDelegate;

@interface SongsAPIManager : NSObject

@property (weak, nonatomic) id<SongsAPIManagerDelegate> delegate;

+ (SongsAPIManager *)managerWithDelegate:(id<SongsAPIManagerDelegate>)aDelegate;
- (void)loadSongs;

@end


@protocol SongsAPIManagerDelegate <NSObject>

@optional
- (void)manager:(SongsAPIManager *)manager didSucceedLoadWithData:(NSArray *)data;
- (void)manager:(SongsAPIManager *)manager didFailedLoadWithError:(NSError *)error;

@end
