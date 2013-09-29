//
//  SCRNetwork.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNetwork.h"

@implementation SCRNetwork

#define hostname @"172.21.167.83"
#define port @1337

static SCRNetwork *sharedSingleton;

+ (SCRNetwork *)sharedSingleton {
  static SCRNetwork *sharedSingleton;

  @synchronized(self) {
    if (!sharedSingleton) {
      sharedSingleton = [[SCRNetwork alloc] init];
    }
    return sharedSingleton;
  }
}

- (void)getUserToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *token = [prefs stringForKey:@"userToken"];
    if (!token) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/user/create", hostname, port]]];
        _tokenConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    } else {
        _token = token;
    }
}

- (void)getAllCategoriesWithQuery:(NSString *)query {
    query = [query stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/all?token=%@&query=%@", hostname, port, _token, query]]];
    // Create url connection and fire request
    _categoriesConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)getNotesForCategoryWithName:(NSString *)name {
    name = [name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/category/notes?token=%@&name=%@", hostname, port, _token, name]]];
    // Create url connection and fire request
    _categoryNotesConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)getNotesViewWithID:(NSNumber *)ID {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/note/view?token=%@&id=%@", hostname, port, _token, ID]]];
    // Create url connection and fire request
    _noteViewConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)saveNotesWithText:(NSString *)text {
    text = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/note/save?token=%@&text=%@", hostname, port, _token, text]]];
    // Create url connection and fire request
    _noteSaveConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)saveNotesWithID:(NSNumber *)ID WithText:(NSString *)text {
    text = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/note/save?token=%@&id=%@&text=%@", hostname, port, _token, ID, text]]];
    // Create url connection and fire request
    _noteSaveConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)getSearcWithQuery:(NSString *)query {
    query = [query stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/all?token=%@&query=%@", hostname, port, _token, query]]];
    // Create url connection and fire request
    _searchConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods
 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}
 
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    NSError *error = nil;
    NSDictionary *jsonResultSet = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (connection == _tokenConnection) {
        _token = jsonResultSet[@"token"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:_token forKey:@"userToken"];
    } else if (connection == _categoriesConnection) {
     
    } else if (connection == _categoryNotesConnection) {
    
    }
    
}
 
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection 
    return nil;
}
 
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}
 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
