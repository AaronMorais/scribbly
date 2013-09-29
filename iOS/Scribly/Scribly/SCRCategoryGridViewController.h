//
//  SCRCategoryGridViewController.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"

@interface SCRCategoryGridViewController : UIViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, retain) NSArray *categories;
@property NSMutableArray *colors;
@property UICollectionView *collectionView;
@end
