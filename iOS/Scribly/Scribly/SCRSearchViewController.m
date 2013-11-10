//
//  SCRSearchViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-29.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRSearchViewController.h"
#import "Note.h"
#import "SCRNetworkManager.h"

#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

@interface SCRSearchViewController ()

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) UISearchDisplayController *sDisplayController;
@property (nonatomic, retain) AFJSONRequestOperation *searchRequestOperation;

@end

@implementation SCRSearchViewController

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Search";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        _notes = @[];
    }
    return self;
}

- (void)viewDidLoad {
    self.tableView = [[UITableView alloc] initWithFrame:[self.view bounds]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    
    self.sDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.sDisplayController.delegate = self;
    self.sDisplayController.searchResultsDelegate  = self;
    self.sDisplayController.searchResultsDataSource = self;
    self.sDisplayController.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismissModalViewControllerAnimated:)];
}

#pragma mark - UITableViewDatasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notes count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate presentNoteControllerWithNote:self.notes[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
    }
    if (self.notes && [self.notes count] > indexPath.row) {
        Note *note = [self.notes objectAtIndex:indexPath.row];
        if (note) {
            cell.textLabel.text = note.text;
        }
    }
    return cell;
}

- (void)queryForString:(NSString *)query {
    NSString *token = [[SCRNetworkManager sharedSingleton] userToken];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SCRNetworkManager sharedSingleton] apiEndpoint]]];
    NSDictionary *params = @{@"token":token, @"query":query};
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[client requestWithMethod:@"GET" path:@"/note/search"  parameters:params]
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([JSON isKindOfClass:[NSArray class]]) {
            NSMutableArray *results = [NSMutableArray array];
            for (NSDictionary *result in (NSArray *)JSON) {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    Note *note = [[Note alloc] init];
                    note.identifier = result[@"id"];
                    note.text = result[@"text"];
                    note.category = result[@"primaryCategory"];
                    [results addObject:note];
                }
            }
            self.notes = results;
            [self.tableView reloadData];
            [self.sDisplayController.searchResultsTableView reloadData];
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    
    [self.searchRequestOperation cancel];
    self.searchRequestOperation = operation;
    [operation start];
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    self.notes = @[];
    [self.tableView reloadData];
    [self.sDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self queryForString:searchString];
    return YES;
}

@end
