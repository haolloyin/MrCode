//
//  UIImage+MRC_Octicons.h
//  MrCode
//
//  Created by hao on 7/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MRC_Octicons)

+ (UIImage *)octicon_imageWithIdentifier:(NSString *)identifier size:(CGSize)size;

+ (UIImage *)octicon_imageWithIdentifier:(NSString *)identifier iconColor:(UIColor *)iconColor size:(CGSize)size;

@end
