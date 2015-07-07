//
//  ViewController.m
//  Songs
//
//  Created by DmitrJuga on 06.07.15.
//  Copyright (c) 2015 Dmitriy Dolotenko. All rights reserved.
//

#import "Song.h"
#import "SongsViewController.h"
#import "SongTableViewCell.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "MagicalRecord/MagicalRecord.h"


@interface SongsViewController ()

@property (strong, nonatomic) SongsAPIManager *APIManager;
@property (strong, nonatomic) NSMutableArray *songList;

@end

@implementation SongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // настройка pull-to-refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadSongs)
                  forControlEvents:UIControlEventValueChanged];

    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // список песен (начально - из локальной БД)
    NSArray *songs = [Song MR_findAll];
    self.songList = [[NSMutableArray alloc] initWithArray:songs];
    
    // обновляем с сервера
    self.APIManager = [SongsAPIManager managerWithDelegate:self];
    [self reloadSongs];
}


// запуск загрузки обновления песен с сервера
- (void)reloadSongs {
    if (!self.refreshControl.refreshing) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [self.APIManager loadSongs];
}


// Объединение списков: сохранённых песен и загруженных
- (void)mergeSongsFromList:(NSArray *)jsonList {

    NSMutableArray *newList = [[NSMutableArray alloc] initWithArray:jsonList];
    
    // Сравнение списков
    NSMutableArray *updateIndexPaths = [[NSMutableArray alloc] init];
    NSMutableIndexSet *deleteIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSUInteger songListIdx = 0; songListIdx < self.songList.count; songListIdx++) {
        Song *song = self.songList[songListIdx];
        BOOL isNeedToDelete = YES;
        for (NSUInteger newListIdx = 0; newListIdx < newList.count; newListIdx++) {
            NSDictionary *jsonSong = newList[newListIdx];
            // если песня присутствует в новом списке
            if ([song.id isEqualToNumber:jsonSong[@"id"]]) {
                // проверяем, не изменились ли данные, при необходимости обновляем
                if (![song.label isEqualToString:jsonSong[@"label"]] ||
                    ![song.author isEqualToString:jsonSong[@"author"]]) {
                    song.label = jsonSong[@"label"];
                    song.author = jsonSong[@"author"];
                    [updateIndexPaths addObject:[NSIndexPath indexPathForRow:songListIdx inSection:0]];
                }
                //удаляем из нового списка, оставляем в основном
                [newList removeObjectAtIndex:newListIdx];
                isNeedToDelete = NO;
                break;
            }
        }
        // песня не найдена в новом списке - заносим в список на удаление
        if (isNeedToDelete) {
            [deleteIndexSet addIndex:songListIdx];
        }
    }
    // удаление
    // отсутствующие в новом списке песни удаляем из БД и основного списка
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] initWithCapacity:deleteIndexSet.count];
    [deleteIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Song *song = self.songList[idx];
        [song MR_deleteEntity];
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    [self.songList removeObjectsAtIndexes:deleteIndexSet];

    // добавление
    // всё что осталось в новом списке - добавляем в БД и в основной список
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] initWithCapacity:newList.count];
    for (NSDictionary *jsonSong in newList) {
        Song *song = [Song MR_importFromObject:jsonSong];
        [self.songList addObject:song];
        [insertIndexPaths addObject:[NSIndexPath indexPathForRow:self.songList.count - 1 inSection:0]];
    }

    if (updateIndexPaths.count > 0 || deleteIndexPaths.count > 0 || insertIndexPaths.count > 0) {
        // сохранение изменений в БД
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
        
        // (хак!) задержка для завершения анимации RefreshControl-а, иначе - дёргается((
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // обновление tableView c анимацией
            [self.tableView beginUpdates];
            // update
            [self.tableView reloadRowsAtIndexPaths:updateIndexPaths
                                  withRowAnimation:UITableViewRowAnimationMiddle];
            // delete
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths
                                  withRowAnimation:UITableViewRowAnimationLeft];
            // add
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths
                                  withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
        });
    }
}


#pragma mark UITableViewDataSource

// кол-во строк
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songList.count;
}

// содержимое ячейки
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    [cell setupCellForSong:self.songList[indexPath.row]];
    return cell;
}


#pragma mark UITableViewDelagate

// нажатие на ячейку
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark SongsAPIManagerDelegate

// получен результат
- (void)manager:(SongsAPIManager *)manager didSucceedLoadWithData:(NSArray *)data {
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    // слияние списков
    [self mergeSongsFromList:data];
}

// получена ошибка
- (void)manager:(SongsAPIManager *)manager didFailedLoadWithError:(NSError *)error {
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ошибка"
                                                   message:error.localizedDescription
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}


#pragma mark Action Handlers

// обработчик нажатия кнопки Обновить
- (IBAction)refreshBtnPressed:(id)sender {
    [self reloadSongs];
}

@end
