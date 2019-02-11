//
//  MenuFilterView.m
//  Ying2018
//
//  Created by qiugaoying on 2018/10/23.
//  Copyright © 2018年 qiugaoying. All rights reserved.
//

#import "DateFilterView.h"
#import "GYDateSimpleSheetView.h"
#import "GYCursorView.h"

@interface DateFilterView()

@property(nonatomic,strong) GYCursorView *cursorView;
@property (nonatomic,copy) GYActionDateFilterDoneBlock confirmBlock;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UIView *parentView; //父类
@property (nonatomic,assign) BOOL operationDateChangeing; //日期是否在操作中

@property (nonatomic,strong)  UIButton *dateActionBtn;
@property (nonatomic,strong)  UIButton *endDateBtn;

@property (nonatomic,strong) NSString *beginDate;
@property (nonatomic,strong) NSString *endDate;
@end

@implementation DateFilterView
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)showInParentView:(UIView *)view fillBeginDateStr:(NSString *)beginDateStr fillEndDateStr:(NSString *)endDateStr dateConfirmBlock:(GYActionDateFilterDoneBlock )block{
    
    UIView *fv = [view viewWithTag:1009];
    if(fv){
        return ;
    }
    
    DateFilterView *filterView = [[DateFilterView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)]; 
    filterView.confirmBlock = block;
    filterView.tag = 1009;
    filterView.parentView = view;
   
    NSDate *startDate = [NSDate date];
    NSString* startDateStr = [NSString stringWithFormat:@"%04lu-%02lu-%02lu 00:00:00",(unsigned long)[startDate year], (unsigned long)[startDate month], (unsigned long)[startDate day]];
    //记录开始日期；
   
    if(beginDateStr){
        startDateStr = beginDateStr;
        startDate = [NSDate dateByStr:beginDateStr format:kSKDateFormatTypeYYYYMMDD];
    }
    filterView.beginDate = startDateStr;
    [filterView.dateActionBtn setTitle:[filterView.beginDate stringByAppendingString:@" "] forState:0];
    
    //记录结束时间；
    NSString *overDateStr =  [NSDate stringFromDate:[NSDate date] format:kSKDateFormatTypeYYYYMMDD];
    if(endDateStr){
        overDateStr = endDateStr;
    }
    filterView.endDate = overDateStr;
    [filterView.endDateBtn setTitle:[filterView.endDate stringByAppendingString:@" "] forState:0];
    
    //根据选的开始时间，选中item项
    [filterView refreshSelectItemView:startDate bRefresh:NO];
    
    [view addSubview:filterView];
    [UIView animateWithDuration:0.22
                     animations:^{
                         filterView.containerView.frame = CGRectMake(0, 0, view.frame.size.width,  98);
                     }];
}


- (void)_initSetUp {
    
     self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, -98, self.frame.size.width, 0)];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    
    //qiu
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.cursorView];
   
    [self fitDataSource];
    [self addOptionDateView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateToolChooseValueChanged:) name:@"FilterDateValueChangedEvent" object:nil];
}

    
-(GYCursorView *)cursorView
{
    if(_cursorView == nil){
        _cursorView = [[GYCursorView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 54)];
        //设置字体和颜色
        _cursorView.backgroundColor = [UIColor whiteColor];
        _cursorView.normalColor = [UIColor whiteColor];
        _cursorView.selectedColor = [UIColor blackColor];
        _cursorView.selectedFont = LJFontRegularText(12);
        _cursorView.normalFont = LJFontRegularText(12);
        _cursorView.lineEdgeInsets = UIEdgeInsetsMake(0,  3,  1, 3);
        _cursorView.lineView.hidden = YES;
        _cursorView.collectionView.scrollEnabled = YES;
        _cursorView.collectionView.showsHorizontalScrollIndicator = NO;
        
    }
    return _cursorView;
}

