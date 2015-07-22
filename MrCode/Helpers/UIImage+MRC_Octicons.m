//
//  UIImage+MRC_Octicons.m
//  MrCode
//
//  Created by hao on 7/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "UIImage+MRC_Octicons.h"
#import "UIImage+Octions.h"

@implementation UIImage (MRC_Octicons)

+ (UIImage *)octicon_imageWithIdentifier:(NSString *)identifier size:(CGSize)size
{
    UIColor *bgColor   = [UIColor clearColor];
    UIColor *iconColor = [UIColor grayColor];
    
    return [UIImage octicon_imageWithIcon:identifier backgroundColor:bgColor iconColor:iconColor iconScale:1.0 andSize:size];
}

+ (UIImage *)octicon_imageWithIdentifier:(NSString *)identifier iconColor:(UIColor *)iconColor size:(CGSize)size
{
    UIColor *bgColor   = [UIColor clearColor];
    return [UIImage octicon_imageWithIcon:identifier backgroundColor:bgColor iconColor:iconColor iconScale:1.0 andSize:size];
}

@end
