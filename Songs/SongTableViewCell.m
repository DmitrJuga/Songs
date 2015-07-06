//
//  SongTableViewCell.m
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright © 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "SongTableViewCell.h"

@interface SongTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songAuthor;

@end


@implementation SongTableViewCell

// заполнение ячейки
- (void)setupCellForSong:(Song *)song {
    self.songTitle.text = song.label;
    self.songAuthor.text = song.author;
}

@end
