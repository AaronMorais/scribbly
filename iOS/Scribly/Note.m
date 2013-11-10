//
//  Note.m
//  
//
//  Created by Aaron Morais on 2013-09-29.
//
//

#import "Note.h"

@implementation Note

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _text = [aDecoder decodeObjectForKey:@"text"];
        _category = [aDecoder decodeObjectForKey:@"category"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.category forKey:@"category"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Note class]]) {
        Note *category = (Note *)object;
        if ([self.identifier isEqualToNumber:category.identifier] && [self.text isEqualToString:category.text] && [self.category isEqualToString:category.category]) {
            return YES;
        }
    }
    return NO;
}

@end
