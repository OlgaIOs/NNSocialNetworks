//
//  NNDataProvider.m
//  NNSocialNetworks
//
//  Created by Olga Nikolaeva on 12/13/14.
//  Copyright (c) 2014 Olga Nikolaeva. All rights reserved.
//

#import "NNDataProvider.h"

static void *NNDataProviderObserveContext = &NNDataProviderObserveContext;
static NSString * const NNDataProviderObservingKey = @"backingObjects";

@interface NNDataProvider () <NNListener>

@property (nonatomic, strong) NSMutableArray *backingArray;

@end

@implementation NNDataProvider

- (id)init
{
    return [self initWithArray:nil];
}

- (instancetype)initWithContentOfFile:(NSString *)filePath
{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return [self initWithArray:array];
}

- (instancetype)initWithArray:(NSArray *)anArray
{
    self = [super init];
    if (self)
    {
        _backingArray = [NSMutableArray arrayWithArray:anArray];
        for (id object in _backingArray) {
            [self addOrRemoveSubscriptionForObject:object withChangeType:NNListenerChangeTypeInsert];
        }
        
        [self addObserver:self
               forKeyPath:NNDataProviderObservingKey
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                  context:NNDataProviderObserveContext];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self
              forKeyPath:NNDataProviderObservingKey
                 context:NNDataProviderObserveContext];
}

- (BOOL)saveToFile:(NSString *)path error:(NSError **)error
{
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:self.backingArray];
    return [saveData writeToFile:path options:NSDataWritingAtomic error:error];
}

- (NSUInteger)count
{
    return [self.proxyObjects count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return self.proxyObjects[index];
}

- (NSUInteger)indexOfObject:(id)anObject
{
    return [self.proxyObjects indexOfObject:anObject];
}

- (void)addObject:(id)anObject
{
    [self.proxyObjects addObject:anObject];
}

- (void)addObjectsFromArray:(NSArray *)objects
{
    NSIndexSet *insertIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.count, objects.count)];
    [self.proxyObjects insertObjects:objects atIndexes:insertIndex];
}

- (void)removeObject:(id)anObject
{
    [self.proxyObjects removeObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self.proxyObjects insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.proxyObjects removeObjectAtIndex:index];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [self.proxyObjects replaceObjectsAtIndexes:indexes withObjects:objects];
}

#pragma mark - Key-Value Coding

- (NSUInteger)countOfBackingObjects
{
    return [self.backingArray count];
}

- (NSArray *)backingObjectsAtIndexes:(NSIndexSet *)indexes
{
    return [self.backingArray objectsAtIndexes:indexes];
}

- (void)insertBackingObjects:(NSArray *)employeeArray atIndexes:(NSIndexSet *)indexes
{
    [self.backingArray insertObjects:employeeArray atIndexes:indexes];
}

- (void)removeBackingObjectsAtIndexes:(NSIndexSet *)indexes
{
    [self.backingArray removeObjectsAtIndexes:indexes];
}

- (void)replaceBackingObjectsAtIndexes:(NSIndexSet *)indexes withBackingObjects:(NSArray *)employeeArray
{
    [self.backingArray replaceObjectsAtIndexes:indexes withObjects:employeeArray];
}

- (NSMutableArray *)proxyObjects
{
    return [self mutableArrayValueForKey:NNDataProviderObservingKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == NNDataProviderObserveContext && [keyPath isEqualToString:NNDataProviderObservingKey])
    {
        NSNumber *isPriorNotification = change[NSKeyValueChangeNotificationIsPriorKey];
        if (isPriorNotification.boolValue)
        {
            [self notifyWillChangeContent:[change mutableCopy]];
        }
        else
        {
            
            [self notifyDidChange:change];
            
            [self notifyDidChangeContent:[change mutableCopy]];
        }
    }
}

- (void)notifyDidChange:(NSDictionary *)change {
    
    NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
    NSKeyValueChange changeKind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
    
    void(^notifyBlock)(NSArray *, NNListenerChangeType) =
    ^(NSArray *changedCollection, NNListenerChangeType type) {
        
        NSEnumerator *objectEnumeration = [changedCollection objectEnumerator];
        
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
         {
             id obj = [objectEnumeration nextObject];
             [self notifyDidChangeObject:obj atIndex:idx forChangeType:type userInfo:[change mutableCopy]];
             [self addOrRemoveSubscriptionForObject:obj withChangeType:type];
         }];
    };
    
    switch (changeKind)
    {
        case NSKeyValueChangeRemoval:
            notifyBlock(change[NSKeyValueChangeOldKey], NNListenerChangeTypeDelete);
            break;
        case NSKeyValueChangeReplacement:
            notifyBlock(change[NSKeyValueChangeOldKey], NNListenerChangeTypeDelete);
            notifyBlock(change[NSKeyValueChangeNewKey], NNListenerChangeTypeInsert);
            break;
        case NSKeyValueChangeInsertion:
            notifyBlock(change[NSKeyValueChangeNewKey], NNListenerChangeTypeInsert);
            break;
        case NSKeyValueChangeSetting:
            NSAssert(NO, @"NSKeyValueChangeSetting is undefined NSKeyValueChangeKindKey");
            break;
    }
}

- (void)addOrRemoveSubscriptionForObject:(id)object withChangeType:(NNListenerChangeType)type
{
    if ([object conformsToProtocol:@protocol(NNObservable)])
    {
        id <NNObservable> observable = object;
        if (type == NNListenerChangeTypeInsert)
        {
            [observable addListener:self];
        }
        else if (type == NNListenerChangeTypeDelete)
        {
            [observable removeListener:self];
        }
    }
}

- (void)observableObjectWillChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    if (!self.isNotifying)
    {
        [self notifyWillChangeContent:userInfo];
    }
}

- (void)observableObjectDidChangeContent:(id <NNObservable>)observable userInfo:(NSMutableDictionary *)userInfo
{
    NSUInteger index = [[self proxyObjects] indexOfObject:observable];
    [self notifyDidChangeObject:self atIndex:index forChangeType:NNListenerChangeTypeUpdate userInfo:userInfo];
    
    if (self.isNotifying)
    {
        [self notifyDidChangeContent:userInfo];
    }
}

@end
