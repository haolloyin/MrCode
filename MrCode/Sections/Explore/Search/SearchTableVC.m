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
#import "ReposTableViewCell.h"
#import "GITSearch.h"
#import "GITRepository.h"
#import "GITUser.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RepositoryDetailTableVC.h"

@interface SearchTableVC () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *repositories;
@property (nonatomic, strong) NSMutableArray *developers;
@property (nonatomic, strong) NSString *keyword;

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
    [self.tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ReposTableViewCell class])];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    self.searchBar.delegate = self;
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.searchBar.placeholder = @"Repository";
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        self.searchBar.placeholder = @"Developer";
    }
    
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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBasicCell" forIndexPath:indexPath];
//    
//    if (self.segmentedControl.selectedSegmentIndex == 0) {
//        GITRepository *repo = self.repositories[indexPath.row];
//        cell.textLabel.text = repo.fullName;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ stars, %@ forks",
//                                     repo.language, @(repo.stargazersCount), @(repo.forksCount)];
//    }

    if (self.segmentedControl.selectedSegmentIndex == 0) {
        ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ReposTableViewCell class])
                                                                   forIndexPath:indexPath];
        GITRepository *repo = self.repositories[indexPath.row];
        [cell configWithRepository:repo];
        
        return cell;
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([ReposTableViewCell class]) configuration:^(id cell) {
            GITRepository *repo = self.repositories[indexPath.row];
            [cell configWithRepository:repo];
        }];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"SearchVC2RepositoryDetail" sender:self.repositories[indexPath.row]];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        
    }

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
    
    self.keyword = searchBar.text;
    [searchBar resignFirstResponder];
    [self loadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"");
    [searchBar resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"SearchVC2RepositoryDetail"]) {
        RepositoryDetailTableVC *controller = (RepositoryDetailTableVC *)segue.destinationViewController;
        controller.repo = (GITRepository *)sender;
    }
}

#pragma mark - Private

- (void)loadData
{
    if (self.segmentedControl.selectedSegmentIndex == 0 && [self.repositories count] == 0) {
        [GITSearch searchRepositoriesWith:self.keyword language:nil sortBy:nil success:^(NSArray *array) {
            [self.repositories addObjectsFromArray:array];
            
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [GITSearch searchDevelopersWith:self.keyword sortBy:nil success:^(NSArray *array) {
            [self.developers addObjectsFromArray:array];
            
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

@end
