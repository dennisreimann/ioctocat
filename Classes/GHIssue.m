#import "GHIssue.h"


@interface GHIssue ()
- (void)setIssueState:(NSString *)theState;
@end


@implementation GHIssue

@synthesize user, title, body, state, type, votes, created, updated, num, repository;

- (void)dealloc {
    [user release];
    [title release];
    [type release];    
    [body release];
    [state release];
    [created release];
    [updated release];
	[super dealloc];
}

- (BOOL)isOpen {
	return [state isEqualToString:kIssueStateOpen];
}

- (BOOL)isClosed {
	return [state isEqualToString:kIssueStateClosed];
}

- (void)closeIssue {
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleClose];
}

- (void)reopenIssue {
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleReopen];
}

- (void)setIssueState:(NSString *)theState {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *toggleURLString = [NSString stringWithFormat:kIssueToggleFormat, theState, repository.owner, repository.name, num];
	NSURL *toggleURL = [NSURL URLWithString:toggleURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:toggleURL];    
	[request start];
    [pool release];
}

@end
