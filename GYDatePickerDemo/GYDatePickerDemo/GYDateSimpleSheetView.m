
//
//  GYDateSimpleSheetView.m
//  GYDatePickerDemo
//
//  Created by qiugaoying on 2019/2/11.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "GYDateSimpleSheetView.h"

@interface GYDateSimpleSheetView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIView *doneView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic, strong) UIPickerView* datePicker;

@property (nonatomic,copy)  NSString *title;
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;
@property (nonatomic,strong) NSDate *selectedDate;
@property (nonatomic,strong) NSDate *orignSelectedDate; //最原始选择的时间；点击取消时候显示；
@property (nonatomic,strong) NSString *orignSelectedEndDateStr;//当取消时，需归位的原结束时间字符串；

@property (nonatomic,copy) GYActionDateDoneBlock actionDateDoneBlock;

@property (nonatomic, assign) NSUInteger maxYearValue;
@property (nonatomic, assign) NSUInteger maxMonthValue;
@property (nonatomic, assign) NSUInteger maxDayValue;
//年
@property (nonatomic, assign) NSUInteger yearValue;
@property (nonatomic, strong) NSMutableArray* yearArray;
//月
@property (nonatomic, assign) NSUInteger dayValue;
@property (nonatomic, strong) NSMutableArray* monthArray;
//日
@property (nonatomic, assign) NSUInteger monthValue;
@property (nonatomic, strong) NSMutableArray* dayArray;
@end
@implementation GYDateSimpleSheetView

- (instancetype)initDatePickerMode:(UIDatePickerMode)datePickerMode
                     title:(NSString *)titleStr
                      selectedDate:(NSDate *)selectedDate
              orignSelectedEndDateStr:(NSString *)orignSelectedEndDateStr
                       minimumDate:(NSDate *)minimumDate
                       maximumDate:(NSDate *)maximumDate
                       actionBlock:(GYActionDateDoneBlock)actionDateDoneBlock
                      {
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
        
        _actionDateDoneBlock = actionDateDoneBlock;
        _selectedDate = selectedDate; //选中的
        _orignSelectedDate = selectedDate; //最原始选择的时间；；
        _orignSelectedEndDateStr = orignSelectedEndDateStr; //最原始 结束时间字符串；
        _minimumDate = minimumDate; //最小时间
        _maximumDate = maximumDate; //最大时间；
        _title = titleStr;
      
        //最大的
        _maxYearValue = [_maximumDate year];
        _maxMonthValue = [_maximumDate month];
        _maxDayValue = [_maximumDate day];
        
        //选中的；
        _yearValue = [_selectedDate year];
        _monthValue = [_selectedDate month];
        _dayValue = [_selectedDate day];
        
        [self _initSetUp];
    }
    
    return self;
}

-(void)showInView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
 
    [UIView animateWithDuration:0.3
                     animations:^{
                        self.containerView.frame = CGRectMake(0, SCREEN_H - (216 + 50), SCREEN_W ,  216 + 50);
                     }];
}


- (void)_initSetUp {
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
    self.containerView.backgroundColor =  [UIColor whiteColor];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    [self addSubview:self.containerView];
    
    [self createContentView];
    
    _doneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    [self.containerView addSubview:self.doneView];
    [_doneView addSubview:self.doneBtn];
    [_doneView addSubview:self.cancelBtn];
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.equalTo(@44);
        make.height.equalTo(@34);
        make.top.mas_equalTo(10);
        make.centerY.mas_equalTo(self.doneView);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.equalTo(@44);
        make.height.equalTo(@34);
        make.top.mas_equalTo(10);
        make.centerY.mas_equalTo(self.doneView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = LJFontRegularText(18);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text= self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_doneView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelBtn.mas_right).offset(10);
        make.right.equalTo(self.doneBtn.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.doneView);
    }];
}



#pragma mark response

- (void)doneAction:(UIButton *)sender {
    if(sender.tag == 200){
        //确定；
        if(self.selectedDate && self.actionDateDoneBlock){
            self.actionDateDoneBlock(self.selectedDate);
        }
        [self hide];
    }else{
        
        [self touchActionHideView];
    }
}

-(void)touchActionHideView
{
    //取消； （如果选择的是开始时间，取消后，需把结束时间归位： endDate_before有的情况下，且statu ==1）
    NSDictionary *dic = @{@"date":self.orignSelectedDate,@"endDate_before":self.orignSelectedEndDateStr,@"statu":self.tag==2000? @1:@0};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterDateValueChangedEvent" object:dic];
    
    if(self.selectedDate && self.actionDateDoneBlock){
        self.actionDateDoneBlock(nil);
    }
    [self hide];
}

