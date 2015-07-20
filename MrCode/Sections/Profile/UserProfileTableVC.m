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

#import "UIImage+MRC_Octicons.h"

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
        self.headerView = [[UserProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 130.f)];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 2 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileTableViewCell" forIndexPath:indexPath];
    NSString *titleLabel = @"";
    NSString *detailLabel = @"";
    CGSize size = CGSizeMake(30, 30);
    UIImage *image = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                titleLabel = @"Name";
                image = [UIImage octicon_imageWithIdentifier:@"Person" size:size];
                detailLabel = self.user.name;
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 1:
                titleLabel = @"Starred Repositories";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                image = [UIImage octicon_imageWithIdentifier:@"Star" size:size];
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                titleLabel = [self.user.blog absoluteString];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                image = [UIImage octicon_imageWithIdentifier:@"Link" size:size];
                break;
            case 1:
                titleLabel = self.user.email;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                image = [UIImage octicon_imageWithIdentifier:@"Mail" size:size];
                break;
            case 2:
                titleLabel = self.user.location;
                image = [UIImage octicon_imageWithIdentifier:@"Location" size:size];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 3:
                titleLabel = @"Organization";
                image = [UIImage octicon_imageWithIdentifier:@"Organization" size:size];
                cell.detailTextLabel.text = [self.user.organizationsURL absoluteString];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            default:
                break;
        }
    }
    cell.textLabel.text = titleLabel;
    cell.detailTextLabel.text = detailLabel;
    cell.imageView.image = image;
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private

- (void)reload
{
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
}

- (void)fetchUserProfile
{
    if (!self.user) {
        [GITUser authenticatedUserWithSuccess:^(GITUser *user) {
            self.user = user;
            [self reload];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else {
        [GITUser userWithUserName:self.user.login success:^(GITUser *user) {
            self.user = user;
            [self reload];
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
