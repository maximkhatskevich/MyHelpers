//
//  NSMutableArray+ParseHelpers.m
//  MyHelpers
//
//  Created by Maxim Khatskevich on 11/8/13.
//  Copyright (c) 2013 Maxim Khatskevich. All rights reserved.
//

#import "NSMutableArray+ParseHelpers.h"
#import "NSArray+ParseHelpers.h"
#import <Parse/Parse.h>

@implementation NSMutableArray (ParseHelpers)

- (void)safeAddUniqueParseObject:(id)object
{
    if (object &&
        [object isKindOfClass:[PFObject class]])
    {
        if (![self containsParseObject:object])
        {
            [self addObject:object];
        }
    }
}

@end
