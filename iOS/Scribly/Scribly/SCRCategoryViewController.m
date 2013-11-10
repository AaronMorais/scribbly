//
//  SCRCategoryGridViewController.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRCategoryViewController.h"
#import "SCRNoteViewController.h"
#import "SCRNetworkManager.h"
#import "NoteCategory.h"

#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

@interface SCRCollectionViewCell : UICollectionViewCell

@property(nonatomic, retain) UILabel *descriptionLabel;

@end

@implementation SCRCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.minimumScaleFactor = 0.5;
        _descriptionLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_descriptionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect descriptionFrame = self.bounds;
    descriptionFrame.size.width -= 20;
    descriptionFrame.origin.x = floorf((self.bounds.size.width - descriptionFrame.size.width) / 2);
    self.descriptionLabel.frame = descriptionFrame;
}

@end


@interface SCRCategoryViewController ()

@property (nonatomic, retain) AFJSONRequestOperation *categoryRequestOperation;
@property (nonatomic, retain) NSArray *noteCategories;
@property (nonatomic, retain) NSMutableArray *categoryColors;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) UINavigationController *searchNavController;

@end

@implementation SCRCategoryViewController

- (id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Categories";
        self.edgesForExtendedLayout = UIRectEdgeNone;
        _categoryColors = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // add search button to navigation bar
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                  target:self
                                                                                  action:@selector(searchButtonPressed:)];
    self.navigationItem.leftBarButtonItem = searchButton;
    // add new note button to navigation bar
    UIBarButtonItem *newNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(newNoteButtonPressed:)];
    self.navigationItem.rightBarButtonItem = newNoteButton;
    // initialize layout for collection view
    RFQuiltLayout *layout = [[RFQuiltLayout alloc] init];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(106.6, 101);
    layout.delegate = self;
    // initialize collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    [self.collectionView registerClass:[SCRCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSData *data = [prefs objectForKey:@"categories"];
    NSArray *cachedCategories = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.noteCategories = cachedCategories ? : [NSArray array];
    [self.collectionView reloadData];
    
    NSString *token = [[SCRNetworkManager sharedSingleton] userToken];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[SCRNetworkManager sharedSingleton] apiEndpoint]]];
    NSDictionary *params = @{@"token":token};
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[client requestWithMethod:@"GET" path:@"/category/all"  parameters:params]
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([JSON isKindOfClass:[NSArray class]]) {
            NSMutableArray *results = [NSMutableArray array];
            for (NSDictionary *result in (NSArray *)JSON) {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    NoteCategory *category = [[NoteCategory alloc] init];
                    category.identifier = result[@"id"];
                    category.name = result[@"name"];
                    category.score = result[@"score"];
                    [results addObject:category];
                }
            }
            BOOL shouldUpdate = [self shouldUpdateCategoriesWithArray:results];
            if (shouldUpdate) {
                self.noteCategories = results;
                [self.collectionView reloadData];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:results];
                [prefs setObject:data forKey:@"categories"];
            }
        }
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    
    [self.categoryRequestOperation cancel];
    self.categoryRequestOperation = operation;
    [operation start];
}

- (BOOL)shouldUpdateCategoriesWithArray:(NSArray *)newCategories {
    if ([newCategories count] != [self.noteCategories count]) {
        return YES;
    }
    for (int i=0; i<[self.noteCategories count]; i++) {
        if (![((NoteCategory *)[self.noteCategories objectAtIndex:i]) isEqual:[newCategories objectAtIndex:i]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark Button actions

- (void)searchButtonPressed:(id)sender {
    SCRSearchViewController *searchViewController = [[SCRSearchViewController alloc] init];
    searchViewController.delegate = self;
    UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchNavController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.searchNavController = searchNavController;
    [self.navigationController presentViewController:searchNavController animated:YES completion:nil];
}

- (void)newNoteButtonPressed:(id)sender {
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithMode:SCRNoteViewControllerModeNoteEditing] animated:YES];
}

#pragma mark SCRSearchDelegate

- (void)presentNoteControllerWithNote:(Note *)note {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithNote:note] animated:YES];
    }];
}

#pragma mark UICollectionViewDelegate & UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.noteCategories count] > 0 ? 1 : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.noteCategories count];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteCategory *noteCategory = [self.noteCategories objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[[SCRNoteViewController alloc] initWithCategory:noteCategory] animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCRCollectionViewCell *cell= (SCRCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    NoteCategory *noteCategory = [self.noteCategories objectAtIndex:indexPath.row];
    cell.descriptionLabel.text = noteCategory.name;
    
    UIColor *color;
    // we store the category colors so that the indices get only one color per app load
    if ([self.categoryColors count] <= indexPath.row ) {
        color = [self randomFlatColorForIndex:indexPath.row];
        [self.categoryColors addObject:color];
    } else {
        color = [self.categoryColors objectAtIndex:indexPath.row];
    }
    if (color) {
        cell.backgroundColor = color;
    }
    return cell;
}

- (UIColor *)randomFlatColorForIndex:(NSInteger)index {
    NSArray *colors;
    if (index % 4 == 0) {
        colors = @[
            [UIColor colorWithRed:231.0f/256.0f green:76.0f/256.0f blue:60.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:230.0f/256.0f green:126.0f/256.0f blue:34.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:241.0f/256.0f green:196.0f/256.0f blue:15.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:155.0f/256.f green:89.0f/256.0f blue:182.0f/256.0f alpha:1.0f]];
    } else if(index % 4 == 1) {
        colors = @[
            [UIColor colorWithRed:192.0f/256.0f green:57.0f/256.0f blue:43.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:230.0f/256.0f green:126.0f/256.0f blue:34.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:243.0f/256.0f green:156.0f/256.0f blue:18.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:142.0f/256.0f green:68.0f/256.0f blue:173.0f/256.0f alpha:1.0f]];
    } else if(index % 4 == 2) {
        colors = @[
            [UIColor colorWithRed:52.0f/256.0f green:152.0f/256.0f blue:219.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:46.0f/256.0f green:204.0f/256.0f blue:113.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:26.0f/256.0f green:188.0f/256.0f blue:156.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:22.0f/256.0f green:160.0f/256.0f blue:133.0f/256.0f alpha:1.0f]];    
    } else {
        colors = @[
            [UIColor colorWithRed:41.0f/256.0f green:128.0f/256.0f blue:185.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:39.0f/256.0f green:174.0f/256.0f blue:96.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:22.0f/256.0f green:160.0f/256.0f blue:133.0f/256.0f alpha:1.0f],
            [UIColor colorWithRed:44.0f/256.0f green:62.0f/256.0f blue:80.0f/256.0f alpha:1.0f]];
    }
    uint32_t rnd = arc4random_uniform((int)[colors count]);
    return [colors objectAtIndex:rnd];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50, 50);
}

#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteCategory *noteCategory = [self.noteCategories objectAtIndex:indexPath.row];
    if ([noteCategory.score intValue] > 60) {
        return CGSizeMake(3, 2);
    } else if ([noteCategory.score intValue] > 30) {
        return CGSizeMake(2, 2);
    } else if ([noteCategory.score intValue] > 20) {
        return CGSizeMake(1, 2);
    } else if ([noteCategory.score intValue] > 10) {
        return CGSizeMake(2, 1);
    } else {
        return CGSizeMake(1, 1);
    }
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsZero;
}

@end
