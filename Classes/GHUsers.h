#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHUsers : GHResource {
	NSMutableArray *users;
}

@property(nonatomic,retain)NSMutableArray *users;

+ (id)usersWithURL:(NSURL *)theURL;
- (id)initWithURL:(NSURL *)theURL;

@end
