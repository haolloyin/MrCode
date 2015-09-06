//
//  RepositoryContentTableVC.m
//  MrCode
//
//  Created by hao on 9/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryContentTableVC.h"
#import "UIImage+MRC_Octicons.h"

@interface RepositoryContentTableVC ()

@property (nonatomic, strong) NSArray *contents;

@end

@implementation RepositoryContentTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = _repo.name;
    
    _contents = [NSArray array];
    
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
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    GITRepositoryContent *item = _contents[indexPath.row];
    
    cell.textLabel.text = item.name;
    if ([item.type isEqualToString:@"file"]) {
        cell.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileCode" size:CGSizeMake(20, 20)];
    } else if ([item.type isEqualToString:@"dir"]) {
        cell.imageView.image = [UIImage octicon_imageWithIdentifier:@"FileDirectory" size:CGSizeMake(20, 20)];
    }
    
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

- (void)loadData
{
    [_repo contentsOfPath:_path success:^(NSArray *array) {
        _contents = [array copy];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
