//
//  NNObservable.h
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NNListenerChangeType)
{
    NNListenerChangeTypeInsert = 1,
    NNListenerChangeTypeDelete = 2,
    NNListenerChangeTypeUpdate = 3
};

@protocol NNObservable;

@protocol NNListener <NSObject>

@optional

- (void)observableObjectWillChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo;

- (void)observableObject:(id <NNObservable>)observable didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(NNListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo;

- (void)observableObjectDidChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo;

@end

@protocol NNObservable <NSObject>

- (void)addListener:(id <NNListener>)listener;
- (void)removeListener:(id <NNListener>)listener;

@end

@interface NNObservable : NSObject <NNObservable>

@property (nonatomic, strong) NSHashTable *listeners;
@property (nonatomic, assign, getter = isNotifying) BOOL notifying;

- (void)notifyWillChangeContent:(NSMutableDictionary *)userInfo;
- (void)notifyDidChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(NNListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo;
- (void)notifyDidChangeContent:(NSMutableDictionary *)userInfo;

@end
