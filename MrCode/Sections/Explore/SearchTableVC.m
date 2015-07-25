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

#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MRC_Octicons.h"
#import <ChameleonFramework/Chameleon.h>
#import "KxMenu.h"

typedef NS_ENUM(NSUInteger, SearchType) {
    SearchTypeRepository = 0,
    SearchTypeDeveloper = 1
};

typedef NS_ENUM(NSUInteger, CurrentTargetType) {
    CurrentTargetTypeTrending = 0,
    CurrentTargetTypeSearch = 1
};

@interface SearchTableVC () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *repositories;
@property (nonatomic, strong) NSMutableArray *developers;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) UIImage *placehodlerImage;

@property (nonatomic, assign) SearchType searchType;
@property (nonatomic, assign) CurrentTargetType currentTargetType;
@property (nonatomic, assign) BOOL isShowingMenu;

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
    
    _repositories = [NSMutableArray array];
    _developers = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initial
{
    self.searchType = SearchTypeRepository;
    self.currentTargetType = CurrentTargetTypeTrending;
    self.isShowingMenu = NO;
    
    self.searchBar.delegate = self;
    
    UIImage *settingImage = [UIImage octicon_imageWithIdentifier:@"Gear" size:CGSizeMake(20, 20)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:settingImage
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showMenu:)];
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar.placeholder = (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.searchType == SearchTypeRepository) {
        count = [self.repositories count];
    }
    else if (self.searchType == SearchTypeDeveloper) {
        count = [self.developers count];
    }
    
    NSLog(@"%@", @(count));
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SearchTypeRepository) {
        ReposTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ReposTableViewCell class])
                                                                   forIndexPath:indexPath];
        GITRepository *repo = self.repositories[indexPath.row];
        [cell configWithRepository:repo];
        
        return cell;
    }
    else if (self.searchType == SearchTypeDeveloper) {

        SearchDeveloperCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SearchDeveloperCell class])
                                                                    forIndexPath:indexPath];
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBasicCell" forIndexPath:indexPath];
//        cell.textLabel.text = user.login;
//        [cell.imageView sd_setImageWithURL:user.avatarURL placeholderImage:self.placehodlerImage];
        
        GITUser *user = self.developers[indexPath.row];
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
            GITRepository *repo = self.repositories[indexPath.row];
            [cell configWithRepository:repo];
        }];
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SearchTypeRepository) {
        [self performSegueWithIdentifier:@"SearchVC2RepositoryDetail" sender:self.repositories[indexPath.row]];
    }
    else if (self.searchType == SearchTypeDeveloper) {
        [self performSegueWithIdentifier:@"Search2UserProfile" sender:self.developers[indexPath.row]];
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
    else if ([identifier isEqualToString:@"Search2UserProfile"]) {
        UserProfileTableVC *controller = (UserProfileTableVC *)segue.destinationViewController;
        controller.user = (GITUser *)sender;
    }
}

#pragma mark - IBAction

- (void)showMenu:(UINavigationItem *)sender
{
    if (self.isShowingMenu) {
        [KxMenu dismissMenu];
        self.isShowingMenu = NO;
    }
    else {
        CGSize size = CGSizeMake(20, 20);
        UIColor *iconColor = [UIColor flatWhiteColor];
        NSArray *menuItems = @[
            [KxMenuItem menuItem:@" Repositories"
                          image:[UIImage octicon_imageWithIdentifier:@"Repo" iconColor:iconColor size:size]
                         target:self
                         action:@selector(itemSelected:)],

            [KxMenuItem menuItem:@" Developers"
                          image:[UIImage octicon_imageWithIdentifier:@"Octoface" iconColor:iconColor size:size]
                         target:self
                         action:@selector(itemSelected:)],

            [KxMenuItem menuItem:@" Languages"
                          image:[UIImage octicon_imageWithIdentifier:@"ListUnordered" iconColor:iconColor size:size]
                         target:self
                         action:@selector(languagesTapped:)]
        ];
        
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        
        KxMenuItem *currentItem = menuItems[self.searchType];
        currentItem.title = [NSString stringWithFormat:@" %@  √😝", (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers")];
        currentItem.foreColor = [UIColor flatYellowColor];
        
        UIView *rightButtonView = (UIView *)[self.navigationItem.rightBarButtonItem performSelector:@selector(view)];
        CGRect fromFrame = rightButtonView.frame;
        fromFrame.origin.y = fromFrame.origin.y + fromFrame.size.height;
        //FIXME: 这里的 topLayoutGuide＝64 还是偏低，可能是 KxMenu 又另外计算
        //fromFrame.origin.y = self.topLayoutGuide.length;
        //NSLogRect(fromFrame);
        [KxMenu showMenuInView:self.view fromRect:fromFrame menuItems:menuItems];
        
        self.isShowingMenu = YES;
    }
}

- (void)segmentedControlChanged
{
    NSLog(@"BEFORE, currentTargetType: %@, keyword: %@", @(self.currentTargetType), self.keyword);
    
    [_repositories removeAllObjects];
    [_developers removeAllObjects];
    [self.tableView reloadData];
    
    self.currentTargetType = self.segmentedControl.selectedSegmentIndex;
    self.keyword = nil;
    self.searchBar.text = nil;
    self.searchBar.placeholder = (self.searchType == SearchTypeRepository ? @"Repositories" : @"Developers");
    
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

- (void)loadData
{
    if (self.searchType == SearchTypeRepository && [self.repositories count] == 0) {
        [GITSearch searchRepositoriesWith:self.keyword language:nil sortBy:nil success:^(NSArray *array) {
            [self.repositories addObjectsFromArray:array];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    else if (self.searchType == SearchTypeDeveloper) {
        [GITSearch searchDevelopersWith:self.keyword sortBy:nil success:^(NSArray *array) {
            [self.developers addObjectsFromArray:array];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)itemSelected:(KxMenuItem *)item
{
    self.searchType = ([item.title isEqualToString:@" Repositories"] ? SearchTypeRepository : SearchTypeDeveloper);
    self.isShowingMenu = NO;
    
    NSLog(@"%@, %@", item, @(self.searchType));
}

- (void)languagesTapped:(id)sender
{
    NSLog(@"%@", sender);
    self.isShowingMenu = NO;
}

@end
