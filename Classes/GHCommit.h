#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser, GHRepository, GHRepoComments;

@interface GHCommit : GHResource {
	NSString *commitID;
	NSString *message;
	NSURL *commitURL;
	NSString *authorName;
	NSString *authorEmail;
	NSString *committerName;
	NSString *committerEmail;
	NSDate *committedDate;
	NSDate *authoredDate;
	NSMutableArray *added;
	NSMutableArray *modified;
	NSMutableArray *removed;
	GHUser *author;
	GHUser *committer;
	GHRepository *repository;
	GHRepoComments *comments;
}

@property(nonatomic,retain)NSString *commitID;
@property(nonatomic,retain)NSString *message;
@property(nonatomic,retain)NSURL *commitURL;
@property(nonatomic,retain)NSString *authorName;
@property(nonatomic,retain)NSString *authorEmail;
@property(nonatomic,retain)NSString *committerName;
@property(nonatomic,retain)NSString *committerEmail;
@property(nonatomic,retain)NSDate *committedDate;
@property(nonatomic,retain)NSDate *authoredDate;
@property(nonatomic,retain)NSMutableArray *added;
@property(nonatomic,retain)NSMutableArray *modified;
@property(nonatomic,retain)NSMutableArray *removed;
@property(nonatomic,retain)GHUser *author;
@property(nonatomic,retain)GHUser *committer;
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHRepoComments *comments;

+ (id)commitWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID;
- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID;

@end
