//
//  SCRCategoryGridView.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRCategoryGridView.h"
#import "SCRNoteManager.h"

@implementation SCRCategoryGridView

- (void)itemSelected {
    NSArray *categories = [[SCRNoteManager sharedSingleton] getCategories];
    [self.delegate itemSelected:categories[0]];
}

@end
