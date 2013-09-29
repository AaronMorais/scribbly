//
//  SCRNoteManager.h
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "NoteCategory.h"

@interface SCRNoteManager : NSObject

@property (assign, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (SCRNoteManager *)sharedSingleton;
- (void)addNoteWithText:(NSString *)text WithID:(NSNumber *)ID;
- (void)updateNote:(NSNumber *)ID WithText:(NSString *)text;
- (void)addCategoryWithID:(NSNumber *)ID WithName:(NSString *)name WithScore:(NSNumber *)score;
- (Note *)getNoteWithID:(NSNumber *)ID;
- (NoteCategory *)getNoteCategoryWithName:(NSString *)name;
- (NSArray *)getNotes;
- (void)clearNotes;
- (NSArray *)getCategories;
- (void)clearCategories;
- (NSArray *)getRecord:(NSString *)entityName;

@end
