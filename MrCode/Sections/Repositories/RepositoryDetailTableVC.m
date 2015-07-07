//
//  RepositoryDetailTableVC.m
//  MrCode
//
//  Created by hao on 7/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryDetailTableVC.h"
#import "RepositoryHeaderView.h"

@interface RepositoryDetailTableVC ()

@property (nonatomic, strong) RepositoryHeaderView *headerView;

@end

@implementation RepositoryDetailTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.tableView.tableHeaderView) {
        self.headerView = [[RepositoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150.f)];
        self.headerView.repo = self.repo;
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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

- (void)setRepo:(GITRepository *)repo
{
    NSLog(@"");
    _repo = repo;
}

@end
