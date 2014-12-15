//
//  NNObservable.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//
#import "NNObservable.h"

@implementation NNObservable

@synthesize listeners = _listeners;

- (id)init
{
    self = [super init];
    if (self)
    {
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

- (void)notifyWillChangeContent:(NSMutableDictionary *)userInfo
{
    self.notifying = YES;
    for (id <NNListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObjectWillChangeContent:userInfo:)])
        {
            [listener observableObjectWillChangeContent:self userInfo:userInfo];
        }
    }
}

- (void)notifyDidChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(NNListenerChangeType)type userInfo:(NSMutableDictionary *)userInfo
{
    for (id <NNListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObject:didChangeObject:atIndex:forChangeType:userInfo:)])
        {
            [listener observableObject:self didChangeObject:anObject atIndex:index forChangeType:type userInfo:userInfo];
        }
    }
}

- (void)notifyDidChangeContent:(NSMutableDictionary *)userInfo
{
    for (id <NNListener> listener in [self.listeners copy])
    {
        if ([listener respondsToSelector:@selector(observableObjectDidChangeContent:userInfo:)])
        {
            [listener observableObjectDidChangeContent:self userInfo:userInfo];
        }
    }
    self.notifying = NO;
}

- (void)addListener:(id <NNListener>)listener
{
    NSParameterAssert([listener conformsToProtocol:@protocol(NNListener)]);
    [self.listeners addObject:listener];
}

- (void)removeListener:(id <NNListener>)listener
{
    [self.listeners removeObject:listener];
}

@end
