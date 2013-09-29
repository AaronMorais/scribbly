//
//  SCRNoteViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRNoteManager.h"
#import "SCRNoteGridView.h"
#import "NoteCategory.h"
#import "Note.h"

@interface SCRNoteViewController : UIViewController <UIScrollViewDelegate, SCRNoteGridViewProtocol, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) SCRNoteManager *noteManager;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) SCRNoteGridView *categoryView;
@property (nonatomic, retain) UILabel *releaseText;
@property (nonatomic, assign) BOOL showingNotes;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL requestedNoteID;
@property (nonatomic, retain) NoteCategory *category;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) NSArray *notes;

- (id)initWithCategory:(NoteCategory *) category;

@end
