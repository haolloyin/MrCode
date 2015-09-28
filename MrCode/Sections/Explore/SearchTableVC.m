//
//  SearchTableVC.m
//  MrCode
//
//  Created by hao on 7/12/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "SearchTableVC.h"
#import "UserTableViewCell.h"
#import "ReposTableViewCell.h"
#import "GITSearch.h"
#import "GITRepository.h"
#import "GITUser.h"
#import "RepositoryDetailTableVC.h"
#import "UserProfileTableVC.h"
#import "LanguagesTableVC.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>
#import "KxMenu.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "NSDate+DateTools.h"


// 搜索 Repos 或 Developer
typedef NS_ENUM(NSUInteger, SearchType) {
    SearchTypeRepository = 0,
    SearchTypeDeveloper = 1
};

// 当前是排行榜还是搜索
typedef NS_ENUM(NSUInteger, CurrentTargetType) {
    CurrentTargetTypeTrending = 0,
    CurrentTargetTypeSearch = 1
};

@interface SearchTableVC () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *trendingReposCache; // Repo 排行榜 cache
@property (nonatomic, strong) NSMutableArray *trendingDevelopersCache; // Repo 排行榜 cache
@property (nonatomic, strong) NSMutableArray *searchReposCache; // Repos 搜索 cache
@property (nonatomic, strong) NSMutableArray *searchDevelopersCache; // 开发者搜索 cache

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) UIImage *placehodlerImage;

@property (nonatomic, assign) SearchType searchType;
@property (nonatomic, assign) CurrentTargetType currentTargetType;
@property (nonatomic, copy) NSString *selectedLanguage; //当前选中的语言
@property (nonatomic, copy) NSString *selectedDatePeriod; //当前选中日期范围，有 Today，This Week，This month

@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@end

@implementation SearchTableVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.tabBarItem.title = @"Explore";
        CGSize size = CGSizeMake(30, 30);
        self.tabBarItem.image = [UIImage octicon_imageWithIdentifier:@"Search" iconColor:FlatGray size:size];
        self.tabBarItem.selectedImage = [UIImage octicon_imageWithIdentifier:@"Search" iconColor:FlatSkyBlue size:size];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:NSStringFromClass([UserTableViewCell class])];
    [self.tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ReposTableViewCell class])];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    [self initial];
    [self updateSeearchBarPlaceholder];
    [self restoreCurrentSelectedLanguage];
    [self restoreCurrentSelectedDatePeriod];
    
    _needRefresh = NO;
    _data                    = [NSArray array];
    _trendingReposCache      = [NSMutableArray array];
    _trendingDevelopersCache = [NSMutableArray array];
    _searchReposCache        = [NSMutableArray array];
    _searchDevelopersCache   = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"");
    [self.requestOperation cancel];
    [self saveCurrentSelectedLanguage];
    [self saveCurrentSelectedDatePeriod];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initial
{
    self.searchType = SearchTypeRepository;
    self.currentTargetType = CurrentTargetTypeTrending;
    
    [self segmentedControlChanged];
    
    UIImage *settingImage = [UIImage octicon_imageWithIdentifier:@"Gear" size:CGSizeMake(20, 20)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:settingImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showMenu:)];
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)updateSeearchBarPlaceholder
{
    self.searchBar.placeholder = (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = [_data count];
    //FIXME: 为啥这里调用了4次？
//    NSLog(@"section: %@, count: %@", @(section), @(count));
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SearchTypeRepository) {
        ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ReposTableViewCell class])
                                                                   forIndexPath:indexPath];
        GITRepository *repo = _data[indexPath.row];
        [cell configWithRepository:repo];
        
        return cell;
    }
    else if (self.searchType == SearchTypeDeveloper) {

        UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UserTableViewCell class])
                                                                    forIndexPath:indexPath];
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBasicCell" forIndexPath:indexPath];
//        cell.textLabel.text = user.login;
//        [cell.imageView sd_setImageWithURL:user.avatarURL placeholderImage:self.placehodlerImage];
        
        GITUser *user = _data[indexPath.row];
        cell.accessoryType = UITableViewRowActionStyleNormal;
        cell.nameLabel.text = user.login;
        [cell.avatarImageView sd_setImageWithURL:user.avatarURL placeholderImage:self.placehodlerImage];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 43;
    
    if (self.searchType == SearchTypeRepository) {
        height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([ReposTableViewCell class]) configuration:^(id cell) {
            GITRepository *repo = _data[indexPath.row];
            [cell configWithRepository:repo];
        }];
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.searchType == SearchTypeRepository) {
        [self performSegueWithIdentifier:@"SearchVC2RepositoryDetail" sender:_data[indexPath.row]];
    }
    else if (self.searchType == SearchTypeDeveloper) {
        [self performSegueWithIdentifier:@"Search2UserProfile" sender:_data[indexPath.row]];
    }
    
    [cell setSelected:NO];
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
    self.needRefresh = YES;
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
        controller.hidesBottomBarWhenPushed = YES;
        controller.repo = (GITRepository *)sender;
    }
    else if ([identifier isEqualToString:@"Search2UserProfile"]) {
        UserProfileTableVC *controller = (UserProfileTableVC *)segue.destinationViewController;
        controller.hidesBottomBarWhenPushed = YES;
        controller.user = (GITUser *)sender;
    }
}

