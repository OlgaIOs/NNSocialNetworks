//
//  NNMediator.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "NNMediator.h"
@interface NNMediator ()
@property (nonatomic, strong) NSMutableArray *changeBlocks;
@end

@implementation NNMediator
#pragma mark - Private Methods

- (void)beginCollectionViewUpdates {
    if (self.collectionView) {
        self.changeBlocks = [NSMutableArray array];
    }
}

- (void)addChangeBlock:(void(^)(void))block {
    [self.changeBlocks addObject:block];
}

- (void)endCollectionViewUpdates {
    __weak NNMediator *weakSelf = self;
    
    [self.collectionView performBatchUpdates:^{
        for (void (^updateBlock)(void) in weakSelf.changeBlocks) {
            updateBlock();
        }
    } completion:^(BOOL finished) {
        weakSelf.changeBlocks = nil;
    }];
}

#pragma mark - TSTListener protocol methods

- (void)observableObjectWillChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo {
    [self.tableView beginUpdates];
    [self beginCollectionViewUpdates];
}

- (void)observableObject:(id <NNObservable>)observable
         didChangeObject:(id)anObject
                 atIndex:(NSUInteger)index
           forChangeType:(NNListenerChangeType)type
                userInfo:(NSMutableDictionary *)userInfo {
    NSArray *changedIndexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
    __weak NNMediator *weakSelf = self;
    switch (type)
    {
        case NNListenerChangeTypeInsert:{
            [self.tableView insertRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView insertItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
        case NNListenerChangeTypeDelete:{
            [self.tableView deleteRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView deleteItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
        case NNListenerChangeTypeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:changedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self addChangeBlock:^{
                [weakSelf.collectionView reloadItemsAtIndexPaths:changedIndexPaths];
            }];
        }
            break;
    }
}

- (void)observableObjectDidChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo {
    [self.tableView endUpdates];
    [self endCollectionViewUpdates];
}

@end
