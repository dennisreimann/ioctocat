#import "GHResource.h"


@class GHRepository, GHUser;

@interface GHMilestone : GHResource
@property(nonatomic,strong)GHUser *creator;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *dueOn;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,assign)NSInteger openIssueCount;
@property(nonatomic,assign)NSInteger closedIssueCount;
@property(nonatomic,readonly)NSInteger percentDone;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)NSString *bodyForDisplay;

- (id)initWithRepository:(GHRepository *)repo;
@end
