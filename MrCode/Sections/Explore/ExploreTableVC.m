//
//  ExploreTableVC.m
//  MrCode
//
//  Created by hao on 7/12/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "ExploreTableVC.h"
#import "SearchTableVC.h"

@interface ExploreTableVC ()

@end

@implementation ExploreTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row: %@", @(indexPath.row));
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Explore2Search" sender:nil];
    } else if (indexPath.row == 1) {
        
    } else if (indexPath.row == 2) {
        
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"Explore2Search"]) {
        SearchTableVC *controller = (SearchTableVC *)segue.destinationViewController;
        NSLog(@"controller: %@", controller);
    } else if ([identifier isEqualToString:@""]) {
        
    } else if ([identifier isEqualToString:@""]) {
        
    }
}

@end
