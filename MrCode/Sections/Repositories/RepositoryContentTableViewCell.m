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

- (void)configWithGitContent:(GITRepositoryContent *)gitContent
{
    if (!gitContent) {
        return;
    }
    
    self.textLabel.font = [UIFont systemFontOfSize:13];
    self.textLabel.text = gitContent.name;
    
    if ([gitContent.type isEqualToString:@"file"]) {
        self.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileCode" size:CGSizeMake(20, 20)];
    } else if ([gitContent.type isEqualToString:@"dir"]) {
        self.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileDirectory" size:CGSizeMake(20, 20)];
    }
}

@end
