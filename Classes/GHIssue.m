#import "GHIssue.h"


@implementation GHIssue

@synthesize issueId, user, title, body, state, type, votes, created, updated, num, repository;    

- (id)initWithIssueID:(NSString *)theIssueID {
	[super init];
    self.issueId = theIssueID;
	return self;
}

- (void)dealloc {
    [issueId release];
    [user release];
    [title release];
    [type release];    
    [body release];
    [state release];
    [created release];
    [updated release];
	[super dealloc];
}

@end
