#import "GHIssue.h"


@interface GHIssue ()
- (void)setIssueState:(NSString *)theState;
- (void)toggledIssueStateTo:(id)theResult;
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
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleClose];
}

- (void)reopenIssue {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(setIssueState:) withObject:kIssueToggleReopen];
}

- (void)setIssueState:(NSString *)theToggle {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *toggleURLString = [NSString stringWithFormat:kIssueToggleFormat, theToggle, repository.owner, repository.name, num];
	NSURL *toggleURL = [NSURL URLWithString:toggleURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:toggleURL];    
	[request start];
	id result;
	if ([request error]) {
		result = [request error];
	} else {
		result = [theToggle isEqualToString:kIssueStateOpen] ? kIssueStateClosed : kIssueStateOpen;
	}
	[self performSelectorOnMainThread:@selector(toggledIssueStateTo:) withObject:result waitUntilDone:YES];
    [pool release];
}

- (void)toggledIssueStateTo:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.state = theResult;
		self.status = GHResourceStatusLoaded;
	}
}

@end
