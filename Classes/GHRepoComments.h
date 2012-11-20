#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHRepoComments : GHResource {
	NSMutableArray *comments;
	NSString *commitID;
	GHRepository *repository;
}

@property(nonatomic,retain)NSMutableArray *comments;
@property(nonatomic,retain)NSString *commitID;
@property(nonatomic,retain)GHRepository *repository;

+ (id)commentsWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID;
- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID;

@end