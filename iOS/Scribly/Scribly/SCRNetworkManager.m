//
//  SCRNetworkManager.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNetworkManager.h"

@implementation SCRNetworkManager

static SCRNetworkManager *sharedSingleton;

+ (SCRNetworkManager *)sharedSingleton {
  static SCRNetworkManager *sharedSingleton;

  @synchronized(self) {
    if (!sharedSingleton) {
      sharedSingleton = [[SCRNetworkManager alloc] init];
    }
    return sharedSingleton;
  }
}

@end
