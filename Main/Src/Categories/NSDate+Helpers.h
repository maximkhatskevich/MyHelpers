//
//  NSDate+Helpers.h
//  CocoaTouchHelpers
//
//  Created by Maxim Khatskevich on 11/15/13.
//  Copyright (c) 2013 Maxim Khatskevich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helpers)

// returns local current date/time for 'targetTimeZone', NOT in UTC:
+ (NSDate *)currentDateForTimeZone:(NSTimeZone *)targetTimeZone;

// returns local date/time for 'sourceDateInUTC' and 'targetTimeZone', NOT in UTC:
+ (NSDate *)dateForDate:(NSDate *)sourceDateInUTC andTimeZone:(NSTimeZone *)targetTimeZone;

- (NSString *)dayOfWeekWithTimeZone:(NSTimeZone *)targetTimeZone;
- (NSString *)relativeDayNameWithBaseDate:(NSDate *)baseDate;

- (NSDateComponents *)defaultComponents;

- (NSString *)stringWithFormat:(NSString *)format timeZone:(NSTimeZone *)targetTimeZone;

+ (NSCalendarUnit)defaultCalendarUnits;

+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)dateFormat;

@end
