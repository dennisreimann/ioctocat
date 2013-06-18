#import "GHResource.h"


@class GHIssueComments, GHRepository, GHUser, GHMilestone, GHLabels;

@interface GHIssue : GHResource
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)GHUser *assignee;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHIssueComments *comments;
@property(nonatomic,strong)GHMilestone *milestone;
@property(nonatomic,strong)GHLabels *labels;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,strong)NSDate *closedAt;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)NSString *repoIdWithIssueNumber;
@property(nonatomic,readonly)NSMutableAttributedString *attributedBody;

- (id)initWithRepository:(GHRepository *)repo;
@end
