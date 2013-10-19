//
//  SCRScribblyAPIClient.h
//  Scribbly
//
//  Created by Aaron Morais on 2013-10-17.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "AFRESTClient.h"
#import "AFIncrementalStore.h"

@interface SCRScribblyAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (SCRScribblyAPIClient *)sharedClient;

@end
