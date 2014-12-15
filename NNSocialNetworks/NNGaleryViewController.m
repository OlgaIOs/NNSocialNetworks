//
//  NNGaleryViewController.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "NNGaleryViewController.h"
#import "NNPhotoProvider.h"
#import "NNMediator.h"

@interface NNGaleryViewController ()
@property (nonatomic, strong) NNPhotoProvider *provider;
@property (nonatomic, strong) NNMediator *collectionViewMediator;
@end

@implementation NNGaleryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _provider = [[NNPhotoProvider alloc] init];
        _collectionViewMediator = [[NNMediator alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_provider removeListener:_collectionViewMediator];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionViewMediator.collectionView = self.collectionView;
    
    [self.provider addListener:self.collectionViewMediator];
    
    [self.provider fetchNextPage];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.provider count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:123];
    imageView.image = nil;
    [self.provider imageForIndex:indexPath.item
                associatedObject:cell
                       withBlock:^(UIImage *image) {
                           [UIView transitionWithView:imageView
                                             duration:1.0f
                                              options:UIViewAnimationOptionTransitionCrossDissolve
                                           animations:^{
                                               imageView.image = image;
                                           } completion:nil];
                       }];
    
    if (indexPath.item == self.provider.count - 1)
    {
        [self.provider fetchNextPage];
    }
    
    return cell;
}

@end
