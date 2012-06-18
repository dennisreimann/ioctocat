#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHRepository, GHUser;

@interface GHRepoComment : GHComment {
	GHRepository *repository;
	NSString *sha;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSString *sha;

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha andDictionary:(NSDictionary *)theDict;
- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;
- (void)saveData;

@end
