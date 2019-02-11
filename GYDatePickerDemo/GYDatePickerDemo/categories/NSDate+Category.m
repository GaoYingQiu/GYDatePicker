/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "NSDate+Category.h"
#import "NSDateFormatter+Category.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Category)

//服务器时间转本地时间
+ (NSString*)timeStrFromServer:(NSString*)serverDateStr
{
    
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:[serverDateStr doubleValue]/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeStr = [formatter stringFromDate:d];
    return timeStr;
}


/*距离当前的时间间隔描述*/
- (NSString *)timeIntervalDescription
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < 60) {
        return NSLocalizedString(@"NSDateCategory.text1", @"");
    } else if (timeInterval < 3600) {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text2", @""), timeInterval / 60];
    } else if (timeInterval < 86400) {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text3", @""), timeInterval / 3600];
    } else if (timeInterval < 2592000) {//30天内
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text4", @""), timeInterval / 86400];
    } else if (timeInterval < 31536000) {//30天至1年内
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text5", @"")];
        return [dateFormatter stringFromDate:self];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text6", @""), timeInterval / 31536000];
    }
}

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription
{
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:NSLocalizedString(@"NSDateCategory.text7", @'"'), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) {//间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
}


//显示XX月XX日格式
-(NSString *)formattedTimeMonthAndDay{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日"];
    ret = [dateFormatter stringFromDate:self];
    return ret;
}

//聊天天信息页面，和聊天列表页面使用
- (NSString *)formattedTimeYseterdayAndNext:(BOOL)isChatList {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    NSInteger hour = [self hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
       if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
      
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        }else if (hour < 0 && hour >= -24) {
            if (isChatList) {
                
                return @"昨天";
            }else{
                dateFormatter=[NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text8", @"")];//昨天
            }
        }else if (hour < -24 && hour >= -48) {//前天
            if (isChatList) {
                
                return @"前天";
            }else{
                dateFormatter=[NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text15", @"")];//前天
            }
        }else {
            
            dateFormatter =  isChatList?[NSDateFormatter dateFormatterWithFormat:@"MM月dd日"]:[NSDateFormatter dateFormatterWithFormat:@"MM月dd日 HH:mm"];
        }
    }else {
        if (hour >= 0 && hour < 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"hh:mm"];//凌晨
        }else if (hour >= 6 && hour <12 ) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"hh:mm"];//早上
            
        }else if (hour >= 12 && hour < 13) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"hh:mm"];//中午
        }
        else if (hour >= 13 && hour < 18) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"hh:mm"];//下午
        }else if (hour >= 18 && hour < 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"hh:mm"];//晚上
        }else if (hour < 0 && hour >= -24){
            //      昨天****************
            if (isChatList) {
                return @"昨天";
            }else{
                   dateFormatter=[NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text8", @"")];//昨天
            }
        }else if (hour < -24 && hour >= -48){
            //      昨天****************
            if (isChatList) {//聊天列表
                return @"前天";
            }else{//聊天信息
                dateFormatter=[NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text15", @"")];//前天
            }
        }else  {
            dateFormatter =  isChatList?[NSDateFormatter dateFormatterWithFormat:@"MM月dd日"]:[NSDateFormatter dateFormatterWithFormat:@"MM月dd日 HH:mm"];
        }
    }
    ret = [dateFormatter stringFromDate:self];
    return ret;
}

