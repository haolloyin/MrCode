//
//  RepositoryContentTableVC.h
//  MrCode
//
//  Created by hao on 9/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITRepository.h"

@interface RepositoryContentTableVC : UITableViewController

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) GITRepository *repo;

@end
