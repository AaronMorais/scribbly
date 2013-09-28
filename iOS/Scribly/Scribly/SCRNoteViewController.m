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

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1);
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGRect headerViewFrame = self.headerView.frame;
        headerViewFrame.size.height = - scrollView.contentOffset.y;
        self.headerView.frame = headerViewFrame;
        self.releaseText.center = self.headerView.center;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < - 30) {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect headerViewFrame = self.headerView.frame;
            headerViewFrame.size.height = self.view.frame.size.height;
            self.headerView.frame = headerViewFrame;
            self.headerView.layer.opacity = 0;
            
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.origin.y = self.view.frame.size.height;
            self.scrollView.frame = scrollViewFrame;
        }];
    } else {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)noteSelected:(Note *)note {
    [UIView animateWithDuration:1.0 animations:^{
        CGRect headerViewFrame = self.headerView.frame;
        headerViewFrame.size.height = 0;
        self.headerView.frame = headerViewFrame;
        self.headerView.layer.opacity = 1;
        
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.origin.y = 0;
        self.scrollView.frame = scrollViewFrame;
    }];
}

@end
