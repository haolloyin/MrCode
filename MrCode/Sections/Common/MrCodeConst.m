//
//  MrCodeConst.m
//  MrCode
//
//  Created by hao on 9/3/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#ifndef __MrCode_MrCodeConst_M__
#define __MrCode_MrCodeConst_M__

#import <Foundation/Foundation.h>

NSString *const MCYTKKeyValueStoreDB = @"MrCode_YTKKeyValueStore.db";
NSString *const MCReadMeFileCacheTable = @"MrCode_ReadMeFileCacheTable";

// 这些是 Desktop 下的 GitHub 样式
//NSString *const MCGitHubHTMLTemplateString = @"<html><head><meta charset='utf-8'>"
//"<link crossorigin=\"anonymous\" href=\"github1.css\" media=\"all\" rel=\"stylesheet\"/>"
//"<link crossorigin=\"anonymous\" href=\"github2.css\" media=\"all\" rel=\"stylesheet\"/>"
//"<script type=\"text/javascript\" src=\"main.js\"></script>"
//"<title>%@</title></head><body onload=\"onLoaded()\">%@</body></html>";

// 这些是 Mobile 下的 GitHub 样式
NSString *const MCGitHubHTMLTemplateString = @"<html><head><meta charset='utf-8'>"
"<link crossorigin=\"anonymous\" href=\"mobile-github.css\" media=\"all\" rel=\"stylesheet\"/>"
"<script type=\"text/javascript\" src=\"main.js\"></script>"
"<title>%@</title></head><body onload=\"onLoaded()\">%@</body></html>";


#endif
