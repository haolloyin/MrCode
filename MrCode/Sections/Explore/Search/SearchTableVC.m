//
//  SearchTableVC.m
//  MrCode
//
//  Created by hao on 7/12/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "SearchTableVC.h"
#import "SearchRepositoryCell.h"
#import "SearchDeveloperCell.h"
#import "GITSearch.h"
#import "GITRepository.h"
#import "GITUser.h"

@interface SearchTableVC () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *repositories;
@property (nonatomic, strong) NSMutableArray *developers;

@end

@implementation SearchTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[SearchRepositoryCell class] forCellReuseIdentifier:NSStringFromClass([SearchRepositoryCell class])];
    [self.tableView registerClass:[SearchDeveloperCell class] forCellReuseIdentifier:NSStringFromClass([SearchDeveloperCell class])];
    
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Repository or Developer";
    
    _repositories = [NSMutableArray array];
    _developers = [NSMutableArray array];
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
    NSInteger count = 0;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        count = [self.repositories count];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        count = [self.developers count];
    }
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBasicCell" forIndexPath:indexPath];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        GITRepository *repo = self.repositories[indexPath.row];
        cell.textLabel.text = repo.fullName;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ stars, %@ forks",
                                     repo.language, @(repo.stargazersCount), @(repo.forksCount)];
    }
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"keyword: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self loadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"");
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Private

- (void)loadData
{
    if (self.segmentedControl.selectedSegmentIndex == 0 && [self.repositories count] == 0) {
        [GITSearch searchRepositoriesWith:nil language:nil sortBy:nil success:^(NSArray *array) {
            [self.repositories addObjectsFromArray:array];
            
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

@end
