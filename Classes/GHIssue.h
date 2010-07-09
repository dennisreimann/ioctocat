#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"


@class GHIssueComments;

@interface GHIssue : GHResource <GHResourceDelegate> {
	GHRepository *repository;
	GHIssueComments *comments;
	NSString *user;
	NSString *title;
	NSString *body;
	NSString *state;
	NSString *type;
	NSDate *created;
	NSDate *updated;
	NSInteger votes;
	NSInteger num;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHIssueComments *comments;
@property(nonatomic,retain)NSString *user;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *body;
@property(nonatomic,retain)NSString *state;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSDate *created;
@property(nonatomic,retain)NSDate *updated;
@property(nonatomic,readwrite)NSInteger num;
@property(nonatomic,readwrite)NSInteger votes;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)BOOL isClosed;

- (id)initWithRepository:(GHRepository *)theRepository;
- (void)closeIssue;
- (void)reopenIssue;
- (void)saveData;

@end
