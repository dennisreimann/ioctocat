#import "Archiver.h"


@implementation Archiver

- (id)initWithKey:(NSString *)theKey andFileName:(NSString *)theFileName{
	[super init];
	key = [theKey retain];
	fileName = [theFileName retain];
	return self;
}

- (NSString *)filePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)archiveObject:(id)theObject {
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:theObject forKey:key];
	[archiver finishEncoding];
	NSString *path = [self filePath];
	[data writeToFile:path atomically:YES];
	[data release];
	[archiver release];
}

- (id)restoreObject {
	NSData *data = [NSData dataWithContentsOfFile:[self filePath]];
	if (!data) return nil;
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	id loadedObject = [unarchiver decodeObjectForKey:key];
	[unarchiver finishDecoding];
	[unarchiver release];
	return loadedObject;
}

- (void)dealloc {
	[fileName release];
	[key release];
	[super dealloc];
}

@end
