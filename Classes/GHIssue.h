#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssueComments, GHRepository, GHUser;

@interface GHIssue : GHResource

@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHIssueComments *comments;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSArray *labels;
@property(nonatomic,strong)NSDate *created;
@property(nonatomic,strong)NSDate *updated;
@property(nonatomic,strong)NSDate *closed;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,readwrite)NSInteger num;
@property(nonatomic,readwrite)NSInteger votes;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)BOOL isClosed;

+ (id)issueWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)closeIssue;
- (void)reopenIssue;
- (void)saveData;

@end
