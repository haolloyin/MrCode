//
//  UsersTableVC.m
//  MrCode
//
//  Created by hao on 7/29/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "UsersTableVC.h"
#import "UserTableViewCell.h"
#import "GITUser.h"
#import "GITRepository.h"
#import "UserProfileTableVC.h"

#import "UIImageView+WebCache.h"
#import "UIImage+MRC_Octicons.h"

@interface UsersTableVC ()

@property (nonatomic, strong) UIImage *placehodlerImage;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation UsersTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = _userType == UsersTableVCUserTypeFollowing ? @"Following" : @"Followers";
    self.navigationController.navigationBar.topItem.title = _user;
    
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([UserTableViewCell class])];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    _users = [NSArray array];
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"");
    [self.requestOperation cancel];
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
    return [_users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserTableViewCell class])
                                                                forIndexPath:indexPath];
    
    GITUser *user = _users[indexPath.row];
    cell.accessoryType = UITableViewRowActionStyleNormal;
    cell.nameLabel.text = user.login;
    [cell.avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:self.placehodlerImage];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GITUser *user = _users[indexPath.row];
    [self performSegueWithIdentifier:@"UsersTableVC2UserProfile" sender:user];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UsersTableVC2UserProfile"]) {
        UserProfileTableVC *controller = (UserProfileTableVC *)segue.destinationViewController;
        controller.user = (GITUser *)sender;
    }
}

#pragma mark - Property

- (UIImage *)placehodlerImage
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _placehodlerImage = [UIImage octicon_imageWithIdentifier:@"Octoface" size:CGSizeMake(20, 20)];
    });
    
    return _placehodlerImage;
}

#pragma mark - Private

- (void)reloadData
{
    NSLog(@"");
    if (_userType == UsersTableVCUserTypeFollower) {
        self.requestOperation = [GITUser followersOfUser:_user success:^(NSArray *users) {
            _users = users;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else if (_userType == UsersTableVCUserTypeFollowing) {
        self.requestOperation = [GITUser followingOfUser:_user success:^(NSArray *users) {
            _users = users;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

@end
