//
//  GITBaseModel.h
//  MrCode
//
//  Created by hao on 7/9/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface GITBaseModel : NSObject

- (id)newValueFromOldValue:(id)oldValue property:(MJProperty *)property;

@end
