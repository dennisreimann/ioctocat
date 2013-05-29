#import "GHResource.h"


@class GHUser, GHGists, GHGistComments, GHFiles;

@interface GHGist : GHResource
@property(nonatomic,strong)NSString *gistId;
@property(nonatomic,strong)GHGists *forks;
@property(nonatomic,strong)GHGistComments *comments;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,strong)NSString *descriptionText;
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)NSString *title;
@property(nonatomic,readwrite)NSUInteger commentsCount;
@property(nonatomic,readwrite)NSUInteger forksCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(nonatomic,readwrite)BOOL isFork;

- (id)initWithId:(NSString *)gistId;
@end