//
//  NSString+ToNSDate.m
//  MrCode
//
//  Created by hao on 7/8/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "NSString+ToNSDate.h"

static NSDateFormatter *dateFormatter = nil;

@implementation NSString (ToNSDate)

- (NSDate *)toNSDate
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return [dateFormatter dateFromString:self];
}

@end
