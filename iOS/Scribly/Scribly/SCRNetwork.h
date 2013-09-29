//
//  SCRNetwork.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCRNetwork : NSObject<NSURLConnectionDelegate>
{
    NSString *_token;
    NSMutableData *_responseData;
    NSURLConnection *_tokenConnection;
    NSURLConnection *_categoriesConnection;
    NSURLConnection *_categoryNotesConnection;
    NSURLConnection *_noteViewConnection;
    NSURLConnection *_noteSaveConnection;
    NSURLConnection *_searchConnection;
}

+ (SCRNetwork *)sharedSingleton;
- (void)getUserToken;
- (void)getAllCategoriesWithQuery:(NSString *)query;
- (void)getNotesForCategoryWithName:(NSString *)name;
- (void)getNotesViewWithID:(NSNumber *)ID;
- (void)saveNotesWithText:(NSString *)text;
- (void)saveNotesWithID:(NSNumber *)ID WithText:(NSString *)text;
- (void)getSearcWithQuery:(NSString *)query;
@end
