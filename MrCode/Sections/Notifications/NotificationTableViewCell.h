//
//  NotificationTableViewCell.h
//  MrCode
//
//  Created by hao on 7/11/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GITNotification;

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) GITNotification *notification;

@end