- (void)hide{
    
    [UIView animateWithDuration:0.22
                     animations:^{
                        
                        self.containerView.frame = CGRectMake(0, self.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark setter/getter
- (UIButton *)doneBtn {
    
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] init];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        _doneBtn.tag = 200;
        [_doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = LJFontRegularText(16);
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
    
}


- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"取消"
                    forState:UIControlStateNormal];
        _cancelBtn.tag = 100;
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = LJFontRegularText(16);
        [_cancelBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchActionHideView];
}

#pragma mark -创建数据源  年月日闰年＝情况分析
-(void)createDataSource{
    
    // 年
    [self.yearArray removeAllObjects];
    
    NSInteger startYear = self.maxYearValue;
    if(self.maxYearValue != [self.minimumDate year]){
        startYear = self.maxYearValue -1;
    }
    for (NSInteger i=startYear; i<=self.maxYearValue; i++) {
        [self.yearArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    
    // 月
    [self createMonthDataSource];
 
    //日
    [self createMonthArrayWithYear:self.yearValue month:[self.selectedDate month]];
}

-(void)createMonthDataSource
{
    [self.monthArray removeAllObjects];
    NSInteger fromMonth = 1;
    NSInteger endMonth = 12;
    if([self.minimumDate year] == self.maxYearValue){
        //年份相当的情况下；
        endMonth = self.maxMonthValue; //结束月份；
        fromMonth = [self.minimumDate month]; //开始月份
    }else{
        if(_yearValue == self.maxYearValue){
            
//            fromMonth = [self.maximumDate month];  //开始月份；
            endMonth = [self.maximumDate month];
        }else{
            fromMonth = [self.minimumDate month];
        }
    }
    for (NSInteger i=fromMonth; i<=endMonth; i++) {
        [self.monthArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
    
}

-(void)createMonthArrayWithYear:(NSInteger)yearInt month:(NSInteger)monthInt{
    
    NSInteger endDate = 0;
    
    switch (monthInt) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            endDate = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            endDate = 30;
            break;
        case 2:
            // 是否为闰年
            if (yearInt % 400 == 0) {
                
                endDate = 29;
                
            } else {
                if (yearInt % 100 != 0 && yearInt %4 == 0) {
                    
                    endDate = 29;
                    
                } else {
                    
                    endDate = 28;
                    
                }
            }
            break;
        default:
            break;
    }
    
    if (self.dayValue > endDate) {
        
        self.dayValue = endDate;
    }
    
   
    NSInteger startDay = 1;
    if(self.yearValue == self.maxYearValue){
         if(self.monthValue == self.maxMonthValue){
        
             if([_title isEqualToString:@"结束时间"]){
                  startDay = [self.minimumDate day]; //开始天数；只为结束时间设置；
                  endDate = self.maxDayValue;
                 if(startDay > endDate){
                     startDay = 1;
                 }else{
                     
                     if(self.monthValue > [self.minimumDate month]){
                         startDay = 1;
                     }
                 }
                 
             }else{
                 endDate = self.maxDayValue;  //同月，同年 ，天数最大值；
             }
         }else{
             
             if(self.maxYearValue == [self.minimumDate year] &&  [self.monthArray.firstObject integerValue] == [self.minimumDate month]){
                 startDay = [self.minimumDate day];   //相同年，最小月天数为最小日开始；
             }
         }
    }else{
        //去年；
        if([self.monthArray.firstObject integerValue] == monthInt){
            startDay = [self.minimumDate day];   //去年，最小月从最小日开始，大于最小月则从1号开始；
        }else{
            startDay = 1;
        }
    }
    
    // 日
    [self.dayArray removeAllObjects];
    for(NSInteger i= startDay; i<=endDate; i++){
        [self.dayArray addObject:[NSString stringWithFormat:@"%ld",i]];
    }
}

-(void)resetDateToCurrentDate:(NSDate *)nowDate{
    
    NSInteger year  = [nowDate year];
    NSInteger yearIndex = 0;
    for(NSInteger index= 0; index<self.yearArray.count; index++){
        NSString *yearStr = [self.yearArray objectAtIndex:index];
        if([yearStr integerValue] == year){
            yearIndex = index;
            break;
        }
    }
    
    [self.datePicker selectRow:yearIndex inComponent:0 animated:YES];

    NSInteger month  = [nowDate month];
    NSInteger monthIndex = 0;
    for(NSInteger index= 0; index<self.monthArray.count; index++){
        NSString *monthStr = [self.monthArray objectAtIndex:index];
        if([monthStr integerValue] == month){
            monthIndex = index;
            break;
        }
    }
    
    [self.datePicker selectRow:monthIndex inComponent:1 animated:YES];
 
    NSInteger day  = [nowDate day];
    NSInteger dayIndex = 0;
    for(NSInteger index= 0; index<self.dayArray.count; index++){
        NSString *dayStr = [self.dayArray objectAtIndex:index];
        if([dayStr integerValue] == day){
            dayIndex = index;
            break;
        }
    }
    
    [self.datePicker selectRow:dayIndex inComponent:2 animated:YES];
 
    [self setYearValue:[nowDate year]];

    [self setMonthValue:[nowDate month]];

    [self setDayValue:[nowDate day]];
}


#pragma makr - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return  self.yearArray.count;
    }
    else if (component == 1) {
        return self.monthArray.count;
    }
    else if (component == 2) {
        return self.dayArray.count;
    }
    return 0;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    NSString *title = @"";
    if (component == 0) {
        title = [self.yearArray objectAtIndex:row];
    }
    else if (component == 1) {
        
        title = [self.monthArray objectAtIndex:row];
    }
    else if (component == 2) {
        title = [self.dayArray objectAtIndex:row];
    }

    UILabel *label = [[UILabel alloc]init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:LJFontRegularText(20)];
    [label setText:title];
    [label setTextColor:[UIColor blackColor]];
    return label;
}

- (void)clickEmpty:(UIButton*)sender
{
    [self removeFromSuperview];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    BOOL bMonthNeedChangeFlag = NO;
    //改变；
    if (component == 0){
        
        self.yearValue = [[self.yearArray objectAtIndex:row] intValue];
        if(self.yearArray.count >1){
            bMonthNeedChangeFlag = YES;
            
            //两个年份的情况下，需要重新刷新月份；
            [self createMonthDataSource];
        
            //年改变时候，刷新月份；
            [self.datePicker reloadComponent:1];
 
            //赋值当前选中的月份；
            self.monthValue = [self.monthArray.lastObject integerValue];
 
            //选中；
            [self.datePicker selectRow:self.monthArray.count-1 inComponent:1 animated:NO];
        }
    }else if(component == 1){
        
        self.monthValue = [[self.monthArray objectAtIndex:row] intValue];
        bMonthNeedChangeFlag = YES;
        
    } else if(component == 2){
        
        self.dayValue = [[self.dayArray objectAtIndex:row]intValue];
    }
        
   if (bMonthNeedChangeFlag) {
        //选择年或者月 更改天；
        [self createMonthArrayWithYear:self.yearValue month:self.monthValue];
        [self.datePicker reloadComponent:2];

        self.dayValue = [self.dayArray.lastObject integerValue];
        [self.datePicker selectRow:self.dayArray.count-1 inComponent:2 animated:NO];
    }
    
    NSString* str = [NSString stringWithFormat:@"%04lu-%02lu-%02lu 00:00:00",(unsigned long)self.yearValue, (unsigned long)self.monthValue, (unsigned long)self.dayValue];
    self.selectedDate = [NSDate dateByStr:str format:kSKDateFormatTypeYYYYMMDDHHMMSS];
    
    if([self.selectedDate isEarlierThanDate:self.minimumDate]){
        NSLog(@"不合法时间");
    }else{
        NSDictionary *dic = @{@"date":self.selectedDate,@"statu":self.tag==2000? @1:@0};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterDateValueChangedEvent" object:dic];
    }
}

- (void)createContentView
{
    NSMutableArray* tempArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray3 = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setYearArray:tempArray1];
    [self setMonthArray:tempArray2];
    [self setDayArray:tempArray3];
    
    // 数据源
    [self createDataSource];
    
    #pragma mark 时间日期View
    UIView * datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0,50, self.frame.size.width, 216)];
 
    // 初始化各个视图
    self.datePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 0,  datePickerView.frame.size.width, datePickerView.frame.size.height)];
    [datePickerView addSubview:self.datePicker];
    [self.containerView addSubview:datePickerView];
    
    [self.datePicker setDataSource:self];
    [self.datePicker setDelegate:self];
    [self.datePicker setShowsSelectionIndicator:YES];
    
    [self resetDateToCurrentDate:_selectedDate];
}

@end
