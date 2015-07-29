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
#import "RepositoriesTableVC.h"

#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>

@interface UserProfileTableVC () <UserProfileHeaderViewDelegate>

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
        self.headerView.delegate = self;
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
    return section == 0 ? 2 : 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (section == 1) {
//        return @" ";
//    }
//    return nil;
    return @" ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileTableViewCell" forIndexPath:indexPath];
    NSString *titleLabel = @"";
    NSString *detailLabel = @"";
    NSString *iconIdentifier;
    CGSize size = CGSizeMake(30, 30);
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (indexPath.row) {
            case 0:
                iconIdentifier = @"Location";
                titleLabel = [self stringDescription:self.user.location];
                break;
            case 1:
                iconIdentifier = @"Organization";
                titleLabel = @"Organization";
                cell.detailTextLabel.text = [self.user.organizationsURL absoluteString];
                break;
        }
    }
    else if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0:
                iconIdentifier = @"Link";
                cell.textLabel.textColor = [UIColor flatSkyBlueColor];
                titleLabel = [self stringDescription:[self.user.blog absoluteString]];
                break;
            case 1:
                iconIdentifier = @"Mail";
                cell.textLabel.textColor = [UIColor flatSkyBlueColor];
                titleLabel = [self stringDescription:self.user.email];
                break;
            case 2:
                iconIdentifier = @"Star";
                titleLabel = @"Starred Repositories";
                break;
        }
    }
    cell.textLabel.text = titleLabel;
    cell.detailTextLabel.text = detailLabel;
    cell.imageView.image = [UIImage octicon_imageWithIdentifier:iconIdentifier size:size];
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) {
        [self performSegueWithIdentifier:@"UserProfile2ReposTableVC" sender:@"starred"];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"UserProfile2ReposTableVC"]) {
        RepositoriesTableVC *controller = (RepositoriesTableVC *)segue.destinationViewController;
        controller.user = _user.login;
        
        NSString *reposType = (NSString *)sender;
        if ([sender isEqualToString:@"public"]) {
            controller.reposType = RepositoriesTableVCReposTypePublic;
        }
        else if ([reposType isEqualToString:@"starred"]) {
            controller.reposType = RepositoriesTableVCReposTypeStarred;
        }

    }
}

#pragma mark - UserProfileHeaderViewDelegate

- (void)tapUserProfileHeaderViewButton:(UIButton *)button
{
    NSLog(@"button.tag=%@", @(button.tag));
    switch (button.tag) {
        case 101:
            break;
        case 102:
            [self performSegueWithIdentifier:@"UserProfile2ReposTableVC" sender:@"public"];
            break;
        case 103:
            break;
    }
}

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

- (NSString *)stringDescription:(id)obj
{
    if (!obj) {
        return @"No Set";
    }
    if ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@""]) {
        return @"No Set";
    }
    
    return obj;
}

#pragma mark - Property

- (void)setUser:(GITUser *)user
{
    _user = user;
    self.headerView.user = self.user;
}

@end
