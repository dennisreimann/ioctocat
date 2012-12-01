#import <Foundation/Foundation.h>


@class GHUser, GHOrganization, GHRepository, GHGist, GHIssue, GHPullRequest, GHComment;

@interface GHEvent : NSObject

@property(nonatomic,retain)NSString *eventID;
@property(nonatomic,retain)NSString *eventType;
@property(nonatomic,retain)NSDate *date;
@property(nonatomic,retain)NSDictionary *payload;
@property(nonatomic,retain)NSString *repoName;
@property(nonatomic,retain)NSString *otherRepoName;
@property(nonatomic,retain)GHGist *gist;
@property(nonatomic,retain)GHIssue *issue;
@property(nonatomic,retain)GHComment *comment;
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHRepository *otherRepository;
@property(nonatomic,retain)GHPullRequest *pullRequest;
@property(nonatomic,retain)NSMutableArray *pages;
@property(nonatomic,retain)NSMutableArray *commits;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)GHUser *otherUser;
@property(nonatomic,retain)GHOrganization *organization;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,readonly)NSString *extendedEventType;
@property(nonatomic,readonly)BOOL isCommentEvent;
@property(nonatomic,readwrite)BOOL read;

+ (id)eventWithDict:(NSDictionary *)theDict;
- (id)initWithDict:(NSDictionary *)theDict;

@end