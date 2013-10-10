//
//  SCRNetwork.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNetwork.h"

@implementation SCRNetwork

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

@end