/*标准时间日期描述*/
-(NSString *)formattedTime{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    NSInteger hour = [self hoursAfterDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
//    NSLog(@"当前时间 is %ld",(long)[comps weekday]);
    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        }else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text8", @"")];
        }else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM-dd hh:mm"];
        }
    }else {
        if (hour >= 0 && hour < 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"凌晨 hh:mm"];
        }else if (hour >= 6 && hour <12 ) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"早上 hh:mm"];
           
        }else if (hour >= 12 && hour < 13) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"中午 hh:mm"];
        }
        else if (hour >= 13 && hour < 18) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午 hh:mm"];
        }else if (hour >= 18 && hour < 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上 hh:mm"];
        }else if (hour < 0 && hour >= -24){
            //      昨天****************
            if (hour < 0 && hour > -6) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"昨天晚上 HH:mm"];
            }else if (hour <= -6 && hour > -12 ) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天下午 HH:mm"];
                
            }else if (hour <= -12 && hour > -13) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"昨天中午 HH:mm"];
            }
            else if (hour <= -13 && hour > -18) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天上午 HH:mm"];
            }else if (hour <= -18 && hour >= -24) {
                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天凌晨 HH:mm"];
            }
        }else  {
              dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM-dd hh:mm"];
            }
    }
    ret = [dateFormatter stringFromDate:self];
    return ret;
}
/*
 -(NSString *)formattedTime{
 
 NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
 [formatter setDateFormat:@"YYYY-MM-dd"];
 NSString * dateNow = [formatter stringFromDate:[NSDate date]];
 NSDateComponents *components = [[NSDateComponents alloc] init];
 [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
 [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
 [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
 NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
 NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
 
 
 NSInteger hour = [self hoursAfterDate:date];
 //    NSLog(@"时间---拉%ld",(long)hour);
 NSDateFormatter *dateFormatter = nil;
 NSString *ret = @"";
 
 //hasAMPM==TURE为12小时制，否则为24小时制
 NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
 NSRange containsA = [formatStringForHours rangeOfString:@"a"];
 BOOL hasAMPM = containsA.location != NSNotFound;
 
 
 //         NSDateComponents *comps = [[NSDateComponents alloc] init];
 NSInteger unitFlags =NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekdayCalendarUnit |
 NSHourCalendarUnit |NSMinuteCalendarUnit | NSSecondCalendarUnit;
 
 NSDateComponents*  comps = [gregorian components:unitFlags fromDate:date];
 //    NSLog(@"当前时间 is %ld",(long)[comps weekday]);
 
 if (!hasAMPM) { //24小时制
 if (hour <= 24 && hour >= 0) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
 }else if (hour < 0 && hour >= -24) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:NSLocalizedString(@"NSDateCategory.text8", @"")];
 }else {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日"];
 }
 }else {
 if (hour >= 0 && hour < 6) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"凌晨 hh:mm"];
 }else if (hour >= 6 && hour <12 ) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"早上 hh:mm"];
 
 }else if (hour >= 12 && hour < 13) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"中午 hh:mm"];
 }
 else if (hour >= 13 && hour < 18) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午 hh:mm"];
 }else if (hour >= 18 && hour < 24) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上 hh:mm"];
 }else if (hour < 0 && hour >= -24){
 //      昨天****************
 if (hour < 0 && hour > -6) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"昨天晚上 HH:mm"];
 }else if (hour <= -6 && hour > -12 ) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天下午 HH:mm"];
 
 }else if (hour <= -12 && hour > -13) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"昨天中午 HH:mm"];
 }
 else if (hour <= -13 && hour > -18) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天上午 HH:mm"];
 }else if (hour <= -18 && hour >= -24) {
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天凌晨 HH:mm"];
 }
 
 
 }else  {
 
 //            if([self isCurrentWeek:date]){
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat:[self weekDayWithDate:date withHours:hour]];
 //            }else{
 //                [formatter setDateFormat:@"YYYY-MM-dd"];
 dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日"];
 }
 //            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 HH:mm"];
 //            NSInteger temp =   hour/(-24);
 //
 //            if (temp >= 0 && temp < 6) {
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"MM月dd日 凌晨hh:mm"];
 //            }else if (temp >= 6 && temp <12 ) {
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 早上hh:mm"];
 //            }else if (hour >= 12 && hour < 13) {
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat: @"MM月dd日 中午hh:mm"];
 //            }
 //            else if (temp >= 13 && temp < 18) {
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 下午hh:mm"];
 //            }else if (temp >= 18 && temp < 24) {
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 晚上hh:mm"];
 //            }else if (temp < 0 && temp >= -24){
 //                dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"MM月dd日 昨天HH:mm"];
 //            }
 //        }
 
 }
 
 ret = [dateFormatter stringFromDate:self];
 return ret;
 }
 
 */
- (NSString *)formattedDateByDay
{
    if ([self isToday]) {
        return @"今天";
    }
//    else if ([self isYesterday])
//    {
//        return @"昨天";
//    }
//
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *theDay = [dateFormatter stringFromDate:self];
        return theDay;
    }
    
}