-(void)addOptionDateView{
    
    UIView *optionDateView= [[UIView alloc]initWithFrame:CGRectMake(0, 54, SCREEN_W, 44)];
    optionDateView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:optionDateView];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"至";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = LJFontRegularText(13);
    [optionDateView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.center.mas_equalTo(optionDateView);
    }];
    
    //开始时间
    _dateActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [optionDateView addSubview:_dateActionBtn];
    
    NSString *selectDateStr =  [NSDate stringFromDate:[NSDate date] format:kSKDateFormatTypeYYYYMMDD];
    
    [_dateActionBtn setTitle:selectDateStr forState:0];
    _dateActionBtn.tag = 1000;
    _dateActionBtn.layer.cornerRadius = 3;
    _dateActionBtn.layer.masksToBounds = YES;
    _dateActionBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    [_dateActionBtn setImage:[UIImage imageNamed:@"ic_direction_down_gold"] forState:0];
    [_dateActionBtn setImage:[UIImage imageNamed:@"ic_direction_up_gold"] forState:UIControlStateSelected];

    [_dateActionBtn addTarget:self action:@selector(clickDateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
    _dateActionBtn.titleLabel.font = LJFontRegularText(12);
    [_dateActionBtn setTitleColor:[UIColor colorWithHexString:@"#DBB76C"] forState:0];
    
    [_dateActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.equalTo(@32);
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(titleLabel.mas_left).offset(0);
    }];
    [_dateActionBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -_dateActionBtn.imageView.frame.size.width, 0, _dateActionBtn.imageView.frame.size.width)];
    [_dateActionBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _dateActionBtn.titleLabel.bounds.size.width, 0, -_dateActionBtn.titleLabel.bounds.size.width)];
    
    //结束时间
    self.endDate = selectDateStr;
    _endDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [optionDateView addSubview:_endDateBtn];
    _endDateBtn.tag = 2000;
    _endDateBtn.layer.cornerRadius = 3;
     _endDateBtn.layer.masksToBounds = YES;
    _endDateBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    [_endDateBtn setTitle:selectDateStr forState:0];
    [_endDateBtn setImage:[UIImage imageNamed:@"ic_direction_down_gold"] forState:0];
    [_endDateBtn setImage:[UIImage imageNamed:@"ic_direction_up_gold"] forState:UIControlStateSelected];
    [_endDateBtn addTarget:self action:@selector(clickDateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
    _endDateBtn.titleLabel.font = LJFontRegularText(12);
    [_endDateBtn setTitleColor:[UIColor colorWithHexString:@"#DBB76C"] forState:0];
    
    [_endDateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.height.equalTo(@32);
        make.centerY.equalTo(titleLabel);
        make.left.equalTo(titleLabel.mas_right).offset(0);
    }];
    [_endDateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -_endDateBtn.imageView.frame.size.width, 0, _endDateBtn.imageView.frame.size.width)];
    [_endDateBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _endDateBtn.titleLabel.bounds.size.width, 0, -_endDateBtn.titleLabel.bounds.size.width)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self _initSetUp];
    }
    return self;
}

-(void)clickDateFilterAction:(UIButton *)sender
{
    sender.selected = YES;
    if(sender.tag == 1000){
        [self datepickerBtnAction:YES btn:sender];
    }else{
        [self datepickerBtnAction:NO btn:sender];
    }
}

