#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser, GHRepository;

@interface GHCommit : GHResource {
	NSString *commitID;
	NSString *tree;
	NSString *message;
	NSURL *commitURL;
	NSString *authorName;
	NSString *authorEmail;
	NSString *committerName;
	NSString *committerEmail;
	NSDate *committedDate;
	NSDate *authoredDate;
	NSArray *added;
	NSArray *modified;
	NSArray *removed;
	NSArray *parents;
	GHUser *author;
	GHUser *committer;
	GHRepository *repository;
}

@property(nonatomic,retain)NSString *commitID;
@property(nonatomic,retain)NSString *tree;
@property(nonatomic,retain)NSString *message;
@property(nonatomic,retain)NSURL *commitURL;
@property(nonatomic,retain)NSString *authorName;
@property(nonatomic,retain)NSString *authorEmail;
@property(nonatomic,retain)NSString *committerName;
@property(nonatomic,retain)NSString *committerEmail;
@property(nonatomic,retain)NSDate *committedDate;
@property(nonatomic,retain)NSDate *authoredDate;
@property(nonatomic,retain)NSArray *added;
@property(nonatomic,retain)NSArray *modified;
@property(nonatomic,retain)NSArray *removed;
@property(nonatomic,retain)NSArray *parents;
@property(nonatomic,retain)GHUser *author;
@property(nonatomic,retain)GHUser *committer;
@property(nonatomic,retain)GHRepository *repository;

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID;

@end
