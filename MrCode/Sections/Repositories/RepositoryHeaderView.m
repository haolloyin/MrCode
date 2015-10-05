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
#import "NSDate+DateTools.h"
#import <ChameleonFramework/Chameleon.h>

@interface RepositoryHeaderView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *updatedLabel;
@property (nonatomic, strong) UIButton    *starButton;
@property (nonatomic, strong) UIButton    *forkButton;
@property (nonatomic, strong) UIButton    *watchButton;
@property (nonatomic, strong) UILabel     *descriptionLabel;

@property (nonatomic, assign) NSUInteger starCount;
@property (nonatomic, assign) NSUInteger watchingCount;

@end

@implementation RepositoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    _iconImageView = [UIImageView new];
    _iconImageView.image = [UIImage octicon_imageWithIdentifier:@"Repo" size:CGSizeMake(30.f, 30.f)];
    [self addSubview:_iconImageView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    _titleLabel.textColor = [UIColor flatPurpleColor];
    [self addSubview:_titleLabel];
    
    _updatedLabel = [UILabel new];
    _updatedLabel.font = [UIFont systemFontOfSize:10.f];
    _updatedLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_updatedLabel];
    
    // Buttons
    _starButton = [UIButton new];
    [self setupButton:_starButton withTag:101 iconName:@"Star"];
    
    _forkButton = [UIButton new];
    [self setupButton:_forkButton withTag:102 iconName:@"GistFork"];
    
    _watchButton = [UIButton new];
    [self setupButton:_watchButton withTag:103 iconName:@"Eye"];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.font = [UIFont systemFontOfSize:12.f];
    _descriptionLabel.textColor = [UIColor grayColor];
    [self addSubview:_descriptionLabel];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.equalTo(@5);
        make.top.equalTo(@10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.top.equalTo(@10);
    }];
    
    [self.updatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    
    // Buttons
    CGFloat horizontalPadding = 15;
    [self.starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.mas_equalTo(horizontalPadding);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
    }];
    [self.forkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.starButton);
        make.left.equalTo(self.starButton.mas_right).offset(horizontalPadding);
        make.top.equalTo(self.starButton);
    }];
    [self.watchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.forkButton);
        make.left.equalTo(self.forkButton.mas_right).offset(horizontalPadding);
        make.top.equalTo(self.forkButton);
        make.right.mas_equalTo(-horizontalPadding);
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.starButton);
        make.top.equalTo(self.starButton.mas_bottom).offset(10);
        make.right.equalTo(@-15);
        make.bottom.equalTo(@-15);
    }];
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds) - 15 * 2;
}

#pragma mark - Private

- (void)setupButton:(UIButton *)button withTag:(NSUInteger)tag iconName:(NSString *)iconName
{
    button.tag = tag;
    
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 0.2;
    button.layer.borderColor = [[UIColor flatSkyBlueColorDark] CGColor];
    
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    button.enabled = YES;
    [button setUserInteractionEnabled:YES];
    [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    CGSize size = CGSizeMake(20, 20);
    [button setImage:[UIImage octicon_imageWithIdentifier:iconName size:size] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (void)tapButton:(UIButton *)button
{
    [self.delegate tapRepositoryHeaderViewButton:button];
}

#pragma mark - Property

- (void)setRepo:(GITRepository *)repo
{
    _repo = repo;
    self.titleLabel.text       = self.repo.name;
    self.updatedLabel.text     = self.repo.updatedAt.timeAgoSinceNow;
    self.descriptionLabel.text = self.repo.desc;
    // FIXME: 调用 https://developer.github.com/v3/repos/ 获取到的 Repos updated 时间好像是错的。
//    NSLog(@"NSDate: %@, formate: %@", self.repo.updatedAt, self.repo.updatedAt.timeAgoSinceNow);
    
    _isStarred = [GITRepository isStarredRepo:self.repo];
    _isWatching = NO;
    
    NSLog(@"stargazersCount=%@, watchersCount=%@", @(self.repo.stargazersCount), @(self.repo.watchersCount));

    _starCount = self.repo.stargazersCount;
    _watchingCount = self.repo.watchersCount;
    [self updateStarButtonWithStar:_isStarred];
    
    [self.forkButton setTitle:[NSString stringWithFormat:@"%@\nFork", @(self.repo.forksCount)] forState:UIControlStateNormal];
    [self.watchButton setTitle:[NSString stringWithFormat:@"%@\nWatch", @(self.repo.watchersCount)] forState:UIControlStateNormal];
}

#pragma mark - Public

- (void)updateStarButtonWithStar:(BOOL)isStarred
{
    if (_isStarred != isStarred) {
        _starCount += (isStarred ? 1 : -1);
        _isStarred = isStarred;
    }
    NSString *title = [NSString stringWithFormat:(_isStarred ? @"%@\nUnstar" : @"%@\nStar"), @(_starCount)];
    
    [self.starButton setTitleColor:(_isStarred ? [UIColor flatPurpleColor] : [UIColor darkTextColor]) forState:UIControlStateNormal];
    [self.starButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateWatchButtonWithWatch:(BOOL)isWatching
{
    NSLog(@"isWatching=%@", @(isWatching));
    
    if (_isWatching != isWatching) {
        _watchingCount += (isWatching ? 1 : -1);
        _isWatching = isWatching;
    }
    NSString *title = [NSString stringWithFormat:(_isWatching ? @"%@\nUnwatch" : @"%@\nWatch"), @(_watchingCount)];
    
    [self.watchButton setTitleColor:(_isWatching ? [UIColor flatPurpleColor] : [UIColor darkTextColor]) forState:UIControlStateNormal];
    [self.watchButton setTitle:title forState:UIControlStateNormal];
}

@end
