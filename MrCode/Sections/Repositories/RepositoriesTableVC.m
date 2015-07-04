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

static NSString *kReposCellIdentifier = @"ReposCellIdentifier";

@interface RepositoriesTableVC ()

@property (nonatomic, strong) NSArray *repos;

@end

@implementation RepositoriesTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _repos = [NSArray array];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReposCellIdentifier forIndexPath:indexPath];
    GITRepository *repo = self.repos[indexPath.row];
    
    NSString *detailText;
    if (repo.language) {
        detailText = [NSString stringWithFormat:@"%@ - %@ stars, %@ forks", repo.language, @(repo.stargazersCount), @(repo.forksCount)];
    } else {
        detailText = [NSString stringWithFormat:@"%@ stars, %@ forks", @(repo.stargazersCount), @(repo.forksCount)];
    }
    cell.textLabel.text            = repo.fullName;
    cell.detailTextLabel.text      = detailText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.imageView.image = [UIImage octicon_imageWithIcon:repo.isForked ? @"RepoForked" : @"Repo"
                                          backgroundColor:[UIColor clearColor]
                                                iconColor:[UIColor darkGrayColor]
                                                iconScale:1.0
                                                  andSize:CGSizeMake(30.0f, 30.0f)];
    
    return cell;
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
    [GITRepository myRepositoriesWithSuccess:^(NSArray * repos) {
        self.repos = repos;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
