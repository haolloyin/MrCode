//
//  TestViewController.m
//  MrCode
//
//  Created by hao on 7/5/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "TestViewController.h"
#import "Masonry.h"

@interface TestViewController ()

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *v1;
@property (nonatomic, strong) UIView *v2;
@property (nonatomic, strong) UILabel *l1;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *str = @"2014-06-08T10:16:16Z";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSDate *date = [dateFormatter dateFromString:str];
    NSLog(@"date: %@, class: %@", date, [date class]);
    
    _superView = [UIView new];
    _superView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_superView];
    [_superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(300, 70));
        make.center.equalTo(self.view);
    }];
    
    _v1 = [UIView new];
    _v1.backgroundColor = [UIColor grayColor];
    [_superView addSubview:_v1];
    [_v1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 30));
        make.left.equalTo(@10);
        make.top.equalTo(@10);
    }];
    
    _v2 = [UIView new];
    _v2.backgroundColor = [UIColor blueColor];
    [_superView addSubview:_v2];
    [_v2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 10));
        make.left.equalTo(_v1.mas_right).offset(5);
        make.top.equalTo(@15);
    }];
    
    _l1 = [UILabel new];
    _l1.lineBreakMode = NSLineBreakByWordWrapping;
    _l1.numberOfLines = 0;
    _l1.text = @"fdafjl fljalsdj lfajls sdlfja lsdjfla flajsd flsdjfa lsdjklka\nladsj flka jldfa djfl";
    _l1.font = [UIFont systemFontOfSize:12.f];
    [_superView addSubview:_l1];
    [_l1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_v2);
        make.top.equalTo(_v2.mas_bottom).offset(10);
        make.right.lessThanOrEqualTo(@-130);
//        make.bottom.equalTo(@-2);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
