//
//  SongsAPIManager.m
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "SongsAPIManager.h"
#import "AFNetworking/AFNetworking.h"

#define     SERVER_URL          @"http://kilograpp.com:8080/songs/api/"
#define     GET_SONGS_METHOD    @"songs"

@interface SongsAPIManager()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation SongsAPIManager

// инициализатор
- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *URL = [NSURL URLWithString:SERVER_URL];
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:URL];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

// возвращает менеджер с делегатом
+ (SongsAPIManager *)managerWithDelegate:(id<SongsAPIManagerDelegate>)aDelegate {
    SongsAPIManager *manager = [[SongsAPIManager alloc] init];
    manager.delegate = aDelegate;
    return manager;
}

// Осуществляет загрузку данных
- (void)loadSongs {
    [self.manager GET:GET_SONGS_METHOD
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject isKindOfClass:[NSArray class]]) {
                      [self.delegate manager:self didSucceedLoadWithData:responseObject];
                  } else {
                      [self.delegate manager:self didSucceedLoadWithData:nil];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if ([self.delegate respondsToSelector:@selector(manager:didFailedLoadWithError:)]) {
                      [self.delegate manager:self didFailedLoadWithError:error];
                  } else {
                      NSLog(@"Error: %@", error);
                  }
              }];
}


@end
