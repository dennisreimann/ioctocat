#import <Foundation/Foundation.h>


@interface GHCommit : NSObject {
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
}

@property (nonatomic, retain) NSString *commitID;
@property (nonatomic, retain) NSString *tree;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSURL *commitURL;
@property (nonatomic, retain) NSString *authorName;
@property (nonatomic, retain) NSString *authorEmail;
@property (nonatomic, retain) NSString *committerName;
@property (nonatomic, retain) NSString *committerEmail;
@property (nonatomic, retain) NSDate *committedDate;
@property (nonatomic, retain) NSDate *authoredDate;

- (id)initWithCommitID:(NSString *)theCommitID;

@end
