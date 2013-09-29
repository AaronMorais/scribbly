//
//  SCRCategoryGridViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"
#import "SCRSearchViewController.h"

@interface SCRCategoryGridViewController : UIViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SCRSearchDelegateProtocol>

@property (nonatomic, retain) NSArray *categories;
@property NSMutableArray *colors;
@property UICollectionView *collectionView;

@property UINavigationController *searchNavController;

@end
