//
//  SCRNoteViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteViewController.h"
#import "SCRNoteManager.h"
#import "Note.h"
#import "NoteCategory.h"

@interface SCRNoteViewController ()

@end

@implementation SCRNoteViewController

- (id)initWithNote:(Note *) note {
    self = [super init];
    if (self) {
        self.showingNotes = (note == nil);
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationItem.title = @"Notes";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noteManager = [SCRNoteManager sharedSingleton];
    [self.noteManager addNoteWithText:@"TestNote" WithID:@19201];
    [self.noteManager addCategoryWithID:@18101 WithName:@"Tests!" WithScore:@9001];
    [self.noteManager updateNote:@19201 WithText:@"TestNoteUpdate"];
    
    NSArray *notes = [self.noteManager getNotes];
    for(Note *note in notes) {
        NSLog(@"%@, %@", note.text, note.identifier);
    }
    
    NSArray *categories = [self.noteManager getCategories];
    for(NoteCategory *category in categories) {
        NSLog(@"%@, %@, %@", category.identifier, category.name, category.score);
    }
   
    self.categoryView = [[SCRNoteGridView alloc] initWithFrame:self.view.bounds];
    self.categoryView.delegate = self;
    [self.view addSubview:self.categoryView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.alwaysBounceVertical = YES;
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.clipsToBounds = NO;
    self.textView.delegate = self;
    [self.scrollView addSubview:self.textView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    self.headerView.backgroundColor = [UIColor redColor];
    self.headerView.clipsToBounds = YES;
    [self.view addSubview:self.headerView];
    
    self.releaseText = [[UILabel alloc] init];
    self.releaseText.text = @"View Categories";
    [self.releaseText sizeToFit];
    self.releaseText.center = self.headerView.center;
    self.releaseText.clipsToBounds = YES;
    [self.headerView addSubview:self.releaseText];
    
    [self showNotes:self.showingNotes Animated:NO];
    
    if (self.showingNotes) {
        [self.textView becomeFirstResponder];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isAnimating) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    }
    if (scrollView.contentOffset.y <= 0) {
        CGRect headerViewFrame = self.headerView.frame;
        headerViewFrame.size.height = - scrollView.contentOffset.y;
        self.headerView.frame = headerViewFrame;
        self.releaseText.center = self.headerView.center;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 216);
}

- (void)textViewDidChange:(UITextView *)textView {
    NSRange range = NSMakeRange(textView.text.length - 1, 1);
    [textView scrollRangeToVisible:range];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
    CGSize textHeight = [textView sizeThatFits:CGSizeMake(self.view.frame.size.width, INT_MAX)];
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, textHeight.height);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, MAX(textHeight.height, self.scrollView.contentSize.height + 100));
}

- (void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < - 100) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
        [self showNotes:NO Animated:YES];
    }
}

- (void)itemSelected:(NSObject *)note {
    [self showNotes:YES Animated:YES];
}

- (void)showNotes:(BOOL)show Animated:(BOOL)animated {
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