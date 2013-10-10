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

@interface SCRCategoryViewController : UIViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource, SCRSearchDelegateProtocol>

@end
