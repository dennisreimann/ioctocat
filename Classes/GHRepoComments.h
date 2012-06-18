#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHRepoComments : GHResource {
	NSMutableArray *comments;
	NSString *sha;
	GHRepository *repository;
}

@property(nonatomic,retain)NSMutableArray *comments;
@property(nonatomic,retain)NSString *sha;
@property(nonatomic,retain)GHRepository *repository;

+ (id)commentsWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;
- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;

@end
