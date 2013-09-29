//
//  SCRCategoryGridViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRCategoryGridViewController.h"
#import "SCRNoteViewController.h"
#import "NoteCategory.h"
#import <AFHTTPRequestOperationManager.h>

@interface SCRCategoryGridViewController ()

@end

@interface SCRCollectionViewCell : UICollectionViewCell

@property(nonatomic, retain) UILabel *descriptionLabel;

@end

@implementation SCRCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.text = @"";
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.minimumScaleFactor = 0.5;
        self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.descriptionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize size = [self.descriptionLabel sizeThatFits:CGSizeMake(self.frame.size.width - 20, INT_MAX)];
    CGRect descriptionFrame = self.bounds;
    descriptionFrame.size.width = size.width;
    self.descriptionLabel.frame = self.bounds;
}

@end

@implementation SCRCategoryGridViewController

- (id)init {
    self = [super init];
    if (self) {
        self.colors = [NSMutableArray array];
        self.navigationItem.title = @"Categories";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.categories = [[SCRNoteManager sharedSingleton] getCategories];
        self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    RFQuiltLayout *layout = [[RFQuiltLayout alloc] init];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(106.6, 100);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    layout.delegate = self;
    [self.collectionView registerClass:[SCRCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];
    self.navigationItem.rightBarButtonItem = newButton;
}

- (void)newNote {
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithCategory:nil] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
}

- (void)refresh {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs objectForKey:@"userToken"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"token":token};
    [manager GET:@"http://kevinbedi.com:9321/category/all" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[SCRNoteManager sharedSingleton] clearCategories];
        NSArray *jsonResponseObject = (NSArray *)responseObject;
        for (NSDictionary *jsonCategory in jsonResponseObject) {
            [[SCRNoteManager sharedSingleton] addCategoryWithID:jsonCategory[@"id"] WithName:jsonCategory[@"name"] WithScore:jsonCategory[@"score"]];
        }
        self.categories = [[SCRNoteManager sharedSingleton] getCategories];
        [self.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSArray *)categories {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score"
                                                  ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    return [_categories sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark CollectionView Delegate and DataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.categories count];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithCategory:self.categories[indexPath.row]] animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SCRCollectionViewCell *cell=(SCRCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    cell.backgroundColor = [self randomFlatColorWithSeed:indexPath.row];
    
    NoteCategory *category = self.categories[indexPath.row];
    cell.descriptionLabel.text = category.name;
    
    if ([self.colors count] <= indexPath.row ) {
        UIColor *color = [self randomFlatColorWithSeed:indexPath.row];
        cell.backgroundColor = color;
        [self.colors addObject:color];
    } else {
        cell.backgroundColor = [self.colors objectAtIndex:indexPath.row];
    }
    return cell;
}

- (UIColor *)randomFlatColorWithSeed:(NSInteger)seed {
    NSArray *colors;
    if (seed % 2 == 0) {
        colors = @[
            [UIColor colorWithRed:26.0f/255.0f green:188.0f/255.0f blue:156.0f/255.0f alpha:1.0f],
            [UIColor colorWithRed:46.0f/255.0f green:204.0f/255.0f blue:113.0f/255.0f alpha:1.0f],
            [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    } else {
        colors = @[
            [UIColor colorWithRed:155.0f/255.0f green:89.0f/255.0f blue:182.0f/255.0f alpha:1.0f],
            [UIColor colorWithRed:44.0f/255.0f green:62.0f/255.0f blue:80.0f/255.0f alpha:1.0f],
            [UIColor colorWithRed:230.0f/255.0f green:126.0f/255.0f blue:34.0f/255.0f alpha:1.0f]];
    }
    uint32_t rnd = arc4random_uniform([colors count]);
    return [colors objectAtIndex:rnd];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
}

#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteCategory *category = self.categories[indexPath.row];
    if ([category.score intValue] > 60) {
        return CGSizeMake(3, 2);
    } else if ([category.score intValue] > 30) {
        return CGSizeMake(2, 2);
    } else if ([category.score intValue] > 10) {
        return CGSizeMake(2, 1);
    } else {
        return CGSizeMake(1, 1);
    }
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

@end
