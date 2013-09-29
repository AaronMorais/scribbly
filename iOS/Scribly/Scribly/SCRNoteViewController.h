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

@interface SCRNoteViewController : UIViewController <UIScrollViewDelegate, SCRNoteGridViewProtocol>

@property (nonatomic, retain) SCRNoteManager *noteManager;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) SCRNoteGridView *categoryView;
@property (nonatomic, retain) UILabel *releaseText;

@end
