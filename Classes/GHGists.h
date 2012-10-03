#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHGists : GHResource {
	NSMutableArray *gists;
}

@property(nonatomic,retain)NSMutableArray *gists;

+ (id)gistsWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

@end
