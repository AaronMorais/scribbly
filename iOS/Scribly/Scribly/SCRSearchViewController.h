//
//  SCRSearchViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-29.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCRSearchViewController : UIViewController <UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) UISearchDisplayController *sDisplayController;

@end


