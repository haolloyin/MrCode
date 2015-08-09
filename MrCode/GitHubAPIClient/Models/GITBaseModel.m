//
//  GITBaseModel.m
//  MrCode
//
//  Created by hao on 7/9/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "GITBaseModel.h"
#import "NSString+ToNSDate.h"

@implementation GITBaseModel

- (id)newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if (oldValue != [NSNull null] && [oldValue isKindOfClass:[NSString class]] && property.type.typeClass == [NSDate class]) {
        
        // 因为 GitHub API 返回的格式是 yyyy-MM-dd'T'HH:mm:ssZ，而将 model 转成 Dictionary 来持久化时，
        // 格式又变成 yyyy-MM-dd HH:mm:ss，所以干脆一开始就格式化成 yyyy-MM-dd HH:mm:ss
        // FIXME: 给 GITRepository model 实现 NSCoding 来持久化更好
        NSString *newString = [oldValue stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        newString = [newString stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        
//        NSLog(@"oldValue: %@, newValue: %@, class: %@", oldValue, newString, [oldValue class]);
        
        NSDate *date = [oldValue toNSDate];
        return date;
    }
    
    return oldValue;
}

@end