/*格式化日期描述*/
- (NSString *)formattedDateDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
    NSInteger timeInterval = - [self timeIntervalSinceNow];
    if (timeInterval < 60) {
        return @"1分钟内";
    } else if (timeInterval < 3600) {//1小时内
        return [NSString stringWithFormat:@"%ld分钟前", timeInterval / 60];
    } else if (timeInterval < 21600) {//6小时内
        return [NSString stringWithFormat:@"%ld小时前", timeInterval / 3600];
    } else if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"今天 %@", [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    }
    else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        return [dateFormatter stringFromDate:self];
    }
}

- (double)timeIntervalSince1970InMilliSecond {
    double ret;
    ret = [self timeIntervalSince1970] * 1000;
    
    return ret;
}

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(timeIntervalInMilliSecond > 140000000000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

+ (NSString *)formattedTimeFromTimeInterval:(long long)time{
    return [[NSDate dateWithTimeIntervalInMilliSecondSince1970:time] formattedTime];
}
+ (NSString *)formattedTimeFromTimeIntervalTime:(long long)times{
    return [[NSDate dateWithTimeIntervalInMilliSecondSince1970:times] formattedTimeMonthAndDay];
}
+ (NSString *)formattedTimeFromTimeIntervalYesterDayTime:(long long)yesterDayTimes{
    return [[NSDate dateWithTimeIntervalInMilliSecondSince1970:yesterDayTimes] formattedTimeYseterdayAndNext:YES];
}
#pragma mark Relative Dates

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL) isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

-(NSString *) getTourstrageUpdateTimeString:(NSString *)updateTime{
    
    NSDate *date1= [NSDate dateWithTimeIntervalSince1970:[updateTime doubleValue]/1000];
    NSInteger timeInterval = -[date1 timeIntervalSinceNow];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [greCalendar setTimeZone: timeZone];
    NSDateComponents *dateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:[NSDate date]];
    //  定义一个NSDateComponents对象，设置一个时间点
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    [dateComponentsForDate setDay:dateComponents.day];
    [dateComponentsForDate setMonth:dateComponents.month];
    [dateComponentsForDate setYear:dateComponents.year];
    [dateComponentsForDate setHour:00];
    [dateComponentsForDate setMinute:00];
    
    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];
    NSInteger hour = [self hoursAfterDate:dateFromDateComponentsForDate];
    if(hour>=0){
        if (timeInterval < 60) {
            //        return NSLocalizedString(@"NSDateCategory.text1", @"");
            return @"1分钟内";
        } else if (timeInterval < 3600) {//1小时内
            NSLog(@"hh %ld",timeInterval / 60);
            return  [NSString stringWithFormat:@"%ld分钟前", timeInterval / 60];
        } else {//当天
            return  [NSString stringWithFormat:@"%ld小时前", hour];
            
        }
    }else if (hour < 0 && hour >=-24) {//昨天
        return @"1天前";
    }else{
        
        return @"2天前";
    }
        return nil;
}

- (BOOL) isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.week != components2.week) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSYearCalendarUnit fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates

- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *) dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark Decomposing Dates

- (NSInteger) nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSHourCalendarUnit fromDate:newDate];
    return components.hour;
}

- (NSInteger) hour
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}

- (NSInteger) minute
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger) seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger) day
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger) month
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger) week
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.week;
}

- (NSInteger) weekday
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger) year
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.year;
}


