#import <Foundation/Foundation.h>


@interface Archiver : NSObject {
  @private
	NSString *fileName;
	NSString *key;
}

- (id)initWithKey:(NSString *)theKey andFileName:(NSString *)theFileName;
- (void)archiveObject:(id)theObject;
- (id)restoreObject;

@end
