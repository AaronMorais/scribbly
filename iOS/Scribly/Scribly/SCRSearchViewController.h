//
//  SCRSearchViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-29.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol SCRSearchDelegate <NSObject>
- (void)presentNoteControllerWithNote:(Note *)note;
@end

@interface SCRSearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) id<SCRSearchDelegate> delegate;

@end