-(BOOL)isCurrentWeek:(NSDate *)dateStr{
//    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *date=[dateFormatter dateFromString:dateStr];
 
    NSDate *date=dateStr;
    NSDate *start;
    NSTimeInterval extends;
    
    NSCalendar *cal=[NSCalendar autoupdatingCurrentCalendar];
    [cal setFirstWeekday:2];//一周的第一天设置为周一
    NSDate *today=[NSDate date];
    
    BOOL success= [cal rangeOfUnit:NSWeekCalendarUnit startDate:&start interval: &extends forDate:today];
    
    if(!success)
        return NO;
    
    NSTimeInterval dateInSecs = [date timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs= [start timeIntervalSinceReferenceDate];
    
    if(dateInSecs >= dayStartInSecs && dateInSecs < (dayStartInSecs+extends)){
        return YES;
    }
    else {
        return NO;
    }
    
}

-(NSString *)weekDayWithDate:(NSDate *)date  withHours:(NSInteger) hour{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *fromdate=[dateFormatter dateFromString:date];
    
    
    NSDate *fromdate=date;
//    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekDayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:fromdate];
    NSInteger mDay = [weekDayComponents weekday];
    
    
    
    
    NSInteger hours;
   
    NSString *week=@"";
    hours = (-hour) % 24;
    NSLog(@"时间 %ld", hours);
    NSString *timeStr = @"";
    if (hours >= 0 && hours < 6) {
//        timeStr = [NSString stringWithFormat:@"凌晨"];
        timeStr = @"晚上";
    }else if (hours >= 6 && hours < 12 ) {
        timeStr = @"下午";
//        timeStr = [NSString stringWithFormat:@"早上"];
    }else if (hours >= 12 && hours < 13) {
        timeStr = @"中午";
//        timeStr = [NSString stringWithFormat:@"中午"];
    }
    else if (hours >= 13 && hours < 18) {
        timeStr = @"上午";
//        timeStr = [NSString stringWithFormat:@"下午"];
    }else if (hours >= 18 && hours < 24) {
        timeStr = @"凌晨";
//        timeStr = [NSString stringWithFormat:@"晚上"];
    }
NSLog(@"时间 %@", timeStr);
    switch (mDay) {
        case 0:{
            week=[NSString stringWithFormat:@"周日 %@HH:mm",timeStr];
            
            break;
        }
        case 1:{
            week=[NSString stringWithFormat:@"周日 %@HH:mm",timeStr];
            break;
        }
        case 2:{
            week=[NSString stringWithFormat:@"周一 %@HH:mm",timeStr];
            break;
        }
        case 3:{
            week=[NSString stringWithFormat:@"周二 %@HH:mm",timeStr];
            break;
        }
        case 4:{
            week=[NSString stringWithFormat:@"周三 %@HH:mm",timeStr];
            break;
        }
        case 5:{
            week=[NSString stringWithFormat:@"周四 %@HH:mm",timeStr];
            break;
        }
        case 6:{
            week=[NSString stringWithFormat:@"周五 %@HH:mm",timeStr];
            break;
        }
        case 7:{
            week=[NSString stringWithFormat:@"周六 %@HH:mm",timeStr];
            break;
        }
        default:{
            break;
        }
    };
    return week;
}

+ (NSString *)stringFromTimeStamp:(long long)timeStamp format:(SKDateFormatType)dateType {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *format = @"yyyy-MM-dd HH:mm";
    switch (dateType) {
        case kSKDateFormatTypeYear:
            format = @"yyyy";
            break;
        case kSKDateFormatTypeYearMonth:
            format = @"yyyy年MM月";
            break;
        case kSKDateFormatTypeYYYYMM:
            format = @"yyyy-MM";
            break;
        case kSKDateFormatTypeYYYYMMDD:
            format = @"yyyy-MM-dd";
            break;
        case kSKDateFormatTypeYYYYMMDD1:
            format = @"yyyyMMdd";
            break;
        case kSKDateFormatTypeYYYYMMDD2:
            format = @"yyyy/MM/dd";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMMSS:
            format = @"yyyy-MM-dd HH:mm:ss";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMM:
            format = @"yyyy-MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMMDD:
            format = @"MM月dd日";
            break;
        case kSKDateFormatTypeMMDDHHMM:
            format = @"MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMM_DD:
            format = @"MM-dd";
            break;
        case kSKDateFormatTypeHHMM:
            format = @"HH:mm";
            break;
        case kSKDateFormatTypeMM__DD:
            format = @"MM/dd";
            break;
        case kSKDateFormatTypeYearMonthDay:
            format = @"yyyy年MM月dd日";
            break;
        case kSKDateFormatTypeMMSS:
            format = @"mm:ss";
            break;
        case kSKDateFormatTypemmdd:
            format = @"M月d日";
            break;
        default:
            break;
    }
    df.dateFormat = format;
    NSString *timeStampString = [NSString stringWithFormat:@"%lld", timeStamp];
    NSTimeInterval _interval = 0;
    if(timeStampString.length > 10){
        _interval=[[timeStampString substringToIndex:10] doubleValue];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    return [df stringFromDate:date];
}

+ (NSString *) stringFromDate:(NSDate *)date format:(SKDateFormatType)dateType {
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *format = @"yyyy-MM-dd HH:mm";
    switch (dateType) {
        case kSKDateFormatTypeYear:
            format = @"yyyy";
            break;
        case kSKDateFormatTypeYearMonth:
            format = @"yyyy年MM月";
            break;
        case kSKDateFormatTypeYYYYMM:
            format = @"yyyy-MM";
            break;
        case kSKDateFormatTypeYYYYMMDD:
            format = @"yyyy-MM-dd";
            break;
        case kSKDateFormatTypeYYYYMMDD1:
            format = @"yyyyMMdd";
            break;
        case kSKDateFormatTypeYYYYMMDD2:
            format = @"yyyy/MM/dd";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMMSS:
            format = @"yyyy-MM-dd HH:mm:ss";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMM:
            format = @"yyyy-MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMMDD:
            format = @"MM月dd日";
            break;
        case kSKDateFormatTypeMMDDHHMM:
            format = @"MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMM_DD:
            format = @"MM-dd";
            break;
        case kSKDateFormatTypeHHMM:
            format = @"HH:mm";
            break;
        case kSKDateFormatTypeMM__DD:
            format = @"MM/dd";
            break;
        case kSKDateFormatTypeYearMonthDay:
            format = @"yyyy年MM月dd日";
            break;
        case kSKDateFormatTypeMMSS:
            format = @"mm:ss";
            break;
        case kSKDateFormatTypemmdd:
            format = @"M月d日";
            break;
        default:
            break;
    }
    df.dateFormat = format;
    return [df stringFromDate:date];
}

+ (NSDate *)dateByStr:(NSString *)str format:(SKDateFormatType)dateType {
    NSString *format = @"yyyy-MM-dd HH:mm:ss";
    switch (dateType) {
        case kSKDateFormatTypeYear:
            format = @"yyyy";
            break;
        case kSKDateFormatTypeYearMonth:
            format = @"yyyy年MM月";
            break;
        case kSKDateFormatTypeYYYYMM:
            format = @"yyyy-MM";
            break;
        case kSKDateFormatTypeYYYYMMDD:
            format = @"yyyy-MM-dd";
            break;
        case kSKDateFormatTypeYYYYMMDD1:
            format = @"yyyyMMdd";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMMSS:
            format = @"yyyy-MM-dd HH:mm:ss";
            break;
        case kSKDateFormatTypeYYYYMMDDHHMM:
            format = @"yyyy-MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMMDD:
            format = @"MM月dd日";
            break;
        case kSKDateFormatTypeMMDDHHMM:
            format = @"MM-dd HH:mm";
            break;
        case kSKDateFormatTypeMM_DD:
            format = @"MM-dd";
            break;
        case kSKDateFormatTypeHHMM:
            format = @"HH:mm";
            break;
        case kSKDateFormatTypeMM__DD:
            format = @"MM/dd";
            break;
        case kSKDateFormatTypeYearMonthDay:
            format = @"yyyy年MM月dd日";
            break;
        case kSKDateFormatTypeMMSS:
            format = @"mm:ss";
            break;
        case kSKDateFormatTypemmdd:
            format = @"M月d日";
            break;
        default:
            break;
    }
    
    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]]; //en_US
    [inputFormatter setDateFormat:format];
    
    NSDate *inputDate = [inputFormatter dateFromString:str];
    return inputDate;
}

+ (NSString *)hlj_formattedTimeFromTimeInterval:(long long)time {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
    NSDate *now = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([date isToday]) {
        
//        NSInteger hour = [date hoursBeforeDate:now];
//        if (hour >= 1) {
        
            [formatter setDateFormat:@"HH:mm"];
            return  [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
//        }
//
//        NSInteger minute = [date minutesBeforeDate:now];
//        if (hour >= 0 && minute >= 3) {
//            return [NSString stringWithFormat:@"%ld分钟前",(long)minute];
//        }
//
//        if (hour >= 0 && minute >= 0) {
//            return @"刚刚";
//        }
    }
    
    
    
    if ([date isYesterday]) {
        return @"昨天";
//        [formatter setDateFormat:@"HH:mm"];
//        return  [NSString stringWithFormat:@"昨天 %@",[formatter stringFromDate:date]];
//    }else if ( [date isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]]){
//        [formatter setDateFormat:@"HH:mm"];
//        return  [NSString stringWithFormat:@"前天 %@",[formatter stringFromDate:date]];
    }else{
    
        [formatter setDateFormat:@"yyyy-MM-dd"];
        return [formatter stringFromDate:date];
    }
    
}

@end
