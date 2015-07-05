//
//  ReposTableViewCell.m
//  MrCode
//
//  Created by hao on 7/5/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "ReposTableViewCell.h"
#import "Masonry.h"
#import "UIImage+Octions.h"

@interface ReposTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *descLabel;
@property (nonatomic, strong) UIImageView *starImageView;
@property (nonatomic, strong) UILabel     *starLabel;
@property (nonatomic, strong) UIImageView *forkImageView;
@property (nonatomic, strong) UILabel     *forkLabel;
@property (nonatomic, strong) UILabel     *languageLabel;

@end

@implementation ReposTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
//    NSLog(@"reuseIdentifier: %@", reuseIdentifier);
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.iconImageView = [UIImageView new];
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.left.equalTo(@5);
        make.top.equalTo(@10);
    }];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.top.equalTo(@7);
        make.right.lessThanOrEqualTo(@-10);
    }];
    
    self.descLabel = [UILabel new];
    self.descLabel.textColor = [UIColor grayColor];
    self.descLabel.font = [UIFont systemFontOfSize:11.f];
    self.descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descLabel.textAlignment = NSTextAlignmentLeft;
    self.descLabel.numberOfLines = 0;
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.right.lessThanOrEqualTo(@-10);
    }];
    
    CGFloat verticalPadding = 5.f;
    CGFloat horizontalPadding = 2.f;
    self.starImageView = [UIImageView new];
    [self.contentView addSubview:self.starImageView];
    [self.starImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(10, 10));
        make.left.equalTo(self.descLabel);
        make.top.equalTo(self.descLabel.mas_bottom).offset(verticalPadding);
        make.bottom.mas_equalTo(-verticalPadding);
    }];
    
    self.starLabel = [UILabel new];
    self.starLabel.font = [UIFont systemFontOfSize:10.f];
    self.starLabel.numberOfLines = 1;
    [self.contentView addSubview:self.starLabel];
    [self.starLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.starImageView.mas_right).offset(2);
        make.top.equalTo(self.descLabel.mas_bottom).offset(verticalPadding);
        make.bottom.mas_equalTo(-verticalPadding);
    }];
    
    self.forkImageView = [UIImageView new];
    [self.contentView addSubview:self.forkImageView];
    [self.forkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(10, 10));
        make.left.equalTo(self.starLabel.mas_right).offset(horizontalPadding * 2);
        make.top.equalTo(self.descLabel.mas_bottom).offset(verticalPadding);
        make.bottom.mas_equalTo(-verticalPadding);
    }];
    
    self.forkLabel = [UILabel new];
    self.forkLabel.font = [UIFont systemFontOfSize:10.f];
    self.forkLabel.numberOfLines = 1;
    [self.contentView addSubview:self.forkLabel];
    [self.forkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forkImageView.mas_right).mas_offset(horizontalPadding);
        make.top.equalTo(self.descLabel.mas_bottom).offset(verticalPadding);
        make.bottom.mas_equalTo(-verticalPadding);
    }];
    
    return self;
}

- (void)configWithRepository:(GITRepository *)repo
{
    self.repo = repo;
    self.titleLabel.text = self.repo.name;
    self.descLabel.text = self.repo.desc;
    self.iconImageView.image = [UIImage octicon_imageWithIcon:repo.isForked ? @"RepoForked" : @"Repo"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor darkGrayColor]
                                                    iconScale:1.0
                                                      andSize:CGSizeMake(20, 20)];
    self.starImageView.image = [UIImage octicon_imageWithIcon:@"Star"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor darkGrayColor]
                                                    iconScale:1.0
                                                      andSize:CGSizeMake(10, 10)];
    self.forkImageView.image = [UIImage octicon_imageWithIcon:@"GitBranch"
                                              backgroundColor:[UIColor clearColor]
                                                    iconColor:[UIColor darkGrayColor]
                                                    iconScale:1.0
                                                      andSize:CGSizeMake(10, 10)];
    self.starLabel.text = [NSString stringWithFormat:@"%@", @(self.repo.stargazersCount)];
    self.forkLabel.text = [NSString stringWithFormat:@"%@", @(self.repo.forksCount)];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.descLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.contentView.bounds) - 35 - 10;
}

@end





