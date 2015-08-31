//
//  KVStoreManager.h
//  MrCode
//
//  Created by hao on 9/1/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"

@interface KVStoreManager : NSObject

+ (YTKKeyValueStore *)sharedStore;

@end
