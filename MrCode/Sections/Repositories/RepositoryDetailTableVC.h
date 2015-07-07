//
//  RepositoryDetailTableVC.h
//  MrCode
//
//  Created by hao on 7/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITRepository.h"

@interface RepositoryDetailTableVC : UITableViewController

@property (nonatomic, strong) GITRepository *repo;

@end
