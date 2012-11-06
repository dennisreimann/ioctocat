#import <Foundation/Foundation.h>


@class GHUser, GHOrganization, GHRepository, GHGist, GHIssue;

@interface GHEvent : NSObject

@property(nonatomic,retain)NSString *eventID;
@property(nonatomic,retain)NSString *eventType;
@property(nonatomic,retain)NSDate *date;
@property(nonatomic,retain)NSDictionary *payload;
@property(nonatomic,retain)NSString *actorLogin;
@property(nonatomic,retain)NSString *otherUserLogin;
@property(nonatomic,retain)NSString *orgLogin;
@property(nonatomic,retain)NSString *repoName;
@property(nonatomic,retain)NSString *otherRepoName;
@property(nonatomic,retain)GHGist *gist;
@property(nonatomic,retain)GHIssue *issue;
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHRepository *otherRepository;
@property(nonatomic,retain)NSMutableArray *pages;
@property(nonatomic,retain)NSMutableArray *commits;
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,readonly)GHUser *otherUser;
@property(nonatomic,readonly)GHOrganization *organization;
@property(nonatomic,readonly)NSString *title;
@property(nonatomic,readonly)NSString *content;
@property(nonatomic,readonly)NSString *extendedEventType;
@property(nonatomic,readwrite)BOOL read;

+ (id)eventWithDict:(NSDictionary *)theDict;
- (id)initWithDict:(NSDictionary *)theDict;

@end
