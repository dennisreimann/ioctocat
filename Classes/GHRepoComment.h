#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHComment.h"


@class GHRepository, GHUser;

@interface GHRepoComment : GHComment {
	GHRepository *repository;
	NSString *commitID;
	NSString *path;
	NSUInteger position;
	NSUInteger line;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSString *commitID;
@property(nonatomic,retain)NSString *path;
@property(nonatomic,assign)NSUInteger position;
@property(nonatomic,assign)NSUInteger line;

+ (id)commentWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict;
+ (id)commentWithRepo:(GHRepository *)theRepo;
- (id)initWithRepo:(GHRepository *)theRepo andDictionary:(NSDictionary *)theDict;
- (id)initWithRepo:(GHRepository *)theRepo;

@end
