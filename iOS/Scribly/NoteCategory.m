//
//  NoteCategory.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "NoteCategory.h"

@implementation NoteCategory

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _score = [aDecoder decodeObjectForKey:@"score"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.score forKey:@"score"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NoteCategory class]]) {
        NoteCategory *category = (NoteCategory *)object;
        if ([self.identifier isEqualToNumber:category.identifier] && [self.name isEqualToString:category.name] && [self.score isEqualToNumber:category.score]) {
            return YES;
        }
    }
    return NO;
}

@end
