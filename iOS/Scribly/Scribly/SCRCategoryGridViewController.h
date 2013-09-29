//
//  SCRCategoryGridViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"

@interface SCRCategoryGridViewController : UIViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) UISearchDisplayController *sDisplayController;
@property (nonatomic, retain) NSArray *categories;
@property NSMutableArray *colors;
@property UICollectionView *collectionView;

@end
