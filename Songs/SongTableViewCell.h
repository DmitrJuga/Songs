//
//  SongTableViewCell.h
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright © 2015 Dmitriy Dolotenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface SongTableViewCell : UITableViewCell

- (void)setupCellForSong:(Song *)song;

@end
