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
#import "AppDelegate.h"

#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "NSDate+DateTools.h"
#import "MMPopupItem.h"
#import "MMAlertView.h"

static NSString *kReposCellIdentifier = @"ReposCellIdentifier";
static NSString *kCustomReposCellIdentifier = @"CustomReposCellIdentifier";

@interface RepositoriesTableVC ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *repos;
@property (nonatomic, strong) NSMutableArray *starredRepoCache;
@property (nonatomic, strong) NSMutableArray *ownnedRepoCache;
@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, assign) NSInteger currentStarredPage;
@property (nonatomic, assign) NSInteger currentOwnnedPage;
@property (nonatomic, assign) NSInteger currentForksPage;

@property (nonatomic, strong) MBProgressHUD *loadingHUD;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation RepositoriesTableVC

#pragma mark - Lift circle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.tabBarItem.title = @"Repositories";
        CGSize size = CGSizeMake(30, 30);
        self.tabBarItem.image = [UIImage octicon_imageWithIdentifier:@"Repo" iconColor:FlatGray size:size];
        self.tabBarItem.selectedImage = [UIImage octicon_imageWithIdentifier:@"Repo" iconColor:FlatSkyBlue size:size];
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
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.topItem.title = _user;
    
    [self.tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:kCustomReposCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    if (_reposType == RepositoriesTableVCReposTypeForks) {
        self.navigationItem.title = @"Forks";
    }
    else {
        self.navigationItem.titleView = self.segmentedControl;
    }
    
    _needRefresh = NO;
    _currentStarredPage = 1;
    _currentOwnnedPage = 1;
    _repos = [NSMutableArray array];
    _starredRepoCache = [NSMutableArray array];
    _ownnedRepoCache = [NSMutableArray array];
    
    [self setupRefreshHeaderFooter];
    
    [self checkGitHubOAuth];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSLog(@"");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSLog(@"");
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

#pragma mark - Initial

- (void)initAndRefresh
{
    NSLog(@"_user=%@, [GITUser username]=%@, _reposType=%@", _user, [GITUser username], @(_reposType));
    _user = _user ? : [GITUser username];
    
    [self loadData];
}

- (void)checkGitHubOAuth
{
    if ([AppDelegate isAlreadyOAuth]) {
        NSLog(@"Just refresh");
        [self initAndRefresh];
    }
    else {
        @weakify(self)
        MMPopupItemHandler beginOAuthBlock = ^(NSInteger index){
            @strongify(self)
            [AppDelegate setupGitHubOAuthWithRequestingAccessTokenBlock:^(void) {
                // 当请求 AccessToken 时让弹出 HUD 提示用户
                self.loadingHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                self.loadingHUD.labelText = @"Request Access Token";
                
            } completeBlock:^(void) {
                
                self.loadingHUD.labelText = @"Access current user";
                
                // 获取当前授权用户，然后刷新其资源库
                [GITUser authenticatedUserWithSuccess:^(GITUser *user) {
                    NSLog(@"%@", user.login);
                    
                    [self initAndRefresh];
                } failure:^(AFHTTPRequestOperation *oper, NSError *error) {
                    NSLog(@"error: %@", error);
                }];
            }];
        };
        
        NSArray *items = @[MMItemMake(@"OK", MMItemTypeHighlight, beginOAuthBlock)];
        [[[MMAlertView alloc] initWithTitle:@"Login GitHub with Safari to AUTHORIZE MrCode"
                                     detail:@"With Safari, you DON'T need to type your PASSWORD for MrCode"
                                      items:items] show];
    }
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
    @weakify(self)
    CGFloat height = [tableView fd_heightForCellWithIdentifier:kCustomReposCellIdentifier configuration:^(id cell) {
        @strongify(self)
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
        controller.hidesBottomBarWhenPushed = YES;
        controller.repo = (GITRepository *)sender;
    }
}

#pragma mark - Property

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Starred", @"Owned"]];
        _segmentedControl.selectedSegmentIndex = _reposType; // 根据资源库类型设定是 starred 还是 public
        
        [_segmentedControl addTarget:self action:@selector(segmentedControlTapped) forControlEvents:UIControlEventValueChanged];
    }
    
    return _segmentedControl;
}

- (void)setupRefreshHeaderFooter
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    
    // 设置文字
    [header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
    [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:16];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = [UIColor grayColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor grayColor];
    header.lastUpdatedTimeText = ^(NSDate *date) {
        return [NSString stringWithFormat:@"Updated %@", date.timeAgoSinceNow];
    };
    
    // 设置刷新控件
    self.tableView.header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setTitle:@"Pull up to load more" forState:MJRefreshStateIdle];
    [footer setTitle:@"Release to load more" forState:MJRefreshStatePulling];
    [footer setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    
    self.tableView.footer = footer;
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
    cell.imageView.image = [UIImage octicon_imageWithIdentifier:repo.isForked ? @"RepoForked" : @"Repo"
                                                      iconColor:[UIColor darkGrayColor]
                                                           size:CGSizeMake(30.0f, 30.0f)];
}

