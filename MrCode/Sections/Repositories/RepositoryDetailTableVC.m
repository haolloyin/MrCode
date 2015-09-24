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
#import "RepositoriesTableVC.h"
#import "WebViewController.h"
#import "RepositoryContentTableVC.h"

#import "UIImage+MRC_Octicons.h"

@interface RepositoryDetailTableVC () <RepositoryHeaderViewDelegate, WebViewControllerDelegate>

@property (nonatomic, strong) RepositoryHeaderView *headerView;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation RepositoryDetailTableVC

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Repos Detail";
    
    if (!self.tableView.tableHeaderView) {
        self.headerView = [[RepositoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150.f)];
        self.headerView.repo = self.repo;
        self.headerView.delegate = self;
        
        [self.headerView setNeedsLayout];
        [self.headerView layoutIfNeeded];
        
        CGFloat height = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
        self.tableView.tableHeaderView = self.headerView;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.requestOperation cancel];
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
    return section == 0 ? 2 : 8;
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
                textLabel = @"Stargazers";
                iconIdentifier = @"Star";
                break;
            case 2:
                textLabel = @"Source Code";
                iconIdentifier = @"Code";
                break;
            case 3:
                textLabel = @"Contributors";
                iconIdentifier = @"Organization";
                break;
            case 4:
                textLabel = @"Recent Activity";
                iconIdentifier = @"Rss";
                break;
            case 5:
                textLabel = @"Pull Requests";
                iconIdentifier = @"GitPullRequest";
                break;
            case 6:
                textLabel = @"Issues";
                iconIdentifier = @"IssueOpened";
                break;
            case 7:
                textLabel = @"Releases";
                iconIdentifier = @"Tag";
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
            case 1:
                [self performSegueWithIdentifier:@"ReposDetail2WebView" sender:nil];
                break;
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"ReposDetail2ReposTableVC" sender:self.repo];
                break;
            case 1:
                [self performSegueWithIdentifier:@"ReposDetail2UserTableVC" sender:self.repo];
                break;
            case 2:
                [self performSegueWithIdentifier:@"ReposDetail2ReposContentTableVC" sender:self.repo];
                break;
            default:
                break;
        }
    }
}

#pragma mark - RepositoryHeaderViewDelegate

- (void)tapRepositoryHeaderViewButton:(UIButton *)button
{
    NSLog(@"button.tag=%@", @(button.tag));
    
    switch (button.tag) {
        case 101:
            [self starRepository];
            break;
        case 102:
            [self forkRepository];
            break;
        case 103:
            [self watchRepository];
            break;
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
    else if ([identifier isEqualToString:@"ReposDetail2ReposTableVC"]) {
        
        RepositoriesTableVC *controller = (RepositoriesTableVC *)segue.destinationViewController;
        controller.user = [NSString stringWithFormat:@"%@/%@", self.repo.owner.login, self.repo.name];
        controller.reposType = RepositoriesTableVCReposTypeForks;
    }
    else if ([identifier isEqualToString:@"ReposDetail2UserTableVC"]) {
        
        RepositoriesTableVC *controller = (RepositoriesTableVC *)segue.destinationViewController;
        controller.user = [NSString stringWithFormat:@"%@/%@", self.repo.owner.login, self.repo.name];
        controller.reposType = RepositoriesTableVCReposTypeForks;
    }
    else if ([identifier isEqualToString:@"ReposDetail2WebView"]) {
        
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        controller.title = self.repo.name;
        controller.delegate = self;
    }
    else if ([identifier isEqualToString:@"ReposDetail2ReposContentTableVC"]) {
        
        RepositoryContentTableVC *controller = (RepositoryContentTableVC *)segue.destinationViewController;
        controller.repo = (GITRepository *)sender;
        controller.path = nil;
    }
}

#pragma makr - WebViewControllerDelegate

- (void)webViewShouldLoadRequest:(UIWebView *)webView
{
    [self.repo readmeWithsuccess:^(NSString *success) {
//        NSLog(@"%@", success);
        
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        [webView loadHTMLString:success baseURL:baseURL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    } needRefresh:NO];
}

#pragma mark - Private

- (void)starRepository
{
    if (self.headerView.isStarred) {
        self.requestOperation = [GITRepository unstarRepository:self.repo success:^(BOOL ok) {
            NSLog(@"unstar OK");
            [self.headerView updateStarButtonWithStar:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else {
        self.requestOperation = [GITRepository starRepository:self.repo success:^(BOOL ok) {
            NSLog(@"star OK");
            [self.headerView updateStarButtonWithStar:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)forkRepository
{
    NSLog(@"");
    [self performSegueWithIdentifier:@"ReposDetail2ReposTableVC" sender:self.repo];
}

- (void)watchRepository
{
    // TODO: 暂时先不做，因为要缓存 watch 的资源库，似乎不是很必要
//    [GITRepository watchRepository:self.repo success:^(BOOL ok) {
//        NSLog(@"OK");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
}

@end
