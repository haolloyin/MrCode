//
//  RepositoryContentTableVC.m
//  MrCode
//
//  Created by hao on 9/6/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoryContentTableVC.h"
#import "GITRepository.h"
#import "RepositoryContentTableViewCell.h"

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
    
    [self.tableView registerClass:[RepositoryContentTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([RepositoryContentTableViewCell class])];
    
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
    NSString *identifier = NSStringFromClass([RepositoryContentTableViewCell class]);
    RepositoryContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.gitContent = _contents[indexPath.row];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    GITRepositoryContent *item = _contents[indexPath.row];
//    if ([item.type isEqualToString:@"dir"]) {
//        NSLog(@"is dir");
//        [self performSegueWithIdentifier:@"ReposContent2Self" sender:item];
//    }
//}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    // 因为这个 push 到自身 controller 是在 IB 拖 cell 连上的，所以不会触发 didSelectRowAtIndexPath，
    // 也就无法设置 sender，此时 sender 是被点击的 UITableViewCell
    RepositoryContentTableViewCell *cell = sender;
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"ReposContent2Self"]) {
        RepositoryContentTableVC *controller = (RepositoryContentTableVC *)segue.destinationViewController;
        controller.repo = self.repo;

        if (!self.path) {
            controller.path = [NSString stringWithFormat:@"%@", cell.textLabel.text];
        }
        else {
            controller.path = [NSString stringWithFormat:@"%@/%@", self.path, cell.textLabel.text];
        }
        controller.title = cell.textLabel.text;
    }
}

- (void)loadData
{
    [_repo contentsOfPath:_path success:^(NSArray *array) {
        _contents = [array copy];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
