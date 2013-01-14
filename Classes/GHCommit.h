#import "GHResource.h"


@class GHUser, GHRepository, GHRepoComments, GHFiles;

@interface GHCommit : GHResource
@property(nonatomic,strong)NSString *commitID;
@property(nonatomic,strong)NSString *message;
@property(nonatomic,strong)NSString *authorName;
@property(nonatomic,strong)NSString *authorEmail;
@property(nonatomic,strong)NSString *committerName;
@property(nonatomic,strong)NSString *committerEmail;
@property(nonatomic,strong)NSDate *committedDate;
@property(nonatomic,strong)NSDate *authoredDate;
@property(nonatomic,strong)GHFiles *added;
@property(nonatomic,strong)GHFiles *modified;
@property(nonatomic,strong)GHFiles *removed;
@property(nonatomic,strong)GHUser *author;
@property(nonatomic,strong)GHUser *committer;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHRepoComments *comments;

- (id)initWithRepository:(GHRepository *)repo andCommitID:(NSString *)commitID;
@end
