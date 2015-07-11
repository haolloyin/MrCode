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
#import "UITableView+FDTemplateLayoutCell.h"

static NSString *kNotificationCellIdentifier = @"NotificationCellIdentifier";

@interface NotificationsTableVC ()

@property (nonatomic, strong) NSArray *notifications;

@end

@implementation NotificationsTableVC

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
