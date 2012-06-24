#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssueComments, GHRepository, GHUser;

@interface GHIssue : GHResource <GHResourceDelegate> {
	GHUser *user;
	GHRepository *repository;
	GHIssueComments *comments;
	NSString *title;
	NSString *body;
	NSString *state;
	NSArray *labels;
	NSDate *created;
	NSDate *updated;
	NSDate *closed;
	NSURL *htmlURL;
	NSInteger votes;
	NSInteger num;
}

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

+ (id)issueWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;
- (void)closeIssue;
- (void)reopenIssue;
- (void)saveData;

@end
