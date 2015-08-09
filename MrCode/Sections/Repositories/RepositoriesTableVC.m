//
//  RepositoriesTableVC.m
//  MrCode
//
//  Created by hao on 7/4/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoriesTableVC.h"
#import "GITRepository.h"
#import "ReposTableViewCell.h"
#import "RepositoryDetailTableVC.h"
#import "GITUser.h"

#import "UIImage+Octions.h"
#import "UITableView+FDTemplateLayoutCell.h"

static NSString *kReposCellIdentifier = @"ReposCellIdentifier";
static NSString *kCustomReposCellIdentifier = @"CustomReposCellIdentifier";

@interface RepositoriesTableVC ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, copy) NSString *cachedUser;
@property (nonatomic, strong) NSArray *repos;
@property (nonatomic, strong) NSArray *ownedReposCache;
@property (nonatomic, strong) NSArray *starredReposCache;

@property (nonatomic, assign) BOOL isAuthenticatedUser;

@end

@implementation RepositoriesTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.topItem.title = _user;
    
    [self.tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:kCustomReposCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    NSLog(@"_user=%@, [GITUser username]=%@, _reposType=%@", _user, [GITUser username], @(_reposType));

    if (_reposType == RepositoriesTableVCReposTypeForks) {
        self.navigationItem.title = @"Forks";
    }
    else {
        self.navigationItem.titleView = self.segmentedControl;
    }
    
    _repos             = [NSArray array];
    _ownedReposCache   = [NSArray array];
    _starredReposCache = [NSArray array];
    
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
    return [self.repos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GITRepository *repo = self.repos[indexPath.row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReposCellIdentifier forIndexPath:indexPath];
//    [self configCell:cell withRepo:repo];
    
    ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomReposCellIdentifier forIndexPath:indexPath];
    if (_reposType == RepositoriesTableVCReposTypeForks) {
        [cell configForksWithRepository:repo];
    }
    else {
        [cell configWithRepository:repo];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [tableView fd_heightForCellWithIdentifier:kCustomReposCellIdentifier configuration:^(id cell) {
        GITRepository *repo = self.repos[indexPath.row];
        [cell configWithRepository:repo];
    }];
    return height;
}

#pragma mark - Table view cell

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
    [self performSegueWithIdentifier:@"RepositoriesTableVC2RepoDetail" sender:self.repos[indexPath.row]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;

    if ([identifier isEqualToString:@"RepositoriesTableVC2RepoDetail"]) {
        RepositoryDetailTableVC *controller = (RepositoryDetailTableVC *)segue.destinationViewController;
        controller.repo = (GITRepository *)sender;
    }
}

#pragma mark - Property

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Starred", @"Owned"]];
        _segmentedControl.selectedSegmentIndex = _reposType; // 根据资源库类型设定是 starred 还是 public
        
        [_segmentedControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

#pragma mark - Private

- (void)configCell:(UITableViewCell *)cell withRepo:(GITRepository *)repo
{
    NSString *detailText;
    if (repo.language) {
        detailText = [NSString stringWithFormat:@"%@ - %@ stars, %@ forks", repo.language, @(repo.stargazersCount), @(repo.forksCount)];
    } else {
        detailText = [NSString stringWithFormat:@"%@ stars, %@ forks", @(repo.stargazersCount), @(repo.forksCount)];
    }

    cell.textLabel.text = repo.name;
    if (_reposType == RepositoriesTableVCReposTypeForks) {
        cell.textLabel.text = repo.fullName;
    }

    cell.detailTextLabel.text      = detailText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.imageView.image = [UIImage octicon_imageWithIcon:repo.isForked ? @"RepoForked" : @"Repo"
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor darkGrayColor]
                                                iconScale:1.0
                                                  andSize:CGSizeMake(30.0f, 30.0f)];
}

- (BOOL)isAuthenticatedUser
{
    NSString *authenticatedUser = [GITUser username];
    if (!_user || [_user isEqualToString:authenticatedUser]) {
        _user = authenticatedUser;
        return YES;
    }
    return NO;
}

- (void)loadData
{
//    NSLog(@"_segmentedControl.selectedSegmentIndex=%@", @(_segmentedControl.selectedSegmentIndex));
    
    // 有 _segmentedControl，说明是查看本人资源库
    if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 0) {
        if ([self.starredReposCache count] > 0) {
            self.repos = self.starredReposCache;
            [self.tableView reloadData];
            return;
        }
        
        [self loadStarredReposOfUser:_user];
    }
    else if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 1) {
        if ([self.ownedReposCache count] > 0) {
            self.repos = self.ownedReposCache;
            [self.tableView reloadData];
            return;
        }
        
        [self loadReposOfUser:_user];
    }
    // 列出某个 Repo 被 fork 的列表
    else if (_reposType == RepositoriesTableVCReposTypeForks) {
        [GITRepository forksOfRepository:_user success:^(NSArray *repos) {
            self.repos = repos;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    // 没有 _segmentedControl，说明是查看他人资源库
    else {
        if (_reposType == RepositoriesTableVCReposTypePublic) {
            [self loadReposOfUser:_user];
        }
        else if (_reposType == RepositoriesTableVCReposTypeStarred) {
            [self loadStarredReposOfUser:_user];
        }
    }
}

- (void)loadReposOfUser:(NSString *)user
{
    if (self.isAuthenticatedUser) {
        [GITRepository myRepositoriesWithSuccess:^(NSArray *repos) {
            self.ownedReposCache = repos;
            self.repos = self.ownedReposCache;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    else {
        [GITRepository repositoriesOfUser:user success:^(NSArray *repos) {
            self.ownedReposCache = repos;
            self.repos = self.ownedReposCache;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)loadStarredReposOfUser:(NSString *)user
{
    [GITRepository starredRepositoriesByUser:user success:^(NSArray * repos) {
        self.starredReposCache = repos;
        self.repos = self.starredReposCache;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
