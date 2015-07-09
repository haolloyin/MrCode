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
    if (oldValue != [NSNull null] && property.type.typeClass == [NSDate class]) {
//        NSLog(@"oldValue: %@, class: %@", oldValue, [oldValue class]);
        NSDate *date = [oldValue toNSDate];
        return date;
    }
    
    return oldValue;
}

@end
