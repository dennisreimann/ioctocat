#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHRepoComments : GHResource

@property(nonatomic,strong)NSMutableArray *comments;
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)GHRepository *repository;

+ (id)commentsWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID;
- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID;

@end