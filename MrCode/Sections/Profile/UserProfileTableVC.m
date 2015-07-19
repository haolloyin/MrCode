//
//  UserProfileTableVC.m
//  MrCode
//
//  Created by hao on 7/19/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "UserProfileTableVC.h"
#import "UserProfileHeaderView.h"
#import "GITUser.h"

@interface UserProfileTableVC ()

@property (nonatomic, strong) UserProfileHeaderView *headerView;

@end

@implementation UserProfileTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.tableView.tableHeaderView) {
        self.headerView = [[UserProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50.f)];
        self.tableView.tableHeaderView = self.headerView;
    }
    
    [self fetchUserProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private

- (void)fetchUserProfile
{
    NSLog(@"");
    if (!self.user) {
        [GITUser authenticatedUserWithSuccess:^(GITUser *user) {
            self.user = user;
            self.headerView.user = self.user;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else {
        [GITUser userWithUserName:self.user.login success:^(GITUser *user) {
            self.user = user;
            self.headerView.user = self.user;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

#pragma mark - Property

- (void)setUser:(GITUser *)user
{
    _user = user;
    self.headerView.user = self.user;
}

@end
