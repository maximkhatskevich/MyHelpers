//
//  ExtMutableArray.m
//  CocoaTouchHelpers
//
//  Created by Maxim Khatskevich on 28/03/14.
//  Copyright (c) 2014 Maxim Khatskevich. All rights reserved.
//

#import "ExtMutableArray.h"

#import "NSArray+Helpers.h"
#import "ArrayItemWrapper.h"
#import <Block-KVO/MTKObserving.h>

@interface ExtMutableArray ()

@property (readwrite, nonatomic) dispatch_queue_t queue;

// backing store
@property (readonly, nonatomic) NSMutableArray *store;

@property (strong, nonatomic) NSMapTable *contentNotifications;
@property (strong, nonatomic) NSMapTable *selectionNotifications;

@end

@implementation ExtMutableArray

#pragma mark - Property accessors

- (NSArray *)selection
{
    NSMutableArray *result = [NSMutableArray array];
    
    //===
    
    for (ArrayItemWrapper *wrapper in _store)
    {
        if (wrapper.selected)
        {
            [result addObject:wrapper.content];
        }
    }
    
    //===
    
    return [NSArray arrayWithArray:result];
}

- (id)selectedObject
{
    return self.selection.firstObject;
}

#pragma mark - Overrided methods

- (instancetype)init
{
    self = [super init];
    
    //===
    
    if (self)
    {
        _store = [NSMutableArray array];
        _queue = dispatch_queue_create("ExtMutableArrayQueue", DISPATCH_QUEUE_CONCURRENT);
        
        _contentNotifications = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory
                                                      valueOptions:NSPointerFunctionsStrongMemory];
        
        _selectionNotifications = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory
                                                        valueOptions:NSPointerFunctionsStrongMemory];
        
        [self
         observeRelationship:@"store"
         changeBlock:^(__weak id self, id old, id new) {
             
             //
         }
         insertionBlock:^(__weak id self, id new, NSIndexSet *indexes) {
             
             [self notifyAboutContentChange];
         }
         removalBlock:^(__weak id self, id old, NSIndexSet *indexes) {
             
             [self notifyAboutContentChange];
         }
         replacementBlock:^(__weak id self, id old, id new, NSIndexSet *indexes) {
             
             [self notifyAboutContentChange];
         }];
    }
    
    //===
    
    return self;
}

//- (instancetype)initWithCapacity:(NSUInteger)numItems
//{
//    self = [super init];
//    
//    //===
//    
//    if (self)
//    {
//        
//    }
//    
//    //===
//    
//    return self;
//}

//- (instancetype)initWithObjects:(const id [])objects
//                          count:(NSUInteger)count
//{
//    self = [super init];
//    
//    //===
//    
//    if (self)
//    {
//        
//    }
//    
//    //===
//    
//    return self;
//}

#pragma mark - Overrided methods - NSArray

- (NSUInteger)count
{
    __block NSUInteger result = 0;
    
    //===
    
    dispatch_sync(_queue, ^{
        
        result = _store.count;
    });
    
    //===
    
    return result;
}

- (id)objectAtIndex:(NSUInteger)index
{
    __block id result = nil;
    
    //===
    
    dispatch_sync(_queue, ^{
        
        result = ((ArrayItemWrapper *)_store[index]).content;
    });
    
    //===
    
    return result;
}

#pragma mark - Overrided methods - NSMutableArray

- (NSString *)description
{
    NSString *result = @"";
    
    //===
    
    for (ArrayItemWrapper *item in self.store)
    {
        if (result.length != 0)
        {
            result = [result stringByAppendingFormat:@", "];
        }
        
        result = [result stringByAppendingFormat:@"[%@]%@",
                  (item.selected ? @"v" : @" "), item.content];
    }
    
    //===
    
    return result;
}

- (void)addObject:(id)anObject
{
    dispatch_barrier_async(_queue, ^{
        
        [_store addObject:
         [ArrayItemWrapper wrapperWithContent:anObject]];
        
        //===
        
//        [self notifyAboutContentChange];
    });
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    dispatch_barrier_async(_queue, ^{
        
        [_store insertObject:[ArrayItemWrapper wrapperWithContent:anObject]
                     atIndex:index];
        
        //===
        
//        [self notifyAboutContentChange];
    });
}

- (void)removeLastObject
{
    dispatch_barrier_async(_queue, ^{
        
//        id targetObject = ((ArrayItemWrapper *)_store.lastObject).content;
        
        //===
        
        [_store removeLastObject];
        
        //===
        
//        if (targetObject)
//        {
//            [self notifyAboutContentChange];
//        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    dispatch_barrier_async(_queue, ^{
        
        if ([_store isValidIndex:index])
        {
//            id targetObject = ((ArrayItemWrapper *)_store[index]).content;
            
            //===
            
            [_store removeObjectAtIndex:index];
            
            //===
            
//            if (targetObject)
//            {
//                [self notifyAboutContentChange];
//            }
        }
    });
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    dispatch_barrier_async(_queue, ^{
        
        if ([_store isValidIndex:index])
        {
//            id targetObject = ((ArrayItemWrapper *)_store[index]).content;
            
            //===
            
            [_store replaceObjectAtIndex:index
                              withObject:[ArrayItemWrapper wrapperWithContent:anObject]];
            
            //===
            
//            if (targetObject)
//            {
//                [self notifyAboutContentChange];
//            }
        }
    });
}

