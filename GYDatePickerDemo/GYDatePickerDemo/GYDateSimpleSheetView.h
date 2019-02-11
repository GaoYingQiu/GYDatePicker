//
//  GYDateSimpleSheetView.h
//  GYDatePickerDemo
//
//  Created by qiugaoying on 2019/2/11.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GYActionDateDoneBlock)(id selectedDate);

@interface GYDateSimpleSheetView : UIView

//标题，选中的日期，选中的结束日期，最小时间，最大时间，回调；
- (instancetype)initDatePickerMode:(UIDatePickerMode)datePickerMode
                             title:(NSString *)titleStr
                     selectedDate:(NSDate *)selectedDate
                    orignSelectedEndDateStr:(NSString *)orignSelectedEndDateStr
                      minimumDate:(NSDate *)minimumDate
                      maximumDate:(NSDate *)maximumDate
                      actionBlock:(GYActionDateDoneBlock)actionDateDoneBlock;

-(void)showInView;

- (void)hide;

@end
