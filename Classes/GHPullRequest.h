#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssueComments, GHRepository, GHUser;

@interface GHPullRequest : GHResource

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHIssueComments *comments;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *body;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSArray *labels;
@property(nonatomic,retain)NSDate *created;
@property(nonatomic,retain)NSDate *updated;
@property(nonatomic,retain)NSDate *closed;
@property(nonatomic,retain)NSURL *htmlURL;
@property(nonatomic,readwrite)NSInteger num;
@property(nonatomic,readwrite)NSInteger votes;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)BOOL isClosed;

+ (id)pullRequestWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)mergePullRequest;
- (void)saveData;

@end