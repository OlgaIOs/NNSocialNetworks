//
//  NNPhotoProvider.h
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NNObservable.h"

extern const NSUInteger TSTPhotoProviderDefaultPageSize;

@interface NNPhotoProvider : NNObservable

- (id)initWithPageSize:(NSUInteger)pageSize;

- (void)fetchNextPage;
- (void)imageForIndex:(NSUInteger)idx
     associatedObject:(id)object
            withBlock:(void (^)(UIImage *image))fetchBlock;
- (NSUInteger)count;

@end
