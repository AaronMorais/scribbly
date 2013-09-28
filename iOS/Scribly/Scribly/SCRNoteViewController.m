//
//  SCRNoteViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteViewController.h"

@interface SCRNoteViewController ()

@end

@implementation SCRNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
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
