//
//  SCRNoteViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteCategory.h"
#import "Note.h"

@interface SCRNoteViewController : UIViewController <UIScrollViewDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

typedef NS_ENUM(NSInteger, SCRNoteViewControllerMode) {
    SCRNoteViewControllerModeCategory,
    SCRNoteViewControllerModeNoteViewing,
    SCRNoteViewControllerModeNoteEditing
};

- (id)initWithNote:(Note *)note;
- (id)initWithCategory:(NoteCategory *) category;
- (id)initWithMode:(SCRNoteViewControllerMode)mode;

@end
