//
//  NNDataProvider.h
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNObservable.h"

@protocol NNDataProvider <NSObject>

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)anObject;

- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)objects;

- (void)removeObject:(id)anObject;

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;

@end

@interface NNDataProvider: NNObservable <NNDataProvider>

- (instancetype)initWithContentOfFile:(NSString *)filePath;
- (instancetype)initWithArray:(NSArray *)anArray;
- (BOOL)saveToFile:(NSString *)path error:(NSError **)error;

@end