#pragma mark - Service

- (BOOL)willChangeSelectionWithObject:(id)targetObject changeType:(EMAChangeType)changeType
{
    BOOL result = YES;
    
    //===
    
    if (self.onWillChangeSelection)
    {
        result = self.onWillChangeSelection(self, targetObject, changeType);
    }
    
    //===
    
    return result;
}

- (void)didChangeSelectionWithObject:(id)targetObject changeType:(EMAChangeType)changeType
{
    if (self.onDidChangeSelection)
    {
        self.onDidChangeSelection(self, targetObject, changeType);
    }
    
    //===
    
    [self notifyAboutSelectionChange];
}

- (void)notifyAboutContentChange
{
    for (id key in [[self.contentNotifications keyEnumerator] allObjects])
    {
        SimpleBlock block = [self.contentNotifications objectForKey:key];
        
        if (block)
        {
            block();
        }
    }
}

- (void)notifyAboutSelectionChange
{
    for (id key in [[self.selectionNotifications keyEnumerator] allObjects])
    {
        SimpleBlock block = [self.selectionNotifications objectForKey:key];
        
        if (block)
        {
            block();
        }
    }
}

#pragma mark - Add to selection

- (void)addObjectToSelection:(id)object
{
    ArrayItemWrapper *targetWrapper = nil;
    
    //===
    
    for (ArrayItemWrapper *wrapper in _store)
    {
        if ([wrapper.content isEqual:object])
        {
            targetWrapper = wrapper;
            break;
        }
    }
    
    //===
    
    if (targetWrapper)
    {
        BOOL canProceed = [self willChangeSelectionWithObject:object
                                                   changeType:kAddEMAChangeType];
        
        //===
        
        if (canProceed)
        {
            targetWrapper.selected = YES;
            
            //===
            
            [self didChangeSelectionWithObject:object
                                    changeType:kAddEMAChangeType];
        }
    }
}

- (void)addObjectAtIndexToSelection:(NSUInteger)index
{
    [self addObjectToSelection:
     [self safeObjectAtIndex:index]];
}

- (void)addObjectsToSelection:(NSArray *)objectList
{
    if (objectList.count)
    {
        for (id object in objectList)
        {
            [self addObjectToSelection:object];
        }
    }
    else
    {
        NSLog(@"Nothing to add to selection list.");
    }
}

#pragma mark - Set selection

- (void)setObjectSelected:(id)object
{
    [self resetSelection];
    
    //===
    
    [self addObjectToSelection:object];
}

- (void)setObjectAtIndexSelected:(NSUInteger)index
{
    [self setObjectSelected:
     [self safeObjectAtIndex:index]];
}

- (void)setObjectsSelected:(NSArray *)objectList
{
    [self resetSelection];
    
    //===
    
    [self addObjectsToSelection:objectList];
}

#pragma mark - Remove from selection

- (void)removeObjectFromSelection:(id)object
{
    ArrayItemWrapper *targetWrapper = nil;
    
    //===
    
    for (ArrayItemWrapper *wrapper in _store)
    {
        if ([wrapper.content isEqual:object])
        {
            targetWrapper = wrapper;
            break;
        }
    }
    
    //===
    
    if (targetWrapper)
    {
        BOOL canProceed = [self willChangeSelectionWithObject:object
                                                   changeType:kRemoveEMAChangeType];
        
        //===
        
        if (canProceed)
        {
            targetWrapper.selected = NO;
            
            //===
            
            [self didChangeSelectionWithObject:object
                                    changeType:kRemoveEMAChangeType];
        }
    }
}

- (void)removeObjectAtIndexFromSelection:(NSUInteger)index
{
    [self removeObjectFromSelection:
     [self safeObjectAtIndex:index]];
}

- (void)removeObjectsFromSelection:(NSArray *)objectList
{
    for (id object in objectList)
    {
        [self removeObjectFromSelection:object];
    }
}

#pragma mark - Reset

- (void)resetSelection
{
    for (ArrayItemWrapper *wrapper in _store)
    {
        wrapper.selected = NO;
    }
}

#pragma mark - Track selection

- (void)subscribe:(id)object forContentUpdates:(SimpleBlock)notificationBlock
{
    if (object && notificationBlock)
    {
        [self.contentNotifications setObject:notificationBlock
                                      forKey:object];
    }
}

- (void)unsubscribeFromContentUpdates:(id)object
{
    [self.contentNotifications removeObjectForKey:object];
}

- (void)subscribe:(id)object forSelectionUpdates:(SimpleBlock)notificationBlock
{
    if (object && notificationBlock)
    {
        [self.selectionNotifications setObject:notificationBlock
                                        forKey:object];
    }
}

- (void)unsubscribeFromSelectionUpdates:(id)object
{
    [self.selectionNotifications removeObjectForKey:object];
}

@end
