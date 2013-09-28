//
//  SCRNoteViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteViewController.h"
#import "SCRNoteManager.h"
#import "Note.h"
#import "NoteCategory.h"

@interface SCRNoteViewController ()

@end

@implementation SCRNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.noteManager = [SCRNoteManager sharedSingleton];
    [self.noteManager addNoteWithText:@"TestNote" WithID:@19201];
    [self.noteManager addCategoryWithID:@18101 WithName:@"Tests!" WithScore:@9001];
    [self.noteManager updateNote:@19201 WithText:@"TestNoteUpdate"];
    
    NSArray *notes = [self.noteManager getNotes];
    for(Note *note in notes) {
        NSLog(@"%@, %@", note.text, note.id);
    }
    
    NSArray *categories = [self.noteManager getCategories];
    for(NoteCategory *category in categories) {
        NSLog(@"%@, %@, %@", category.id, category.name, category.score);
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *hello = [[UILabel alloc] initWithFrame:CGRectZero];
    hello.text = @"Hello World!";
    [hello sizeToFit];
    CGRect helloFrame = hello.frame;
    helloFrame.origin.y += 200;
    hello.frame = helloFrame;
    [self.view addSubview:hello];
    [self.view setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
