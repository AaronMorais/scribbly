//
//  SCRNoteViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteViewController.h"
#import "SCRNetworkManager.h"
#import <AFJSONRequestOperation.h>
#import <AFHTTPClient.h>

@interface SCRNoteHeaderView : UIView

@property (nonatomic, retain) UIView *headerSubview;
@property (nonatomic, retain) UILabel *releaseText;

@end

@implementation SCRNoteHeaderView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIView *headerSubview = [[UIView alloc] init];
        headerSubview.backgroundColor = [UIColor colorWithWhite:0.8627f alpha:1.0];
        headerSubview.clipsToBounds = YES;
        headerSubview.layer.cornerRadius = 5.0f;
        [self addSubview:headerSubview];
        _headerSubview = headerSubview;
        
        UILabel *releaseText = [[UILabel alloc] init];
        releaseText.text = @"View Categories";
        [releaseText sizeToFit];
        releaseText.clipsToBounds = YES;
        releaseText.layer.masksToBounds = YES;
        [self addSubview:releaseText];
        _releaseText = releaseText;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.releaseText.center = self.center;
    self.headerSubview.frame = CGRectInset(self.bounds, 15, 15);
    if (self.frame.size.height < 50) {
        self.releaseText.hidden = YES;
    } else {
        self.releaseText.hidden = NO;
    }
}

@end

@interface SCRNoteViewController ()

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) SCRNoteHeaderView *noteHeaderView;
@property (nonatomic, retain) UIScrollView *noteScrollView;
@property (nonatomic, retain) UITextView *noteTextView;

@property (nonatomic, retain) NoteCategory *category;
@property (nonatomic, retain) NSString *currentNoteText;
@property (nonatomic, retain) NSString *currentNoteCategory;
@property (nonatomic, retain) NSNumber *currentNoteIdentifier;

@property (nonatomic, retain) AFJSONRequestOperation *noteRequestOperation;
@property (nonatomic, retain) AFJSONRequestOperation *categoryRequestOperation;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL requestedNoteID;
@property (nonatomic, assign) SCRNoteViewControllerMode mode;

@end

@implementation SCRNoteViewController

- (id)initWithCategory:(NoteCategory *)category {
    self = [self initWithMode:SCRNoteViewControllerModeCategory];
    if (self) {
        _category = category;
    }
    return self;
}

- (id)initWithNote:(Note *)note{
    self = [self initWithMode:SCRNoteViewControllerModeNoteViewing];
    if (self) {
        _currentNoteText = note.text;
        _currentNoteCategory = note.category;
        _currentNoteIdentifier = note.identifier;
        _requestedNoteID = YES;
    }
    return self;
}

- (id)initWithMode:(SCRNoteViewControllerMode)mode {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"Notes";
        _mode = mode;
        _requestedNoteID = NO;
        _notes = [NSArray array];
    }
    return self;
}

- (void)dealloc {
    self.view.gestureRecognizers = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    [self.view addSubview:self.tableView];
    
    self.noteScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.noteScrollView.delegate = self;
    self.noteScrollView.bounces = YES;
    self.noteScrollView.contentSize = CGSizeMake(self.noteScrollView.frame.size.width, self.noteScrollView.frame.size.height);
    self.noteScrollView.alwaysBounceVertical = YES;
    [self.noteScrollView setShowsVerticalScrollIndicator:NO];
    self.noteScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.noteScrollView];
    
    self.noteTextView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.noteTextView.font = [UIFont systemFontOfSize:18];
    self.noteTextView.clipsToBounds = NO;
    self.noteTextView.delegate = self;
    [self.noteScrollView addSubview:self.noteTextView];
    
    self.noteHeaderView = [[SCRNoteHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.noteHeaderView.backgroundColor = [UIColor whiteColor];
    self.noteHeaderView.clipsToBounds = YES;
    [self.view addSubview:self.noteHeaderView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self showNotes:[self isShowingNotes] Animated:NO];
    [self refresh];
}

- (void)setMode:(SCRNoteViewControllerMode)mode {
    switch (mode) {
      case SCRNoteViewControllerModeCategory:
      case SCRNoteViewControllerModeNoteViewing:
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(newNote)];
        break;
      case SCRNoteViewControllerModeNoteEditing:
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(dismissKeyboard)];;
        break;
    }
    _mode = mode;
}

- (BOOL)isShowingNotes {
    return (self.mode == SCRNoteViewControllerModeNoteEditing || self.mode == SCRNoteViewControllerModeNoteViewing);
}

- (void)newNote {
    self.currentNoteText = nil;
    self.currentNoteCategory = nil;
    self.currentNoteIdentifier = nil;
    self.category = nil;
    self.requestedNoteID = NO;
    self.noteTextView.text = @"";
    self.navigationItem.title = @"Notes";
    [self showNotes:YES Animated:YES];
}

- (void)dismissKeyboard {
    [self.noteTextView resignFirstResponder];
}

