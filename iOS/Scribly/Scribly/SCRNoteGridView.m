//
//  SCRNoteGridView.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteGridView.h"
#import "SCRNoteManager.h"

@implementation SCRNoteGridView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f];
        self.backgroundColor = [UIColor blueColor];
        self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button.frame = CGRectMake(0, 0, 200, 200);
        [self.button setTitle:@"CLICKEZ MOI" forState:UIControlStateNormal];
        [self.button.titleLabel sizeToFit];
        self.button.backgroundColor = [UIColor redColor];
        [self.button addTarget:self action:@selector(noteSelected) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.center = self.center;
}

- (void) noteSelected {
    NSArray *notes = [[SCRNoteManager sharedSingleton] getNotes];
    [self.delegate noteSelected:notes[0]];
}

@end
