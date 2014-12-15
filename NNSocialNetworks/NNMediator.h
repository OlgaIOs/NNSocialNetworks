//
//  NNMediator.h
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NNObservable.h"

@interface NNMediator : NSObject <NNListener>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end
