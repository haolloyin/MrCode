//
//  RepositoryHeaderView.m
//  MrCode
//
//  Created by hao on 7/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryHeaderView.h"
#import "Masonry.h"
#import "UIImage+MRC_Octicons.h"

@interface RepositoryHeaderView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *lastUpdatedLabel;
@property (nonatomic, strong) UIButton    *starButton;
@property (nonatomic, strong) UIButton    *forkButton;
@property (nonatomic, strong) UIButton    *watchButton;
@property (nonatomic, strong) UILabel     *descriptionLabel;

@end

@implementation RepositoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    NSLog(@"");
    
    _iconImageView = [UIImageView new];
    _iconImageView.image = [UIImage octicon_imageWithIdentifier:@"Repo" size:CGSizeMake(30.f, 30.f)];
    [self addSubview:_iconImageView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self addSubview:_titleLabel];
    
    _lastUpdatedLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:11.f];
    _titleLabel.textColor = [UIColor lightTextColor];
    [self addSubview:_lastUpdatedLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSLog(@"");
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.equalTo(@5);
        make.top.equalTo(@10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10.f);
        make.top.equalTo(@10);
    }];
    
    [self.lastUpdatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
}


- (void)dealloc
{
    NSLog(@"");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Property

- (void)setRepo:(GITRepository *)repo
{
    NSLog(@"");
    _repo = repo;
    self.titleLabel.text = self.repo.name;
    self.lastUpdatedLabel.text = self.repo.updatedAt;
}

@end
