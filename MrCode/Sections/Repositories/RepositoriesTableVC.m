//
//  RepositoriesTableVC.m
//  MrCode
//
//  Created by hao on 7/4/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "RepositoriesTableVC.h"
#import "UIImage+Octions.h"
#import "GITRepository.h"
#import "ReposTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

static NSString *kReposCellIdentifier = @"ReposCellIdentifier";
static NSString *kCustomReposCellIdentifier = @"CustomReposCellIdentifier";

@interface RepositoriesTableVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, copy) NSString *cachedUser;
@property (nonatomic, strong) NSArray *repos;
@property (nonatomic, strong) NSArray *ownedReposCache;
@property (nonatomic, strong) NSArray *starredReposCache;

@end

@implementation RepositoriesTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[ReposTableViewCell class] forCellReuseIdentifier:kCustomReposCellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    _repos             = [NSArray array];
    _ownedReposCache   = [NSArray array];
    _starredReposCache = [NSArray array];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    
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
    [cell configWithRepository:repo];
    
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

- (void)configCell:(UITableViewCell *)cell withRepo:(GITRepository *)repo
{
    NSString *detailText;
    if (repo.language) {
        detailText = [NSString stringWithFormat:@"%@ - %@ stars, %@ forks", repo.language, @(repo.stargazersCount), @(repo.forksCount)];
    } else {
        detailText = [NSString stringWithFormat:@"%@ stars, %@ forks", @(repo.stargazersCount), @(repo.forksCount)];
    }
    cell.textLabel.text            = repo.name;
    cell.detailTextLabel.text      = detailText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.imageView.image = [UIImage octicon_imageWithIcon:repo.isForked ? @"RepoForked" : @"Repo"
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor darkGrayColor]
                                                iconScale:1.0
                                                  andSize:CGSizeMake(30.0f, 30.0f)];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private

- (void)loadData
{
    if (_segmentedControl.selectedSegmentIndex == 0) {
        if ([self.ownedReposCache count] > 0) {
            self.repos = self.ownedReposCache;
            [self.tableView reloadData];
            return;
        }
        
        [GITRepository myRepositoriesWithSuccess:^(NSArray * repos) {
            self.ownedReposCache = repos;
            self.repos = self.ownedReposCache;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    } else if (_segmentedControl.selectedSegmentIndex == 1) {
        if ([self.starredReposCache count] > 0) {
            self.repos = self.starredReposCache;
            [self.tableView reloadData];
            return;
        }
        
        [GITRepository starredRepositoriesByUser:@"haolloyin" success:^(NSArray * repos) {
            self.starredReposCache = repos;
            self.repos = self.starredReposCache;
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}

@end
