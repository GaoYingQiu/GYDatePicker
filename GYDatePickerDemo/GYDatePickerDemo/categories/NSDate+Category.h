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

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate (Category)

-(NSString *) getTourstrageUpdateTimeString:(NSString *)updateTime;


+ (NSString*)timeStrFromServer:(NSString*)serverDateStr;//服务器获取的时间戳转时间格式的字符串
- (NSString *)timeIntervalDescription;//距离当前的时间间隔描述
- (NSString *)minuteDescription;/*精确到分钟的日期描述*/
- (NSString *)formattedTime;
- (NSString *)formattedDateDescription;//格式化日期描述
//今天，昨天，日期
- (NSString *)formattedDateByDay;
//聊天列表页面和聊天信息页面使用
- (NSString *)formattedTimeYseterdayAndNext:(BOOL)isChatList;

- (double)timeIntervalSince1970InMilliSecond;
+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;

+ (NSString *)formattedTimeFromTimeInterval:(long long)time;
+ (NSString *)formattedTimeFromTimeIntervalTime:(long long)times;
+ (NSString *)formattedTimeFromTimeIntervalYesterDayTime:(long long)yesterDayTimes;

// Relative dates from the current date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;
- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;
- (BOOL) isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;
- (BOOL) isInFuture;
- (BOOL) isInPast;

// Date roles
- (BOOL) isTypicallyWorkday;
- (BOOL) isTypicallyWeekend;

// Adjusting dates
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateAtStartOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

// 拼音为显示中文日期，日期格式显示日期
typedef NS_ENUM(NSInteger, SKDateFormatType) {
    kSKDateFormatTypeYear,
    kSKDateFormatTypeYearMonth,
    kSKDateFormatTypeYYYYMM,
    kSKDateFormatTypeYYYYMMDD,
    kSKDateFormatTypeYYYYMMDD1,
    kSKDateFormatTypeYYYYMMDD2,
    kSKDateFormatTypeYYYYMMDDHHMMSS,
    kSKDateFormatTypeYYYYMMDDHHMM,
    kSKDateFormatTypeMMDD,
    kSKDateFormatTypemmdd,
    kSKDateFormatTypeMMDDHHMM,
    kSKDateFormatTypeMM_DD,
    kSKDateFormatTypeHHMM,
    kSKDateFormatTypeMM__DD,
    kSKDateFormatTypeYearMonthDay,
    kSKDateFormatTypeMMSS
};

/**
 *  将时间戳转化成字符串的格式
 *
 *  @param timeStamp  时间戳（毫秒）
 *  @param dateType 时间格式枚举
 *
 *  @return 转换时间的字符串
 */
+ (NSString *)stringFromTimeStamp:(long long)timeStamp format:(SKDateFormatType)dateType;

/**
 将日期转化成字符串的格式
 
 @param date <#date description#>
 @param dateType <#dateType description#>
 @return <#return value description#>
 */
+ (NSString *)stringFromDate:(NSDate *)date format:(SKDateFormatType)dateType;


/**
 将字符串转成时间
 
 @param str <#str description#>
 @param dateType <#dateType description#>
 @return <#return value description#>
 */
+ (NSDate *)dateByStr:(NSString *)str format:(SKDateFormatType)dateType;

+ (NSString *)hlj_formattedTimeFromTimeInterval:(long long)time;

@end
