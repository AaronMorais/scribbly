//
//  SCRNetworkManager.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "Note.h"

@interface SCRNetworkManager : NSObject

@property (nonatomic, retain) NSString *endpoint;

+ (SCRNetworkManager *)sharedSingleton;
- (NSString *)apiEndpoint;
- (NSString *)userToken;
- (void)trackViewForNote:(Note *)note;

@end
