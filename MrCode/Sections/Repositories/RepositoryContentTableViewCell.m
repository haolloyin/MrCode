//
//  RepositoryContentTableViewCell.m
//  MrCode
//
//  Created by hao on 9/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryContentTableViewCell.h"
#import "UIImage+MRC_Octicons.h"
#import "GITRepository.h"

@implementation RepositoryContentTableViewCell

- (void)setGitContent:(GITRepositoryContent *)gitContent
{
    _gitContent = gitContent;
    self.textLabel.text = _gitContent.name;
    
    if ([_gitContent.type isEqualToString:@"file"]) {
        self.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileCode" size:CGSizeMake(20, 20)];
    } else if ([_gitContent.type isEqualToString:@"dir"]) {
        self.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileDirectory" size:CGSizeMake(20, 20)];
    }
}

@end