-(void)datepickerBtnAction:(BOOL)bStartFlag btn:(UIButton *)sender
{
    NSDate *chooseDate = [NSDate dateByStr:bStartFlag? self.beginDate : self.endDate format:kSKDateFormatTypeYYYYMMDD] ;
    NSDate * selectDate = chooseDate?:[NSDate date];//默认为当前时间。
    
    
    NSDate *dateNow = [NSDate date];
    NSString* nowStr = [NSString stringWithFormat:@"%04lu-%02lu-%02lu 00:00:00",(unsigned long)[dateNow year], (unsigned long)[dateNow month], (unsigned long)[dateNow day]];
    
    NSDate *maxDate = [NSDate dateByStr:nowStr format:kSKDateFormatTypeYYYYMMDDHHMMSS];
    NSDate *minDate = [maxDate dateByAddingDays:-59]; //最小时间为近三月
    if(!bStartFlag){
        //选结束时间，最小为开始时间；
        if(self.beginDate){
            minDate = [NSDate dateByStr:self.beginDate format:kSKDateFormatTypeYYYYMMDD];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    GYDateSimpleSheetView *datePicker =  [[GYDateSimpleSheetView alloc]initDatePickerMode:UIDatePickerModeDate title:bStartFlag?@"开始时间":@"结束时间" selectedDate:selectDate  orignSelectedEndDateStr:self.endDate  minimumDate:minDate maximumDate:maxDate actionBlock:^(id selectedDate) {
        
        weakSelf.operationDateChangeing = NO;
        sender.selected = NO;
        if(selectedDate){
            NSString *selectDateStr =  [NSDate stringFromDate:selectedDate format:kSKDateFormatTypeYYYYMMDD];
            if(bStartFlag){
                self.beginDate = selectDateStr;
                [weakSelf.dateActionBtn setTitle:[self.beginDate stringByAppendingString:@" "] forState:0];
            }else{
                self.endDate = selectDateStr;
                [weakSelf.endDateBtn setTitle:[self.endDate stringByAppendingString:@" "] forState:0];
            }
            
            if(weakSelf.confirmBlock){
                weakSelf.confirmBlock(weakSelf.beginDate, weakSelf.endDate);
            }
        }
    }];
    if(bStartFlag){
        datePicker.tag = 2000; //开始时间；
    }else{
        datePicker.tag = 4000;
    }
    [datePicker showInView];
}

-(void)dateToolChooseValueChanged:(NSNotification *)notification
{
    //日期改变时候；
    self.operationDateChangeing = YES;
    NSDictionary *dic = notification.object;
    NSDate *date = [dic objectForKey:@"date"];
    NSInteger statu = [[dic objectForKey:@"statu"] integerValue]; //1为开始时间；
    NSString *changeSelectDateStr =  [NSDate stringFromDate:date format:kSKDateFormatTypeYYYYMMDD];
    if(statu == 1){
         [self.dateActionBtn setTitle:[changeSelectDateStr stringByAppendingString:@" "] forState:0];
        //选择某一项；
        [self refreshSelectItemView:date bRefresh:YES];
        
        //判断当前结束时间是否小于所选开始时间，如果小于所选开始时间，则结束时间为当前时间；
        NSDate *currentEndDate = [NSDate dateByStr:self.endDate format:kSKDateFormatTypeYYYYMMDD];
        if([currentEndDate isEarlierThanDate:date]){
            //结束时间归位为今天时间；
            self.endDate = [NSDate stringFromDate:[NSDate date] format:kSKDateFormatTypeYYYYMMDD];
            [self.endDateBtn setTitle:[self.endDate stringByAppendingString:@" "] forState:0];
        }
        
        //需要归位的结束时间；
        if([dic objectForKey:@"endDate_before"]){
            
            self.endDate = [dic objectForKey:@"endDate_before"];
            [self.endDateBtn setTitle:[self.endDate stringByAppendingString:@" "] forState:0];
        }
        
    }else{
        [self.endDateBtn setTitle:[changeSelectDateStr stringByAppendingString:@" "] forState:0];
    }
}

-(void)refreshSelectItemView:(NSDate *)date  bRefresh:(BOOL)refreshFlag{
    NSInteger selectCurrentItemIndex = -1;
    if([date isToday]){
        selectCurrentItemIndex = 0;
        //今天；
    }else{
        if([date isYesterday]){
            //昨天
            selectCurrentItemIndex = 1;
        }else{
            
            //小于昨天
            if([date isEarlierThanDate:[[NSDate date] dateByAddingDays:-3]]){
                if([date isEarlierThanDate:[[NSDate date] dateByAddingDays:-7]]){
                    //小于近一周
                    selectCurrentItemIndex = 4;
                    //近30天；
                }else{
                    //近一周
                    selectCurrentItemIndex = 3;
                }
            }else{
                //近三天
                selectCurrentItemIndex = 2;
            }
        }
    }
    
    if(selectCurrentItemIndex >-1){
        self.cursorView.currentIndex = selectCurrentItemIndex;
        if(refreshFlag){
            [self.cursorView selectItemAtCurrentIndex];
        }
        [self.cursorView reloadPages];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

- (void)hide{
    
    [UIView animateWithDuration:0.22
                     animations:^{
                         
                           self.containerView.frame = CGRectMake(0, -98, self.containerView.frame.size.width, self.containerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    
}

-(void)fitDataSource
{
    NSMutableArray *extDicArr = [[NSMutableArray alloc]init];
    NSArray *arr = @[@"今天",@"昨天",@"近三天",@"近一周",@"近2个月"];
    NSInteger value = 0;
    for (NSString *vue in arr) {
        ConditionFilter *f = [[ConditionFilter alloc]init];
        f.name = vue;
        f.value = value;
        [extDicArr addObject:f];
        value ++;
    }
    
    __weak typeof(self) weakSelf = self;
    self.cursorView.selectItemBlock = ^(ConditionFilter *filter) {
        if(!weakSelf.operationDateChangeing){
            NSInteger dayDiffer = 0;
            if(filter.value == 1){
                dayDiffer = -1;
            }else if(filter.value == 2){
                dayDiffer = -2;
            }else if(filter.value == 3){
                dayDiffer = -6;
            }else if(filter.value == 4){
                dayDiffer = -59; //89
            }
            
             NSString *selectDateStr =  [NSDate stringFromDate:[[NSDate date] dateByAddingDays:dayDiffer] format:kSKDateFormatTypeYYYYMMDD];
            weakSelf.beginDate = selectDateStr;
             [weakSelf.dateActionBtn setTitle:[weakSelf.beginDate stringByAppendingString:@" "] forState:0];
            
            //结束时间归位为今天时间；
            NSDate *doEndDate = [NSDate date];
            if(dayDiffer == -1){
                doEndDate = [NSDate dateYesterday];
            }
            weakSelf.endDate = [NSDate stringFromDate:doEndDate format:kSKDateFormatTypeYYYYMMDD];
            [weakSelf.endDateBtn setTitle:[weakSelf.endDate stringByAppendingString:@" "] forState:0];
            
            [weakSelf hide];
            if(weakSelf.confirmBlock){
                weakSelf.confirmBlock(weakSelf.beginDate, weakSelf.endDate);
            }
        }
    };
    _cursorView.currentIndex = 0;
    _cursorView.extDataDicArr = extDicArr;
    
    [_cursorView selectItemAtCurrentIndex];
    //属性设置完成后，调用此方法绘制界面
    [_cursorView reloadPages];
    
}

@end
