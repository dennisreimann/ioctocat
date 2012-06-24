#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHRepositories : GHResource {
	NSMutableArray *repositories;
}

@property(nonatomic,retain)NSMutableArray *repositories;

+ (id)repositoriesWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

@end
