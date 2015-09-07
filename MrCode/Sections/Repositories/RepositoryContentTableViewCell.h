//
//  RepositoryContentTableViewCell.h
//  MrCode
//
//  Created by hao on 9/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GITRepositoryContent;

@interface RepositoryContentTableViewCell : UITableViewCell

@property (nonatomic, strong) GITRepositoryContent *gitContent;

@end
