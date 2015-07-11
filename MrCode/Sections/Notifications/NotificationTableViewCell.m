//
//  NotificationTableViewCell.m
//  MrCode
//
//  Created by hao on 7/11/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Masonry.h"
#import "GITNotification.h"
#import "NSDate+DateTools.h"
#import "UIImage+MRC_Octicons.h"

static UIImage *_GitPullRequestIcon = nil;
static UIImage *_IssueOpenedIcon = nil;

@interface NotificationTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *subjectTitleLabel;
@property (nonatomic, strong) UILabel *repoNameLabel;
@property (nonatomic, strong) UILabel *updatedLabel;

@end

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Initial

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    CGFloat horizontalPadding = 5.f;
    
    _iconImageView = [UIImageView new];
    [self.contentView addSubview:_iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(10, 10));
        make.left.equalTo(@10);
        make.top.equalTo(@8);
    }];
    
    // FIXME: 个别 title 第一次显示时 autolayout 距顶部不对，滚回来后又变正常。使用 UITableView+FDTemplateLayoutCell.h 计算高度又是正常的，奇怪。
    _subjectTitleLabel = [UILabel new];
    _subjectTitleLabel.font = [UIFont systemFontOfSize:14];
    _subjectTitleLabel.numberOfLines = 0;
    _subjectTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_subjectTitleLabel];
    [_subjectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@5);
        make.left.equalTo(_iconImageView.mas_right).offset(10);
        make.right.mas_equalTo(-10);
    }];
    
    _repoNameLabel = [UILabel new];
    _repoNameLabel.font = [UIFont systemFontOfSize:10];
    _repoNameLabel.textColor = [UIColor colorWithRed:98/255.0 green:176/255.0 blue:244/255.0 alpha:1.0];
    [self.contentView addSubview:_repoNameLabel];
    [_repoNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_subjectTitleLabel);
        make.top.equalTo(_subjectTitleLabel.mas_bottom).offset(horizontalPadding);
        make.bottom.mas_equalTo(-horizontalPadding);
    }];
    _repoNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(repoNameLabelTapped)];
    [_repoNameLabel addGestureRecognizer:tapGestureRecognizer];
    
    _updatedLabel = [UILabel new];
    _updatedLabel.font = [UIFont systemFontOfSize:10];
    _updatedLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_updatedLabel];
    [_updatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.top.equalTo(_subjectTitleLabel.mas_bottom).offset(horizontalPadding);
        make.bottom.equalTo(_repoNameLabel);
    }];
    
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.subjectTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.bounds) - 10 * 2;
}

#pragma mark - Property

- (void)setNotification:(GITNotification *)notification
{
    _notification = notification;
    
    self.subjectTitleLabel.text = self.notification.subjectTitle;
    self.repoNameLabel.text = self.notification.repository.name;
    self.updatedLabel.text = [self.notification.updatedAt timeAgoSinceNow];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize iconSize    = CGSizeMake(10.f, 10.f);
        _GitPullRequestIcon = [UIImage octicon_imageWithIdentifier:@"GitPullRequest" size:iconSize];
        _IssueOpenedIcon    = [UIImage octicon_imageWithIdentifier:@"IssueOpened" size:iconSize];
    });
    
    self.iconImageView.image = [self.notification.subjectType isEqualToString:@"Issue"] ? _IssueOpenedIcon : _GitPullRequestIcon;
}

#pragma mark - Private

- (void)repoNameLabelTapped
{
    [self.delegate notificationTabViewCellRepoNameTapped:self.notification];
}

@end
