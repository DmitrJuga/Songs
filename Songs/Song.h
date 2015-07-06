//
//  Song.h
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * label;

@end