- (void)segmentedControlTapped
{
    self.repos = nil;
    [self loadData];
}

- (void)loadData
{
    NSLog(@"");
    
    if (self.tableView.header.isRefreshing) {
        _needRefresh = YES;
    }
    else {
        self.loadingHUD.labelText = nil;
    }
    
    // 有 _segmentedControl 且是第一个 segment，说明是查看某用户的 star 资源库
    if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 0) {
        
        if (_needRefresh || !self.starredRepoCache || self.starredRepoCache.count == 0) {
            
            @weakify(self)
            self.requestOperation = [GITRepository starredRepositoriesByUser:_user needRefresh:_needRefresh parameters:nil success:^(NSArray *repos) {
                
                NSLog(@"count=%@", @(repos.count));
                @strongify(self)
                
                // 回滚为第一页，并且删掉所有缓存
                _currentStarredPage = 1;
                [self.starredRepoCache removeAllObjects];
                [self.starredRepoCache addObjectsFromArray:repos];
                self.repos = [self.starredRepoCache copy];
                
                [self refreshData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"error:\n%@", error);
                @strongify(self)
                [self.tableView.header endRefreshing];
            }];
        }
        // 读缓存
        else {
            self.repos = [self.starredRepoCache copy];
            [self refreshData];
        }
    }
    // 有 _segmentedControl 且是第二个 segment，说明是查看某用户的 public 资源库
    else if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 1) {
        
        if (_needRefresh || !self.ownnedRepoCache || self.ownnedRepoCache.count == 0) {
            @weakify(self)
            self.requestOperation = [GITRepository repositoriesOfUser:_user needRefresh:_needRefresh parameters:nil success:^(NSArray *repos) {

                NSLog(@"count=%@", @(repos.count));
                @strongify(self)
                
                // 回滚为第一页，并且删掉所有缓存
                _currentOwnnedPage = 1;
                [self.ownnedRepoCache removeAllObjects];
                [self.ownnedRepoCache addObjectsFromArray:repos];
                self.repos = [self.ownnedRepoCache copy];
                
                [self refreshData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error:\n%@", error);
                @strongify(self)
                [self.tableView.header endRefreshing];
            }];
        }
        else {
            self.repos = [self.ownnedRepoCache copy];
            [self refreshData];
        }
    }
    // 无 _segmentControl，列出某个 Repo 被 fork 的列表
    else if (_reposType == RepositoriesTableVCReposTypeForks) {
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        @weakify(self)
        self.requestOperation = [GITRepository forksOfRepository:_user parameters:nil success:^(NSArray *repos) {
            
            @strongify(self)
            [self.repos removeAllObjects];
            [self.repos addObjectsFromArray:repos];
            [self refreshData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"error:\n%@", error);
            @strongify(self)
            [self.tableView.header endRefreshing];
            
        }];
    }
}

- (void)loadMoreData
{
    NSLog(@"");
    
    // 有 _segmentedControl 且是第一个 segment，说明是查看某用户的 star 资源库
    if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 0) {
        
        @weakify(self)
        _currentStarredPage += 1;
        NSDictionary *paras = @{@"page": @(_currentStarredPage)};
        self.requestOperation = [GITRepository starredRepositoriesByUser:_user needRefresh:_needRefresh parameters:paras success:^(NSArray *repos) {
            
            NSLog(@"count=%@", @(repos.count));
            @strongify(self)
            [self.starredRepoCache addObjectsFromArray:repos];
            self.repos = [self.starredRepoCache copy];
            [self refreshData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"error:\n%@", error);
            @strongify(self)
            [self.tableView.footer endRefreshing];
        }];
    }
    // 有 _segmentedControl 且是第二个 segment，说明是查看某用户的 public 资源库
    else if (_segmentedControl && _segmentedControl.selectedSegmentIndex == 1) {
        
        @weakify(self)
        _currentOwnnedPage += 1;
        NSDictionary *paras = @{@"page": @(_currentOwnnedPage)};
        self.requestOperation = [GITRepository repositoriesOfUser:_user needRefresh:_needRefresh parameters:paras success:^(NSArray *repos) {
            
            NSLog(@"count=%@", @(repos.count));
            @strongify(self)
            [self.ownnedRepoCache addObjectsFromArray:repos];
            self.repos = [self.ownnedRepoCache copy];
            [self refreshData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:\n%@", error);
            @strongify(self)
            [self.tableView.footer endRefreshing];
        }];
    }
    // 无 _segmentControl，列出某个 Repo 被 fork 的列表
    else if (_reposType == RepositoriesTableVCReposTypeForks) {
        
        @weakify(self)
        _currentForksPage += 1;
        NSDictionary *paras = @{@"page": @(_currentForksPage)};
        self.requestOperation = [GITRepository forksOfRepository:_user parameters:paras success:^(NSArray *repos) {
            
            @strongify(self)
            [self.repos addObjectsFromArray:repos];
            [self refreshData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"error:\n%@", error);
            @strongify(self)
            [self.tableView.footer endRefreshing];
            
        }];
    }
}

- (void)refreshData
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    _needRefresh = NO;
}

@end
