//
//  NotificationsTableVC.m
//  MrCode
//
//  Created by hao on 7/4/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "NotificationsTableVC.h"
#import "GITNotification.h"
#import "NotificationTableViewCell.h"
#import "RepositoryDetailTableVC.h"
#import "WebViewController.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>

static NSString *kNotificationCellIdentifier = @"NotificationCellIdentifier";

@interface NotificationsTableVC () <NotificationTableViewCellRepoNameTapped>

@property (nonatomic, strong) NSArray *notifications;

@end

@implementation NotificationsTableVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.tabBarItem.title = @"Notifications";
        CGSize size = CGSizeMake(30, 30);
        self.tabBarItem.image = [UIImage octicon_imageWithIdentifier:@"Broadcast" iconColor:FlatGray size:size];
        self.tabBarItem.selectedImage = [UIImage octicon_imageWithIdentifier:@"Broadcast" iconColor:FlatSkyBlue size:size];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[NotificationTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([NotificationTableViewCell class])];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    _notifications = [NSArray new];
    
    [self loadData];
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
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellIdentifier forIndexPath:indexPath];
//    GITNotification *notification = self.notifications[indexPath.row];
//    cell.textLabel.text = notification.subjectTitle;
//    cell.detailTextLabel.text = notification.subjectType;
//    NSLog(@"%@, %@", cell.textLabel.text, cell.detailTextLabel.text);
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([NotificationTableViewCell class])
                                                                      forIndexPath:indexPath];
    cell.notification = self.notifications[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([NotificationTableViewCell class])
                                                 configuration:^(NotificationTableViewCell *cell) {
        cell.notification = self.notifications[indexPath.row];
    }];
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GITNotification *notification = _notifications[indexPath.row];
    [self performSegueWithIdentifier:@"Notification2WebView" sender:notification];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"NotificationCell2RepositoryDetail"]) {
        RepositoryDetailTableVC *controller = (RepositoryDetailTableVC *)segue.destinationViewController;
        GITNotification *notification = (GITNotification *)sender;
        controller.repo = notification.repository;
    }
    else if ([identifier isEqualToString:@"Notification2WebView"]) {
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        GITNotification *notification = (GITNotification *)sender;
        controller.url = notification.htmlURL;
    }
}

#pragma mark - Protocol

- (void)notificationTabViewCellRepoNameTapped:(GITNotification *)notification
{
    [self performSegueWithIdentifier:@"NotificationCell2RepositoryDetail" sender:notification];
}

#pragma makr - Private

- (void)loadData
{
    NSLog(@"");
    [GITNotification myNotificationsWithSuccess:^(NSArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

@end
