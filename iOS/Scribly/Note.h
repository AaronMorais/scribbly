//
//  Note.h
//  
//
//  Created by Aaron Morais on 2013-09-29.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * category;

@end
