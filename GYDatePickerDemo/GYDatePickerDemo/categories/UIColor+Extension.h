//
//  UIColor+Extension.h
//  mp_business
//
//  Created by pengkaichang on 14-10-10.
//  Copyright (c) 2014年 com.soudoushi.makepolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)
//颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor*) colorWithHexString:(NSString*)color;
+ (UIColor *) colorWithHexString:(NSString *)color alpha:(float)alpha;
@end
