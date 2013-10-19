//
//  SCRNetworkManager.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNetworkManager.h"
#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

static NSString * const endpoint = @"http://162.243.28.10:1337";

@implementation SCRNetworkManager

+ (SCRNetworkManager *)sharedSingleton {
  static SCRNetworkManager *sharedSingleton;

  @synchronized(self) {
    if (!sharedSingleton) {
      sharedSingleton = [[SCRNetworkManager alloc] init];
    }
    return sharedSingleton;
  }
}

- (NSString *)apiEndpoint {
    return endpoint;
}

- (NSString *)userToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs objectForKey:@"userToken"];
    if (!token) {
        NSString *urlString = [NSString stringWithFormat:@"%@/user/create", [self apiEndpoint]];
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error;
        NSDictionary *jsonResultSet = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        token = jsonResultSet[@"token"];
        [prefs setObject:token forKey:@"userToken"];
    }
    return token;
}

- (void)trackViewForNote:(Note *)note {
    NSString *token = [self userToken];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[self apiEndpoint]]];
    NSDictionary *params = @{@"token":token, @"id":note.identifier};
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[client requestWithMethod:@"GET" path:@"/note/view" parameters:params]
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    [operation start];
}

@end
