//
//  SCRNoteManager.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteManager.h"
#import "SCRAppDelegate.h"

@implementation SCRNoteManager

static SCRNoteManager *sharedSingleton;

+ (SCRNoteManager *)sharedSingleton {
  static SCRNoteManager *sharedSingleton;

  @synchronized(self) {
    if (!sharedSingleton) {
      sharedSingleton = [[SCRNoteManager alloc] init];
      SCRAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
      sharedSingleton.managedObjectContext = appDelegate.managedObjectContext;
    }
    return sharedSingleton;
  }
}

- (void)addNoteWithText:(NSString *)text WithID:(NSNumber *)ID {
    Note *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                    inManagedObjectContext:self.managedObjectContext];
    newEntry.text = text;
    newEntry.identifier = ID;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (Note *)getNoteWithID:(NSNumber *)ID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", ID];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return results[0];
}

- (NoteCategory *)getNoteCategoryWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"NoteCategory" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    return results[0];
}

- (void)updateNote:(NSNumber *)ID WithText:(NSString *)text {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", ID];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    for (Note* note in results) {
        note.text = text;
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (void)addCategoryWithID:(NSNumber *)ID WithName:(NSString *)name WithScore:(NSNumber *)score {
    NoteCategory *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"NoteCategory"
                                                    inManagedObjectContext:self.managedObjectContext];
    newEntry.identifier = ID;
    newEntry.name = name;
    newEntry.score = score;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (void)clearNotes {
    NSFetchRequest * allCategories = [[NSFetchRequest alloc] init];
    [allCategories setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext]];
    [allCategories setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * categories = [self.managedObjectContext executeFetchRequest:allCategories error:&error];
    
    for (NSManagedObject * category in categories) {
        [self.managedObjectContext deleteObject:category];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

- (void)clearCategories {
    NSFetchRequest * allCategories = [[NSFetchRequest alloc] init];
    [allCategories setEntity:[NSEntityDescription entityForName:@"NoteCategory" inManagedObjectContext:self.managedObjectContext]];
    [allCategories setIncludesPropertyValues:NO];

    NSError * error = nil;
    NSArray * categories = [self.managedObjectContext executeFetchRequest:allCategories error:&error];
    
    for (NSManagedObject * category in categories) {
        [self.managedObjectContext deleteObject:category];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

- (NSArray *)getNotes {
    return [self getRecord:@"Note"];
}

- (NSArray *)getCategories {
    return [self getRecord:@"NoteCategory"];
}

- (NSArray *)getRecord:(NSString *)entityName {
  // initializing NSFetchRequest
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 
  //Setting Entity to be Queried
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  NSError* error;
 
  // Query on managedObjectContext With Generated fetchRequest
  NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
 
  // Returning Fetched Records
  return fetchedRecords;
}

@end
