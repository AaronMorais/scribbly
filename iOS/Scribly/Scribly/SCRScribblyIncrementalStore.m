//
//  SCRScribblyIncrementalStore.m
//  Scribbly
//
//  Created by Aaron Morais on 2013-10-17.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRScribblyIncrementalStore.h"
#import "SCRScribblyAPIClient.h"

@implementation SCRScribblyIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Scribly" withExtension:@"xcdatamodeld"]];
}

- (id <AFIncrementalStoreHTTPClient>)HTTPClient {
    return [SCRScribblyAPIClient sharedClient];
}

@end