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

@interface SCRNoteViewController ()

@end

@implementation SCRNoteViewController

- (id)initWithCategory:(NoteCategory *)category {
    self = [super init];
    if (self) {
        self.showingNotes = (category == nil);
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"Notes";
        self.category = category;
        self.notes = [NSArray array];
        self.requestedNoteID = NO;
        self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
        self.showingKeyboard = NO;
    }
    return self;
}

- (id)initWithNote:(Note *)note{
    self = [super init];
    if (self) {
        self.showingNotes = (note != nil);
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"Notes";
        self.notes = @[note];
        self.note = note;
        self.requestedNoteID = YES;
        self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
        self.showingKeyboard = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.noteManager = [SCRNoteManager sharedSingleton];
    
    NSArray *notes = [self.noteManager getNotes];
    for(Note *note in notes) {
        NSLog(@"%@, %@", note.text, note.identifier);
    }
    
    NSArray *categories = [self.noteManager getCategories];
    for(NoteCategory *category in categories) {
        NSLog(@"%@, %@, %@", category.identifier, category.name, category.score);
    }
    
    _newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];
    self.navigationItem.rightBarButtonItem = _newButton;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.clipsToBounds = NO;
    self.textView.delegate = self;
    [self.scrollView addSubview:self.textView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.headerView.clipsToBounds = YES;
    [self.view addSubview:self.headerView];
    
    self.headerSubview = [[UIView alloc] init];
    self.headerSubview.backgroundColor = [UIColor colorWithWhite:0.8627f alpha:1.0];
    self.headerSubview.clipsToBounds = YES;
    self.headerSubview.layer.cornerRadius = 5.0f;
    [self.headerView addSubview:self.headerSubview];
    
    self.releaseText = [[UILabel alloc] init];
    self.releaseText.text = @"View Categories";
    [self.releaseText sizeToFit];
    self.releaseText.center = self.headerView.center;
    self.releaseText.clipsToBounds = YES;
    self.releaseText.layer.masksToBounds = YES;
    [self.headerView addSubview:self.releaseText];
    
    [self showNotes:self.showingNotes Animated:NO];
    
    if (self.showingNotes) {
        [self.textView becomeFirstResponder];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setNeedsLayout];
}

- (void)dealloc {
    self.view.gestureRecognizers = nil;
}

- (void)newNote {
    self.note = nil;
    self.category = nil;
    self.requestedNoteID = NO;
    self.textView.text = @"";
    self.navigationItem.title = @"Notes";
    [self showNotes:YES Animated:YES];
    [self.textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

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
    Note *note = [[SCRNoteManager sharedSingleton] getNotes][indexPath.row];
    if (note) {
        self.note = note;
        self.textView.text = note.text;
        [self showNotes:YES Animated:YES];
        NSString *token = [SCRNoteManager token];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"token":token, @"id":self.note.identifier};
        [manager GET:@"http://10.101.30.230:1337/note/view" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    if (self.notes) {
        Note *note = [self.notes objectAtIndex:indexPath.row];
        cell.textLabel.text = note.text;
        self.requestedNoteID = YES;
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.tableView) {
        if (self.isAnimating) {
            CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        }
        if (scrollView.contentOffset.y <= 0) {
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = - scrollView.contentOffset.y;
            self.headerView.frame = headerViewFrame;
            self.headerSubview.frame = CGRectInset(self.headerView.bounds, 15, 15);
            if (self.headerView.frame.size.height < 50) {
                self.releaseText.hidden = YES;
            } else {
                self.releaseText.hidden = NO;
            }
            self.releaseText.center = self.headerView.center;
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 216);
    self.showingKeyboard = YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSRange range = NSMakeRange(textView.text.length - 1, 1);
    [textView scrollRangeToVisible:range];
 
    NSString *token = [SCRNoteManager token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params;
    if (self.note && self.note.identifier) {
        params = @{@"token":token, @"text":self.textView.text, @"id":self.note.identifier};
    } else {
        params = @{@"token":token, @"text":self.textView.text};
    }
    if (!self.requestedNoteID || self.note) {
        [manager GET:@"http://10.101.30.230:1337/note/save" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[SCRNoteManager sharedSingleton] addNoteWithText:responseObject[@"text"] WithID:responseObject[@"id"] WithCategory:responseObject[@"category"]];
            Note *note = [[SCRNoteManager sharedSingleton] getNoteWithID:responseObject[@"id"]];
            if (!self.note && note) {
                self.note = note;
            }
            [[SCRNoteManager sharedSingleton] addCategoryWithID:nil WithName:responseObject[@"primaryCategory"] WithScore:responseObject[@"score"]];
            NoteCategory *category = [[SCRNoteManager sharedSingleton] getNoteCategoryWithName:responseObject[@"primaryCategory"]];
            if (category) {
                self.category = category;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        self.requestedNoteID = YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = _newButton;
    CGSize textHeight = [textView sizeThatFits:CGSizeMake(self.view.frame.size.width, INT_MAX)];
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, textHeight.height);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, MAX(textHeight.height, self.scrollView.contentSize.height + 100));
    self.showingKeyboard = NO;
}

- (void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (void)refresh {
    if ((self.category && self.category.name) || (self.note && self.note.category)) {
        NSString *token = [SCRNoteManager token];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *name = self.category.name;
        name = name ? : self.note.category;
        NSDictionary *params = @{@"token":token, @"name":name};
        [manager GET:@"http://10.101.30.230:1337/category/notes" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[SCRNoteManager sharedSingleton] clearNotes];
            NSArray *jsonResponseObject = (NSArray *)responseObject;
            for (NSDictionary *jsonCategory in jsonResponseObject) {
                [[SCRNoteManager sharedSingleton] addNoteWithText:jsonCategory[@"text"] WithID:jsonCategory[@"id"] WithCategory:jsonCategory[@"category"]];
            }
            self.notes = [[SCRNoteManager sharedSingleton] getNotes];
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)setCategory:(NoteCategory *)category {
    _category = category;
    if (category.name) {
        self.navigationItem.title = category.name;
    }
}

- (void)setNote:(Note *)note {
    _note = note;
    if (note.category) {
        self.navigationItem.title = note.category;
    }
}

- (void)showNotes:(BOOL)show Animated:(BOOL)animated {
    if (!show) {
        [self refresh];
    } else {
        if (self.note) {
            self.textView.text = self.note.text;
            [self setNote:self.note];
            [self refresh];
        }
    }

    void (^animationBlock)() = ^void () {
        if (show) {
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = 0;
            self.headerView.frame = headerViewFrame;
            
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.origin.y = 0;
            self.scrollView.frame = scrollViewFrame;
        } else {
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = 0;
            self.headerView.frame = headerViewFrame;
        
            self.headerView.layer.opacity = 0;
            
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.origin.y = self.view.frame.size.height;
            self.scrollView.frame = scrollViewFrame;
        }
        self.isAnimating = YES;
    };
    
    void (^completionBlock)(BOOL finished) = ^void (BOOL finished) {
        self.isAnimating = NO;
        if (show) {
            self.headerView.layer.opacity = 1;
        }
        self.scrollView.contentInset = UIEdgeInsetsZero;
    };

    if (!show) {
        [self.textView resignFirstResponder];
    }

    if (animated) {
        [UIView animateWithDuration:0.3 animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
    self.showingNotes = show;
}

@end