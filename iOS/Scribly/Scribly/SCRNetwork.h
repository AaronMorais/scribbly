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
    NSMutableData *_responseData;
    NSURLConnection *_categoriesConnection;
    NSURLConnection *_categoryNotesConnection;
    NSURLConnection *_noteViewConnection;
    NSURLConnection *_noteSaveConnection;
    NSURLConnection *_searchConnection;
}
@end
