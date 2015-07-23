//
//  RepositoryDetailTableVC.m
//  MrCode
//
//  Created by hao on 7/7/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryDetailTableVC.h"
#import "RepositoryHeaderView.h"
#import "UserProfileTableVC.h"

#import "UIImage+MRC_Octicons.h"

@interface RepositoryDetailTableVC ()

@property (nonatomic, strong) RepositoryHeaderView *headerView;

@end

@implementation RepositoryDetailTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = self.repo.name;
    
    if (!self.tableView.tableHeaderView) {
        self.headerView = [[RepositoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150.f)];
        self.headerView.repo = self.repo;
        
        [self.headerView setNeedsLayout];
        [self.headerView layoutIfNeeded];
        
        CGFloat height = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return section == 0 ? 2 : 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *textLabel = @"";
    NSString *iconIdentifier;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    }

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                textLabel = @"Owner";
                iconIdentifier = @"Person";
                cell.detailTextLabel.text = self.repo.owner.login;
                break;
            case 1:
                textLabel = @"README";
                iconIdentifier = @"Book";
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                textLabel = @"Forks";
                iconIdentifier = @"GitBranch";
                cell.detailTextLabel.text = self.repo.owner.login;
                break;
            case 1:
                textLabel = @"Releases";
                iconIdentifier = @"Tag";
                break;
            case 2:
                textLabel = @"Recent Activity";
                iconIdentifier = @"Rss";
                break;
            case 3:
                textLabel = @"Contributors";
                iconIdentifier = @"Organization";
                break;
            case 4:
                textLabel = @"Stargazers";
                iconIdentifier = @"Star";
                break;
            case 5:
                textLabel = @"Pull Requests";
                iconIdentifier = @"GitPullRequest";
                break;
            case 6:
                textLabel = @"Issues";
                iconIdentifier = @"IssueOpened";
                break;
        }
    }
    
    cell.textLabel.text = textLabel;
    CGSize size = CGSizeMake(30, 30);
    UIColor *color = [UIColor grayColor];
    cell.imageView.image = [UIImage octicon_imageWithIdentifier:iconIdentifier iconColor:color size:size];
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"RepositoryDetail2UserProfile" sender:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"RepositoryDetail2UserProfile"]) {
        UserProfileTableVC *controller = (UserProfileTableVC *)segue.destinationViewController;
        controller.user = self.repo.owner;
    }
}

#pragma mark - Private


@end
