//
//  SCRSearchViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-29.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRSearchViewController.h"
#import "Note.h"
#import <AFHTTPRequestOperationManager.h>
#import "SCRNoteManager.h"
#import "SCRNoteViewController.h"

@interface SCRSearchViewController ()

@end

@implementation SCRSearchViewController

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Search";
        self.edgesForExtendedLayout = UIRectEdgeNone;

        _tableView = [[UITableView alloc] initWithFrame:[self.view bounds]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:[self tableView]];
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   CGRectGetWidth(self.view.frame),
                                                                   44.0f)];
        
        [[self tableView] setTableHeaderView:[self searchBar]];
        self.notes = [NSArray array];
    
        self.sDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        self.sDisplayController.delegate = self;
        self.sDisplayController.searchResultsDelegate  = self;
        self.sDisplayController.searchResultsDataSource = self;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    self.sDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

#pragma mark - UITableViewDatasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notes count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_delegate presentNoteControllerWithNote:self.notes[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    if (self.notes && self.notes.count > indexPath.row) {
        Note *note = [self.notes objectAtIndex:indexPath.row];
        cell.textLabel.text = note.text;
    }
    return cell;
}

- (NSArray *)notes {
    return _notes;
}

- (void)queryForString:(NSString *)query {
    NSString *token = [SCRNoteManager token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"token":token, @"query":query};
    [manager GET:@"http://10.101.30.230:1337/note/search" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[SCRNoteManager sharedSingleton] clearNotes];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *jsonResponseObject = (NSArray *)responseObject;
            for (NSDictionary *jsonCategory in jsonResponseObject) {
                if([jsonCategory isKindOfClass:[NSDictionary class]]) {
                    [[SCRNoteManager sharedSingleton] addNoteWithText:jsonCategory[@"text"] WithID:jsonCategory[@"id"] WithCategory:jsonCategory[@"primaryCategory"]];
                }
            }
        } else if([responseObject isKindOfClass:[NSDictionary class]]) {
            [[SCRNoteManager sharedSingleton] addNoteWithText:responseObject[@"text"] WithID:responseObject[@"id"] WithCategory:responseObject[@"primaryCategory"]];
        }
        self.notes = [[SCRNoteManager sharedSingleton] getNotes];
        [self.tableView reloadData];
        [self.sDisplayController.searchResultsTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
 {
    self.notes = [NSArray array];
    [self.tableView reloadData];
    [self.sDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self queryForString:searchString];
    return YES;
}

@end
