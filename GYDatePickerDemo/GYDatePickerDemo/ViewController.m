//
//  ViewController.m
//  GYDatePickerDemo
//
//  Created by qiugaoying on 2019/2/11.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "ViewController.h"
#import "DateFilterView.h"

@interface ViewController ()
@property(nonatomic,strong) NSString *startDate;
@property(nonatomic,strong) NSString *endDate;
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
