//
//  SCRNoteManager.m
//  Scribly
//
//  Created by Aaron Morais on 2013-09-28.
//  Copyright (c) 2013 Aaron Morais. All rights reserved.
//

#import "SCRNoteManager.h"
#import "Note.h"
#import "NoteCategory.h"
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
    newEntry.id = ID;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (void)updateNote:(NSNumber *)ID WithText:(NSString *)text {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", ID];
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
    newEntry.id = ID;
    newEntry.name = name;
    newEntry.score = score;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
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