- (void)refresh {
    if ((self.category && self.category.name) || (self.currentNoteCategory)) {
        NSString *name = self.category.name;
        name = name ? :self.currentNoteCategory;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSData *data = [prefs objectForKey:[NSString stringWithFormat:@"category:%@", name]];
        NSArray *cachedNotes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.notes = cachedNotes ? : [NSArray array];
        [self.tableView reloadData];
        [self refreshTitle];
        
        NSString *token = [[SCRNetworkManager sharedSingleton] userToken];
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SCRNetworkManager sharedSingleton] apiEndpoint]]];
        NSDictionary *params = @{@"token":token, @"name":name};
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[client requestWithMethod:@"GET" path:@"/category/notes"  parameters:params]
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if ([JSON isKindOfClass:[NSArray class]]) {
                NSMutableArray *results = [NSMutableArray array];
                for (NSDictionary *result in (NSArray *)JSON) {
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        Note *note = [[Note alloc] init];
                        note.identifier = result[@"id"];
                        note.text = result[@"text"];
                        note.category = name;
                        [results addObject:note];
                    }
                }
                BOOL shouldUpdate = [self shouldUpdateCategoriesWithArray:results];
                if (shouldUpdate) {
                    self.notes = results;
                    [self.tableView reloadData];
                    [self refreshTitle];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:results];
                    [prefs setObject:data forKey:[NSString stringWithFormat:@"category:%@", name]];
                }
            }
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Error: %@", error);
        }];
        
        [self.categoryRequestOperation cancel];
        self.categoryRequestOperation = operation;
        [operation start];
    }
}

- (BOOL)shouldUpdateCategoriesWithArray:(NSArray *)newNotes {
    if ([newNotes count] != [self.notes count]) {
        return YES;
    }
    for (int i=0; i<[self.notes count]; i++) {
        if (![((Note *)[self.notes objectAtIndex:i]) isEqual:[newNotes objectAtIndex:i]]) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshTitle {
    NSString *title = nil;
    if (self.category && self.category.name) {
        title = self.category.name;
    } else if(self.currentNoteCategory) {
        title = self.currentNoteCategory;
    } else {
        title = @"Notes";
    }
    self.title = title;
}

- (void)sendNoteRequest {
    NSString *token = [[SCRNetworkManager sharedSingleton] userToken];
    NSDictionary *params;
    if (self.currentNoteIdentifier) {
        params = @{@"token":token, @"text":self.noteTextView.text, @"id":self.currentNoteIdentifier};
    } else {
        params = @{@"token":token, @"text":self.noteTextView.text};
    }
    if (!self.requestedNoteID || self.currentNoteIdentifier) {
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SCRNetworkManager sharedSingleton] apiEndpoint]]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[client requestWithMethod:@"GET" path:@"/note/save" parameters:params]
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.currentNoteIdentifier = JSON[@"id"];
            self.currentNoteCategory = JSON[@"primaryCategory"];
            [self refreshTitle];
            [self refresh];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Error: %@", error);
        }];
        
        [self.noteRequestOperation cancel];
        self.noteRequestOperation = operation;
        [operation start];
        
        self.requestedNoteID = YES;
    }
}

- (void)showNotes:(BOOL)show Animated:(BOOL)animated {
    [self refresh];
    if (self.currentNoteText) {
        self.noteTextView.text = self.currentNoteText;
    }

    void (^animationBlock)() = ^void () {
        self.isAnimating = YES;
        CGRect scrollViewFrame = self.noteScrollView.frame;
        if (show) {
            self.noteHeaderView.layer.opacity = 1;
            scrollViewFrame.origin.y = 0;
        } else {
            self.noteHeaderView.layer.opacity = 0;
            scrollViewFrame.origin.y = self.view.frame.size.height;
        }
        self.noteScrollView.frame = scrollViewFrame;
    };
    
    void (^completionBlock)(BOOL finished) = ^void (BOOL finished) {
        self.isAnimating = NO;
        if (show) {
            [self.noteTextView becomeFirstResponder];
            self.mode = SCRNoteViewControllerModeNoteEditing;
        } else {
            [self.noteTextView resignFirstResponder];
            self.mode = SCRNoteViewControllerModeCategory;
        }
        self.noteScrollView.contentInset = UIEdgeInsetsZero;
    };

    if (animated) {
        [UIView animateWithDuration:0.3 animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark TableView Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notes count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = [self.notes objectAtIndex:indexPath.row];
    self.currentNoteText = note.text;
    self.currentNoteCategory = note.category;
    self.currentNoteIdentifier = note.identifier;
    [self showNotes:YES Animated:YES];
    [[SCRNetworkManager sharedSingleton] trackViewForNote:note];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
    }
    Note *note = [self.notes objectAtIndex:indexPath.row];
    cell.textLabel.text = note.text;
    self.requestedNoteID = YES;
    return cell;
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.mode = SCRNoteViewControllerModeNoteEditing;
    self.noteTextView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 216);
}

- (void)textViewDidChange:(UITextView *)textView {
    // TODO: Fix scrolling
    NSRange range = NSMakeRange(textView.text.length - 1, 1);
    [textView scrollRangeToVisible:range];
    [self sendNoteRequest];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.mode = SCRNoteViewControllerModeNoteViewing;
    // TODO: Fix scrollview contentsize
    CGSize textHeight = [textView sizeThatFits:CGSizeMake(self.view.frame.size.width, INT_MAX)];
    self.noteTextView.frame = CGRectMake(0, 0, self.view.frame.size.width, textHeight.height);
    self.noteScrollView.contentSize = CGSizeMake(self.view.frame.size.width, MAX(textHeight.height, self.noteScrollView.contentSize.height + 100));
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        if (self.isAnimating) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        }
        if (scrollView.contentOffset.y <= 0) {
            CGRect headerViewFrame = self.noteHeaderView.frame;
            headerViewFrame.size.height = - scrollView.contentOffset.y;
            self.noteHeaderView.frame = headerViewFrame;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.tableView) {
        if (scrollView.contentOffset.y < - 100) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
            [self showNotes:NO Animated:YES];
        }
    }
}

@end