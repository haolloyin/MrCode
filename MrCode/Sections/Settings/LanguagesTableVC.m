//
//  LanguagesTableVC.m
//  MrCode
//
//  Created by hao on 7/25/15.
//  Copyright (c) 2015 hao. All rights reserved.
//

#import "LanguagesTableVC.h"

@interface LanguagesTableVC ()

@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSMutableDictionary *languagesSelected;

@end

@implementation LanguagesTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 25 languages, see https://github.com/search/advanced?l=objective-c&langOverride=Objective-C&q=stars%3A%3E1&s=updated&type=Repositories
    _languages = @[
        @"ActionScript",
        @"C",
        @"C#",
        @"C++",
        @"Clojure",
        @"CoffeeScript",
        @"CSS",
        @"Go",
        @"Haskell",
        @"HTML",
        @"Java",
        @"JavaScript",
        @"Lua",
        @"Matlab",
        @"Objective-C",
        @"Perl",
        @"PHP",
        @"Python",
        @"R",
        @"Ruby",
        @"Scala",
        @"Shell",
        @"Swift",
        @"TeX",
        @"VimL"
    ];

    _languagesSelected = [NSMutableDictionary dictionary];
    NSDictionary *savedLanguagesSetting = [self loadLanguagesSetting];
    
    if (savedLanguagesSetting) {
        NSLog(@"has savedLanguagesSetting");
        [_languagesSelected addEntriesFromDictionary:savedLanguagesSetting];
    }
    else {
        NSLog(@"not savedLanguagesSetting");
        for (NSString *language in _languages) {
            _languagesSelected[language] = @"NO";
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"");
    [self saveLanguagesSetting];
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
    return [_languages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell" forIndexPath:indexPath];
    
    NSString *language = _languages[indexPath.row];
    cell.textLabel.text = language;
    
    BOOL isSelected = [_languagesSelected[language] isEqualToString:@"NO"] ? NO : YES;
    
    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *language = _languages[indexPath.row];
    
    BOOL isSelected = [_languagesSelected[language] isEqualToString:@"NO"] ? NO : YES;
    
    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        _languagesSelected[language] = @"NO";
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _languagesSelected[language] = @"YES";
    }
    
    [cell setSelected:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction

- (IBAction)dismissSelf:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (NSDictionary *)loadLanguagesSetting
{
    NSDictionary *languagesDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_Languages_Setting"];
    return [languagesDictionary copy];
}

- (void)saveLanguagesSetting
{
    [[NSUserDefaults standardUserDefaults] setObject:_languagesSelected forKey:@"MrCode_Languages_Setting"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Public

+ (NSString *)favouriteLanguages
{
    NSDictionary *languagesDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"MrCode_Languages_Setting"];
    if (!languagesDictionary) {
        return nil;
    }
 
    for (NSString *key in languagesDictionary) {
        NSString *value = languagesDictionary[key];
        if ([value isEqualToString:@"YES"]) {
            return value;
        }
    }

    return nil;
}

@end
