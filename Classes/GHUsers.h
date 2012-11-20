#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHUsers : GHResource {
	NSMutableArray *users;
}

@property(nonatomic,retain)NSMutableArray *users;

+ (id)usersWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

@end