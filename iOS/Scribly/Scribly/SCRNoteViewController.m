//
//  SCRNoteViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteViewController.h"
#import "SCRNoteManager.h"
#import <AFHTTPRequestOperationManager.h>

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

@property (nonatomic, retain) SCRNoteHeaderView *noteHeaderView;

@property (nonatomic, retain) UIScrollView *noteScrollView;
@property (nonatomic, retain) UITextView *noteTextView;

@property (nonatomic, retain) NoteCategory *category;
@property (nonatomic, retain) Note *currentNote;
@property (nonatomic, retain) NSArray *categoryNotes;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL requestedNoteID;

@property (nonatomic, retain) SCRNoteManager *noteManager;
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
        _categoryNotes = @[note];
        _currentNote = note;
        _requestedNoteID = YES;
    }
    return self;
}

- (id)initWithMode:(SCRNoteViewControllerMode)mode {
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"Notes";
        _mode = mode;
        _categoryNotes = @[];
        _requestedNoteID = NO;
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
    
    self.noteManager = [SCRNoteManager sharedSingleton];
    
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
    
    [self showNotes:[self isShowingNotes] Animated:NO];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)setMode:(SCRNoteViewControllerMode)mode {
    switch (mode) {
      case SCRNoteViewControllerModeCategory:
      case SCRNoteViewControllerModeNoteViewing:
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];;
        break;
      case SCRNoteViewControllerModeNoteEditing:
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];;
        break;
    }
    _mode = mode;
}

- (BOOL)isShowingNotes {
    return (self.mode == SCRNoteViewControllerModeNoteEditing || self.mode == SCRNoteViewControllerModeNoteViewing);
}

- (void)newNote {
    self.currentNote = nil;
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
    if ((self.category && self.category.name) || (self.currentNote && self.currentNote.category)) {
        NSString *token = [SCRNoteManager token];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *name = self.category.name;
        name = name ? : self.currentNote.category;
        NSDictionary *params = @{@"token":token, @"name":name};
        NSString *URL = [NSString stringWithFormat:@"%@/category/notes", [SCRNoteManager apiEndpoint]];
        [manager GET:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"] != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userToken"];
            } else {
                [[SCRNoteManager sharedSingleton] clearNotes];
                NSArray *jsonResponseObject = (NSArray *)responseObject;
                for (NSDictionary *jsonCategory in jsonResponseObject) {
                    [[SCRNoteManager sharedSingleton] addNoteWithText:jsonCategory[@"text"] WithID:jsonCategory[@"id"] WithCategory:jsonCategory[@"category"]];
                }
                self.categoryNotes = [[SCRNoteManager sharedSingleton] getNotes];
                [self.tableView reloadData];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [self refreshTitle];
}

- (void)refreshTitle {
    NSString *title = nil;
    if (self.category && self.category.name) {
        title = self.category.name;
    } else if(self.currentNote && self.currentNote.category) {
        title = self.currentNote.category;
    } else {
        title = @"Notes";
    }
    self.title = title;
}

- (void)showNotes:(BOOL)show Animated:(BOOL)animated {
    [self refresh];
    if (self.currentNote) {
        self.noteTextView.text = self.currentNote.text;
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
        } else {
            [self.noteTextView resignFirstResponder];
        }
        self.noteScrollView.contentInset = UIEdgeInsetsZero;
        self.mode = show ? SCRNoteViewControllerModeNoteViewing : SCRNoteViewControllerModeCategory;
    };

    if (animated) {
        [UIView animateWithDuration:0.3 animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

#pragma mark TableView Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categoryNotes count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = self.categoryNotes[indexPath.row];
    if (note) {
        self.currentNote = note;
        [self showNotes:YES Animated:YES];
        NSString *token = [SCRNoteManager token];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"token":token, @"id":self.currentNote.identifier};
        NSString *URL = [NSString stringWithFormat:@"%@/note/view", [SCRNoteManager apiEndpoint]];
        [manager GET:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"] != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userToken"];
            }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID];
    }
    if (self.categoryNotes && [self.categoryNotes count] > indexPath.row) {
        Note *note = [self.categoryNotes objectAtIndex:indexPath.row];
        if (note) {
            cell.textLabel.text = note.text;
            self.requestedNoteID = YES;
        }
    }
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
 
    NSString *token = [SCRNoteManager token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params;
    if (self.currentNote && self.currentNote.identifier) {
        params = @{@"token":token, @"text":self.noteTextView.text, @"id":self.currentNote.identifier};
    } else {
        params = @{@"token":token, @"text":self.noteTextView.text};
    }
    if (!self.requestedNoteID || self.currentNote) {
        NSString *URL = [NSString stringWithFormat:@"%@/note/save", [SCRNoteManager apiEndpoint]];
        [manager GET:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"error"] != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userToken"];
            } else {
                [[SCRNoteManager sharedSingleton] addNoteWithText:responseObject[@"text"] WithID:responseObject[@"id"] WithCategory:responseObject[@"category"]];
                Note *note = [[SCRNoteManager sharedSingleton] getNoteWithID:responseObject[@"id"]];
                if (!self.currentNote && note) {
                    self.currentNote = note;
                }
                [[SCRNoteManager sharedSingleton] addCategoryWithID:nil WithName:responseObject[@"primaryCategory"] WithScore:responseObject[@"score"]];
                NoteCategory *category = [[SCRNoteManager sharedSingleton] getNoteCategoryWithName:responseObject[@"primaryCategory"]];
                if (category) {
                    self.category = category;
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        self.requestedNoteID = YES;
    }
    [self refreshTitle];
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