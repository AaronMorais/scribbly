//
//  SCRSearchViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-29.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRSearchViewController.h"
#import "Note.h"

@interface SCRSearchViewController ()

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) UISearchDisplayController *sDisplayController;

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
// TODO: fix me!
//    NSString *token = [SCRNoteManager token];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *params = @{@"token":token, @"query":query};
//    NSString *URL = [NSString stringWithFormat:@"%@/note/search", [SCRNoteManager apiEndpoint]];
//    [manager GET:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"] != nil) {
//            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userToken"];
//        } else {
//            [[SCRNoteManager sharedSingleton] clearNotes];
//            if ([responseObject isKindOfClass:[NSArray class]]) {
//                NSArray *jsonResponseObject = (NSArray *)responseObject;
//                for (NSDictionary *jsonCategory in jsonResponseObject) {
//                    if([jsonCategory isKindOfClass:[NSDictionary class]]) {
//                        [[SCRNoteManager sharedSingleton] addNoteWithText:jsonCategory[@"text"] WithID:jsonCategory[@"id"] WithCategory:jsonCategory[@"primaryCategory"]];
//                    }
//                }
//            } else if([responseObject isKindOfClass:[NSDictionary class]]) {
//                [[SCRNoteManager sharedSingleton] addNoteWithText:responseObject[@"text"] WithID:responseObject[@"id"] WithCategory:responseObject[@"primaryCategory"]];
//            }
//            self.notes = [[SCRNoteManager sharedSingleton] getNotes];
//            [self.tableView reloadData];
//            [self.sDisplayController.searchResultsTableView reloadData];
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
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
