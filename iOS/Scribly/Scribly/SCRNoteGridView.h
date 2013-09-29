//
//  SCRNoteGridView.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol SCRNoteGridViewProtocol <NSObject>
- (void)itemSelected:(NSObject *)note;
@end

@interface SCRNoteGridView : UIView

@property (nonatomic, strong) id<SCRNoteGridViewProtocol> delegate;

@property (nonatomic, strong) UIButton *button;

- (void) itemSelected;

@end