#pragma mark - KxMenu

- (void)showMenu:(UINavigationItem *)sender
{
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
    }
    else {
        NSArray *menuItems = [self setupMenu];

        // 把当前用户选中的高亮一下
        KxMenuItem *currentItem = menuItems[self.searchType];
        currentItem.title = [NSString stringWithFormat:@"%@  √", (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers")];
        currentItem.foreColor = [UIColor flatYellowColor];
        
        // 计算弹出框的位置
        UIView *rightButtonView = (UIView *)[self.navigationItem.rightBarButtonItem performSelector:@selector(view)];
        CGRect fromFrame        = rightButtonView.frame;
        fromFrame.origin.y      = fromFrame.origin.y + fromFrame.size.height;
        //FIXME: 这里的 topLayoutGuide＝64 还是偏低，可能是 KxMenu 又另外计算
        //fromFrame.origin.y = self.topLayoutGuide.length;
        //NSLogRect(fromFrame);
        
        [KxMenu setTitleFont:[UIFont systemFontOfSize:12]];
        [KxMenu showMenuInView:self.view fromRect:fromFrame menuItems:menuItems];
    }
}

- (NSArray *)setupMenu
{
    NSMutableArray *menuItems = [NSMutableArray array];
    
    KxMenuItem *reposItem   = [self menuItemWithTitle:@"Repositories" identifier:@"Repo" action:@selector(itemSelected:)];
    KxMenuItem *devItem     = [self menuItemWithTitle:@"Developers" identifier:@"Person" action:@selector(itemSelected:)];
    [menuItems addObject:reposItem];
    [menuItems addObject:devItem];
    
    if (_currentTargetType == CurrentTargetTypeTrending) {
        NSArray *datePeriods = @[@"Today", @"This week", @"This month"];
        
        BOOL hasDatePeriod = NO;
        for (NSString *period in datePeriods) {
            KxMenuItem *item = [self menuItemWithTitle:period identifier:@"Calendar" action:@selector(datePeriodTapped:)];
            if ([period isEqualToString:_selectedDatePeriod]) {
                item.title = [NSString stringWithFormat:@"%@  √", item.title];
                item.foreColor = [UIColor flatYellowColor];
                hasDatePeriod = YES;
            }
            [menuItems addObject:item];
        }
        
        if (!hasDatePeriod) {
            _selectedDatePeriod = @"Today";
            KxMenuItem *todayItem = menuItems[2];
            todayItem.title = [NSString stringWithFormat:@"%@  √", todayItem.title];
            todayItem.foreColor = [UIColor flatYellowColor];
        }
    }
    
    [menuItems addObject:[self menuItemWithTitle:@"Languages Setting" identifier:@"ListUnordered" action:@selector(languagesSetting:)]];
    
    NSArray *favouriteLanguages = [LanguagesTableVC favouriteLanguages];
    if (favouriteLanguages && [favouriteLanguages count] > 0) {


        for (NSString *language in favouriteLanguages) {
            KxMenuItem *item = [self menuItemWithTitle:language identifier:@"FileCode" action:@selector(languageTapped:)];
            
            // 高亮用户当前选中的语言
            if (self.selectedLanguage && [language isEqualToString:self.selectedLanguage]) {
                item.title = [NSString stringWithFormat:@"%@  √", item.title];
                item.foreColor = [UIColor flatYellowColor];
            }
            
            [menuItems addObject:item];
        }
    }
    
    return [menuItems copy];
}

- (KxMenuItem *)menuItemWithTitle:(NSString *)title identifier:(NSString *)identifier action:(SEL)action
{
    CGSize size = CGSizeMake(20, 20);
    UIColor *iconColor = [UIColor flatWhiteColor];
    UIImage *image = [UIImage octicon_imageWithIdentifier:identifier iconColor:iconColor size:size];
    
    return [KxMenuItem menuItem:title image:image target:self action:action];
}

- (void)itemSelected:(KxMenuItem *)item
{
    self.searchType = ([item.title isEqualToString:@"Repositories"] ? SearchTypeRepository : SearchTypeDeveloper);
    
    [self updateSeearchBarPlaceholder];
    
    NSLog(@"%@, %@", item, @(self.searchType));
}

- (void)languagesSetting:(KxMenuItem *)item
{
    NSLog(@"%@", item);
    
    [self performSegueWithIdentifier:@"Search2Languages" sender:nil];
}

- (void)languageTapped:(KxMenuItem *)item
{
    NSLog(@"CurrentSelected: %@, Tapped: %@", self.selectedLanguage, item.title);
    
    if (!self.selectedLanguage) {
        self.selectedLanguage = item.title;
    }
    else if ([item.title isEqualToString:self.selectedLanguage]) {
        self.selectedLanguage = nil;
    }
    else {
        self.selectedLanguage = item.title;
    }
}

- (void)datePeriodTapped:(KxMenuItem *)item
{
    NSLog(@"CurrentSelected: %@, Tapped: %@", self.selectedDatePeriod, item.title);
    
    if (!self.selectedDatePeriod) {
        self.selectedDatePeriod = item.title;
    }
    else {
        self.selectedDatePeriod = item.title;
    }
}

#pragma mark - IBAction

- (void)segmentedControlChanged
{
    if ([KxMenu isShowing]) {
        [KxMenu dismissMenu];
    }
    
    NSLog(@"BEFORE, currentTargetType: %@, keyword: %@", @(self.currentTargetType), self.keyword);
    
    self.currentTargetType = self.segmentedControl.selectedSegmentIndex;
    
    if (self.currentTargetType == 0) {
        self.tableView.tableHeaderView = nil;
        [self setupRefreshHeader];
    }
    else {
        self.tableView.header = nil;
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.searchBar.delegate = self;
        self.keyword = nil;
        self.searchBar.text = nil;
        self.searchBar.placeholder = (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers");
        self.tableView.tableHeaderView = self.searchBar;
    }
    
    [self loadData];
    
    NSLog(@"AFTER, currentTargetType: %@, keyword: %@", @(self.currentTargetType), self.keyword);
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

- (void)setupRefreshHeader
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
        return [NSString stringWithFormat:@"Last updated: %@", date.timeAgoSinceNow];
    };
    
    // 设置刷新控件
    self.tableView.header = header;
}

- (void)saveCurrentSelectedLanguage
{
    if (self.selectedLanguage) {
        NSLog(@"selectedLanguage=%@", self.selectedLanguage);
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedLanguage forKey:@"MrCode_CurrentSelectedLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)restoreCurrentSelectedLanguage
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_CurrentSelectedLanguage"];
    self.selectedLanguage = language;
    NSLog(@"selectedLanguage=%@", self.selectedLanguage);
}

- (void)saveCurrentSelectedDatePeriod
{
    if (self.selectedDatePeriod) {
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedDatePeriod forKey:@"MrCode_CurrentSelectedDatePeriod"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)restoreCurrentSelectedDatePeriod
{
    NSString *period = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_CurrentSelectedDatePeriod"];
    self.selectedDatePeriod = period;
}

- (void)loadData
{
    NSLog(@"");
    
    if (self.tableView.header.isRefreshing) {
        _needRefresh = YES;
    }
    
    if (_searchType == SearchTypeRepository) {
        [self loadRepos];
    }
    else if (_searchType == SearchTypeDeveloper) {
        [self loadDevelopers];
    }
}


- (void)loadRepos
{
    NSLog(@"");
    
    if (_currentTargetType == CurrentTargetTypeTrending) {
        if (_needRefresh) {
            [self fetchRepos];
        }
        else {
            [self refreshWithData:_trendingReposCache];
        }
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if (_needRefresh) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [self fetchRepos];
        }
        else {
            [self refreshWithData:_searchReposCache];
        }
    }
}

- (void)loadDevelopers
{
    if (_currentTargetType == CurrentTargetTypeTrending) {
        // TODO
        if (_needRefresh) {
            [self fetchDevelopers];
        }
        else {
            [self refreshWithData:_trendingDevelopersCache];
        }
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if (_needRefresh) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [self fetchDevelopers];
        }
        else {
            [self refreshWithData:_searchDevelopersCache];
        }
    }
}

- (void)fetchRepos
{
    NSLog(@"");
    
    // 排行榜
    if (_currentTargetType == CurrentTargetTypeTrending) {
        self.requestOperation = [GITSearch trendingReposOfLanguage:self.selectedLanguage since:self.selectedDatePeriod success:^(NSArray *repos) {
            
            [_trendingReposCache removeAllObjects];
            [_trendingReposCache addObjectsFromArray:repos];
            [self refreshWithData:_trendingReposCache];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    // 搜索
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if (self.keyword) {
            self.requestOperation = [GITSearch repositoriesWithKeyword:self.keyword language:self.selectedLanguage sortBy:nil success:^(NSArray *array) {
                
                [_searchReposCache removeAllObjects];
                [_searchReposCache addObjectsFromArray:array];
                [self refreshWithData:_searchReposCache];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
        else {
            [self refreshWithData:nil];
        }
    }
}

- (void)fetchDevelopers
{
    // 排行榜
    if (_currentTargetType == CurrentTargetTypeTrending) {
        self.requestOperation = [GITSearch developersWithKeyword:nil sortBy:nil success:^(NSArray *array) {
            
            [_trendingDevelopersCache removeAllObjects];
            [_trendingDevelopersCache addObjectsFromArray:array];
            [self refreshWithData:_trendingDevelopersCache];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    // 搜索
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if (self.keyword) {
            self.requestOperation = [GITSearch developersWithKeyword:self.keyword sortBy:nil success:^(NSArray *array) {
                
                [_searchDevelopersCache removeAllObjects];
                [_searchDevelopersCache addObjectsFromArray:array];
                [self refreshWithData:_searchDevelopersCache];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
        else {
            [self refreshWithData:nil];
        }
    }
}

- (void)refreshWithData:(NSMutableArray *)array
{
    NSLog(@"");
    
    _data = [array copy];
    _needRefresh = NO;
    
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

@end
