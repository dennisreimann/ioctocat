@class GHUser, GHOrganization, GHRepository, GHGist, GHCommits, GHIssue, GHPullRequest, GHComment, GHBranch, GHTag;

@interface GHEvent : NSObject
@property(nonatomic,strong)NSString *eventID;
@property(nonatomic,strong)NSString *eventType;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,strong)NSDictionary *payload;
@property(nonatomic,strong)NSString *repoName;
@property(nonatomic,strong)NSString *ref;
@property(nonatomic,strong)NSString *refType;
@property(nonatomic,strong)GHGist *gist;
@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHRepository *otherRepository;
@property(nonatomic,strong)GHPullRequest *pullRequest;
@property(nonatomic,strong)NSMutableArray *pages;
@property(nonatomic,strong)GHCommits *commits;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)GHUser *otherUser;
@property(nonatomic,strong)GHOrganization *organization;
@property(nonatomic,strong)GHBranch *branch;
@property(nonatomic,strong)GHTag *tag;
@property(nonatomic,readonly)NSString *contentForDisplay;
@property(nonatomic,readonly)NSString *extendedEventType;
@property(nonatomic,readonly)BOOL isCommentEvent;
@property(nonatomic,readonly)BOOL read;

- (id)initWithDict:(NSDictionary *)dict;
- (void)setValues:(id)dict;
- (void)markAsRead;
@end