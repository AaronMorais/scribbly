//
//  Note.h
//  
//
//  Created by Aaron Morais on 2013-09-29.
//
//

@interface Note : NSObject <NSCoding>

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * category;

@end
