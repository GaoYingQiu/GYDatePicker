//
//  MenuFilterView.h
//  Ying2018
//
//  Created by qiugaoying on 2018/10/23.
//  Copyright © 2018年 qiugaoying. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GYActionDateFilterDoneBlock)(id startDate,id endDate);

@interface DateFilterView : UIView
+ (void)showInParentView:(UIView *)view fillBeginDateStr:(NSString *)beginDateStr fillEndDateStr:(NSString *)endDateStr dateConfirmBlock:(GYActionDateFilterDoneBlock )block;
@end
