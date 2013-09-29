//
//  SCRCategoryGridViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRCategoryGridViewController.h"
#import "SCRNoteViewController.h"

@interface SCRCategoryGridViewController ()

@end

@implementation SCRCategoryGridViewController

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Categories";
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    SCRNoteGridView *gridView = [[SCRNoteGridView alloc] init];
    gridView.frame = self.view.bounds;
    gridView.delegate = self;
    [gridView.button setTitle:@"BASE!" forState:UIControlStateNormal];
    [self.view addSubview:gridView];
}

- (void)itemSelected:(NSObject *)note {
    NSArray *notes = [[SCRNoteManager sharedSingleton] getNotes];
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithNote:notes[0]] animated:YES];
}

@end
