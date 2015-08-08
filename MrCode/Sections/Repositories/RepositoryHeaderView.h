//
//  RepositoryHeaderView.h
//  MrCode
//
//  Created by hao on 7/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GITRepository.h"

@protocol RepositoryHeaderViewDelegate <NSObject>

- (void)tapRepositoryHeaderViewButton:(UIButton *)button;

@end

@interface RepositoryHeaderView : UIView

@property (nonatomic, strong) GITRepository *repo;
@property (nonatomic, weak) id<RepositoryHeaderViewDelegate> delegate;

@end
