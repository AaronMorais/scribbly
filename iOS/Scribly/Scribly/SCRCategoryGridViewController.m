//
//  SCRCategoryGridViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRCategoryGridViewController.h"
#import "SCRNoteViewController.h"
#import "NoteCategory.h"
#import <AFHTTPRequestOperationManager.h>

@interface SCRCategoryGridViewController ()

@end

@implementation SCRCategoryGridViewController

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Categories";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.categories = [[SCRNoteManager sharedSingleton] getCategories];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithCategory:self.categories[indexPath.row]] animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    NoteCategory *category = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.name;
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs objectForKey:@"userToken"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"token":token};
    [manager GET:@"http://172.21.167.83:1337/category/all" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[SCRNoteManager sharedSingleton] clearCategories];
        NSArray *jsonResponseObject = (NSArray *)responseObject;
        for (NSDictionary *jsonCategory in jsonResponseObject) {
            [[SCRNoteManager sharedSingleton] addCategoryWithID:jsonCategory[@"id"] WithName:jsonCategory[@"name"] WithScore:jsonCategory[@"score"]];
        }
        self.categories = [[SCRNoteManager sharedSingleton] getCategories];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
