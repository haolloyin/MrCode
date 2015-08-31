//
//  KVStoreManager.m
//  MrCode
//
//  Created by hao on 9/1/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "KVStoreManager.h"

@implementation KVStoreManager

+ (YTKKeyValueStore *)sharedStore
{
    static dispatch_once_t onceToken;
    static YTKKeyValueStore *store;
    if (!store) {
        dispatch_once(&onceToken, ^{
            store = [[YTKKeyValueStore alloc] initDBWithName:@"MrCode.db"];
        });
    }

    return store;
}

@end
