#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHFeedParserDelegate.h"
#import "GHUser.h"
#import "GHAccount.h"
#import "GHApiClient.h"
#import "iOctocat.h"


@implementation GHFeed

@synthesize entries;
@synthesize lastReadingDate;

- (void)dealloc {
	[entries release];
	[lastReadingDate release];
    [super dealloc];
}

- (void)setEntries:(NSArray *)theEntries {
	[theEntries retain];
	[entries release];
	for (GHFeedEntry *entry in theEntries) {
		if ([entry.date compare:lastReadingDate] != NSOrderedDescending) entry.read = YES;
	}
	entries = theEntries;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeed resourcePath:'%@'>", resourcePath];
}

- (NSString *)resourceContentType {
	return kResourceContentTypeAtom;
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	// Send the request
	DJLog(@"Loading %@\n\n====\n\n", self.resourcePath);
	[self.currentAccount.feedClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	[self.currentAccount.feedClient getPath:self.resourcePath
								parameters:nil
								   success:^(AFHTTPRequestOperation *operation, id response) {
									   NSXMLParser *parser = (NSXMLParser *)response;
									   DJLog(@"Loading %@ finished: %@\n\n====\n\n", self.resourcePath, response);
									   GHFeedParserDelegate *parserDelegate = [[GHFeedParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
									   [parser setDelegate:parserDelegate];
									   [parser setShouldProcessNamespaces:NO];
									   [parser setShouldReportNamespacePrefixes:NO];
									   [parser setShouldResolveExternalEntities:NO];
									   [parser parse];
								   }
								   failure:^(AFHTTPRequestOperation *operation, NSError *theError) {
									   DJLog(@"Loading %@ failed: %@", self.resourcePath, theError);
									   
									   self.error = theError;
									   self.loadingStatus = GHResourceStatusNotProcessed;
									   [self notifyDelegates:@selector(resource:failed:) withObject:self withObject:error];
								   }];
}

#pragma mark Feed parsing

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotProcessed;
	} else {
		self.entries = theResult;
		self.lastReadingDate = [NSDate date];
		self.loadingStatus = GHResourceStatusProcessed;
		[self notifyDelegates:@selector(resource:finished:) withObject:self withObject:data];
	}
}

@end
