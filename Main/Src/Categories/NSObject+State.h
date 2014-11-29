//
//  NSObject+State.h
//  CocoaTouchHelpers
//
//  Created by Maxim Khatskevich on 12/10/13.
//  Copyright (c) 2013 Maxim Khatskevich. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kUnknownObjectState = 0 // "unset"
}
ObjectState;

//===

typedef BOOL (^StateWillChangeBlock)(NSInteger currentState, NSInteger targetState);
typedef void (^StateDidChangeBlock)(NSInteger previousState, NSInteger currentState);

//===

@interface NSObject (State)

@property NSInteger state;

@property (strong, nonatomic) StateWillChangeBlock onStateWillChange;
@property (strong, nonatomic) StateDidChangeBlock onStateDidChange;

- (void)setOnStateWillChange:(StateWillChangeBlock)onStateWillChange;
- (void)setOnStateDidChange:(StateDidChangeBlock)onStateDidChange;

- (void)switchToState:(NSInteger)targetState;

@end
