//
//  ViewController.m
//  GYDatePickerDemo
//
//  Created by qiugaoying on 2019/2/11.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "ViewController.h"
#import "DateFilterView.h"

#import "GYDateSimpleSheetView.h"

@interface ViewController ()
@property(nonatomic,strong) NSString *startDate;
@property(nonatomic,strong) NSString *endDate;

@property(nonatomic,strong) NSString *birthStr;
@property(nonatomic,strong) UILabel *birthDayLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"GYDatePicker";
    
    self.startDate = [NSDate stringFromDate:[NSDate date] format:kSKDateFormatTypeYYYYMMDD];
    self.endDate = self.startDate;
   
    UIView *optionDateView= [[UIView alloc]init];
    optionDateView.backgroundColor = [UIColor blackColor];
    optionDateView.layer.cornerRadius = 2;
    optionDateView.layer.masksToBounds = YES;
    [self.view addSubview:optionDateView];
    [optionDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.width.equalTo(@71);
        make.right.mas_equalTo(-15);
        make.height.equalTo(@40);
    }];
    
    UIButton  *dateActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dateActionBtn.frame = CGRectMake(0, 0, 71, 40);
    [dateActionBtn setTitle:@"时间" forState:0];
    dateActionBtn.layer.cornerRadius = 2;
    dateActionBtn.layer.masksToBounds = YES;
    [dateActionBtn setImage:[UIImage imageNamed:@"ic_screen"] forState:0];
    dateActionBtn.titleLabel.font = LJFontRegularText(12);
    [dateActionBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:0];
    [optionDateView addSubview:dateActionBtn];
    [dateActionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -dateActionBtn.imageView.frame.size.width, 0, dateActionBtn.imageView.frame.size.width)];
    [dateActionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, dateActionBtn.titleLabel.bounds.size.width, 0, -dateActionBtn.titleLabel.bounds.size.width)];
    [dateActionBtn addTarget:self action:@selector(clickDateFilterAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton  *birthDayActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [birthDayActionBtn setTitle:@"选择生日" forState:0];
    birthDayActionBtn.backgroundColor = [UIColor blackColor];
    birthDayActionBtn.layer.cornerRadius = 2;
    birthDayActionBtn.layer.masksToBounds = YES;
    birthDayActionBtn.titleLabel.font = LJFontRegularText(12);
    [birthDayActionBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:0];
    [self.view addSubview:birthDayActionBtn];
    [birthDayActionBtn addTarget:self action:@selector(clickBirthDayDateFilterAction) forControlEvents:UIControlEventTouchUpInside];
    [birthDayActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@40);
        make.center.mas_equalTo(self.view);
    }];
    
    _birthDayLabel = [[UILabel alloc]init];
    _birthDayLabel.font = LJFontRegularText(22);
    _birthDayLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_birthDayLabel];
    [_birthDayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.equalTo(birthDayActionBtn.mas_top).offset(-30);
    }];
}

-(void)clickBirthDayDateFilterAction
{
    
    NSDate *chooseDate = [NSDate dateByStr:self.birthStr format:kSKDateFormatTypeYYYYMMDD] ;
    
    NSDate *defaultDate = [NSDate dateByStr:@"1990-01-01" format:kSKDateFormatTypeYYYYMMDD]; //[NSDate date];//默认为当前时间。
    NSDate * selectDate = chooseDate?:defaultDate;
    
    
    NSDate *dateNow = [NSDate date];
    NSString* nowStr = [NSString stringWithFormat:@"%04lu-%02lu-%02lu 00:00:00",(unsigned long)[dateNow year], (unsigned long)[dateNow month], (unsigned long)[dateNow day]];
    
    NSDate *maxDate = [NSDate dateByStr:nowStr format:kSKDateFormatTypeYYYYMMDDHHMMSS];
    NSDate *minDate = [NSDate dateByStr:@"1980-01-01" format:kSKDateFormatTypeYYYYMMDD];
 
    NSString *endDate = nil;
    __weak typeof(self) weakSelf = self;
    GYDateSimpleSheetView *datePicker =  [[GYDateSimpleSheetView alloc]initDatePickerMode:UIDatePickerModeDate title:@"出生日期" selectedDate:selectDate  orignSelectedEndDateStr:endDate  minimumDate:minDate maximumDate:maxDate actionBlock:^(id selectedDate) {
        
        if(selectedDate){
            NSString *selectDateStr =  [NSDate stringFromDate:selectedDate format:kSKDateFormatTypeYYYYMMDD];
            weakSelf.birthStr =  selectDateStr;
            weakSelf.birthDayLabel.text = selectDateStr;
            NSLog(@"选择的生日是%@",selectDateStr);
        }
    }];
    
    datePicker.tag = 2000;
    [datePicker showInView];
}


-(void)clickDateFilterAction
{
    __weak typeof(self) weakSelf = self;
    [DateFilterView showInParentView:self.view fillBeginDateStr:self.startDate fillEndDateStr:self.endDate  dateConfirmBlock:^(id startDate, id endDate)  {
        weakSelf.startDate = startDate;
        weakSelf.endDate = endDate;
        [weakSelf requestServerAPIByDateParam];
    }];
}


//根据开始时间，结束时间参数 请求服务器
-(void)requestServerAPIByDateParam
{
    
}
@end
