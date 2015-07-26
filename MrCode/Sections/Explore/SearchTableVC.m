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
#import "RepositoryDetailTableVC.h"
#import "UserProfileTableVC.h"
#import "LanguagesTableVC.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>
#import "KxMenu.h"

// 搜索 Repos 或 Developer
typedef NS_ENUM(NSUInteger, SearchType) {
    SearchTypeRepository = 0,
    SearchTypeDeveloper = 1
};

// 当前时排行榜还是搜索
typedef NS_ENUM(NSUInteger, CurrentTargetType) {
    CurrentTargetTypeTrending = 0,
    CurrentTargetTypeSearch = 1
};

@interface SearchTableVC () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

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
    
    [self initial];
    [self updateSeearchBarPlaceholder];
    
    _data                    = [NSArray array];
    _trendingReposCache      = [NSMutableArray array];
    _trendingDevelopersCache = [NSMutableArray array];
    _searchReposCache        = [NSMutableArray array];
    _searchDevelopersCache   = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"");
    [self restoreCurrentSelectedLanguage];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"");
    [self saveCurrentSelectedLanguage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initial
{
    self.searchType = SearchTypeRepository;
    self.currentTargetType = CurrentTargetTypeTrending;
    
    self.searchBar.delegate = self;
    
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
    NSLog(@"section: %@, count: %@", @(section), @(count));
    
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

        SearchDeveloperCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SearchDeveloperCell class])
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
    [searchBar resignFirstResponder];
    [self reloadData];
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
    else if ([identifier isEqualToString:@"Search2UserProfile"]) {
        UserProfileTableVC *controller = (UserProfileTableVC *)segue.destinationViewController;
        controller.user = (GITUser *)sender;
    }
}

#pragma mark - IBAction

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
    KxMenuItem *settingItem = [self menuItemWithTitle:@"Languages Setting" identifier:@"ListUnordered" action:@selector(languagesSetting:)];
    
    [menuItems addObject:reposItem];
    [menuItems addObject:devItem];
    
    NSArray *favouriteLanguages = [LanguagesTableVC favouriteLanguages];
    if (favouriteLanguages && [favouriteLanguages count] > 0) {
        [menuItems addObject:[KxMenuItem menuItem:@"😝😝😝😝😝😝😝😝😝" image:nil target:nil action:nil]];
        [menuItems addObject:settingItem];

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
    else {
        [menuItems addObject:settingItem];
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

- (void)segmentedControlChanged
{
    NSLog(@"BEFORE, currentTargetType: %@, keyword: %@", @(self.currentTargetType), self.keyword);
    
    self.currentTargetType = self.segmentedControl.selectedSegmentIndex;
    self.keyword = nil;
    self.searchBar.text = nil;
    self.searchBar.placeholder = (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers");
    
    [self reloadData];
    
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

- (void)saveCurrentSelectedLanguage
{
    if (self.selectedLanguage) {
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedLanguage forKey:@"MrCode_CurrentSelectedLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)restoreCurrentSelectedLanguage
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_CurrentSelectedLanguage"];
    self.selectedLanguage = language;
}

- (void)reloadData
{
    if (_searchType == SearchTypeRepository) {
        [self loadRepos];
    }
    else if (_searchType == SearchTypeDeveloper) {
        [self loadDevelopers];
    }
}


- (void)loadRepos
{
    if (_currentTargetType == CurrentTargetTypeTrending) {
        if ([_trendingReposCache count] == 0) {
            [self fetchRepos];
        }
        else {
            [self refreshWithData:_trendingReposCache];
        }
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if ([_searchReposCache count] == 0) {
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
        if ([_trendingDevelopersCache count] == 0) {
            [self fetchDevelopers];
        }
        else {
            [self refreshWithData:_trendingDevelopersCache];
        }
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        if ([_searchDevelopersCache count] == 0) {
            [self fetchDevelopers];
        }
        else {
            [self refreshWithData:_searchDevelopersCache];
        }
    }
}

- (void)fetchRepos
{
    if (_currentTargetType == CurrentTargetTypeTrending) {
        [GITSearch searchRepositoriesWith:nil language:nil sortBy:nil success:^(NSArray *array) {
            [_trendingReposCache addObjectsFromArray:array];
            [self refreshWithData:_trendingReposCache];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        [GITSearch searchRepositoriesWith:self.keyword language:nil sortBy:nil success:^(NSArray *array) {
            [_searchReposCache addObjectsFromArray:array];
            [self refreshWithData:_searchReposCache];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)fetchDevelopers
{
    if (_currentTargetType == CurrentTargetTypeTrending) {
        [GITSearch searchDevelopersWith:nil sortBy:nil success:^(NSArray *array) {
            [_trendingDevelopersCache addObjectsFromArray:array];
            [self refreshWithData:_trendingDevelopersCache];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    else if (_currentTargetType == CurrentTargetTypeSearch) {
        [GITSearch searchRepositoriesWith:self.keyword language:nil sortBy:nil success:^(NSArray *array) {
            [_searchDevelopersCache addObjectsFromArray:array];
            [self refreshWithData:_searchDevelopersCache];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)refreshWithData:(NSMutableArray *)array
{
    NSLog(@"");
    _data = [array copy];
    [self.tableView reloadData];
}

@end
