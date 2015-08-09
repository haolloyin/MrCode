//
//  ReposTableViewCell.h
//  MrCode
//
//  Created by hao on 7/5/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITRepository.h"

@interface ReposTableViewCell : UITableViewCell

@property (nonatomic, strong) GITRepository *repo;

- (void)configWithRepository:(GITRepository *)repo;

- (void)configForksWithRepository:(GITRepository *)repo;

@end
