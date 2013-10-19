//
//  SCRScribblyAPIClient.m
//  Scribbly
//
//  Created by Aaron Morais on 2013-10-17.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRScribblyAPIClient.h"
#import "SCRNetworkManager.h"

@implementation SCRScribblyAPIClient

+ (SCRScribblyAPIClient *)sharedClient {
    static SCRScribblyAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[[SCRNetworkManager sharedSingleton] apiEndpoint]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

#pragma mark - AFIncrementalStore

// TODO: find a cleaner way to form the request without using a predicate
// find a way to use something cleaner than the requested category string
static NSString *requestedCategory = nil;

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context {
    NSMutableDictionary *params = [@{@"token":[[SCRNetworkManager sharedSingleton] userToken]} mutableCopy];
    NSMutableURLRequest *mutableURLRequest = nil;
    if([fetchRequest.entityName isEqualToString:@"NoteCategory"]) {
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"category/all" parameters:params];
    } else if([fetchRequest.entityName isEqualToString:@"Note"]) {
        if ([fetchRequest.predicate isKindOfClass:[NSComparisonPredicate class]]) {
            NSComparisonPredicate *predicate = (NSComparisonPredicate *)fetchRequest.predicate;
            requestedCategory = [NSString stringWithFormat:@"%@", predicate.rightExpression.constantValue];
            [params setValue:[NSString stringWithFormat:@"%@", predicate.rightExpression.constantValue] forKey:@"name"];
        }
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"category/notes" parameters:params];
    }
    return mutableURLRequest;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation 
                                     ofEntity:(NSEntityDescription *)entity 
                                 fromResponse:(NSHTTPURLResponse *)response {
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    if ([entity.name isEqualToString:@"Note"]) {
        [mutablePropertyValues setValue:[representation valueForKey:@"id"] forKey:@"identifier"];
        [mutablePropertyValues setValue:[representation valueForKey:@"text"] forKey:@"text"];
        [mutablePropertyValues setValue:requestedCategory forKey:@"category"];
    }
    return mutablePropertyValues;
}
@end