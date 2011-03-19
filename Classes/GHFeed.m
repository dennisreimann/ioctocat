#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHFeedParserDelegate.h"
#import "GHUser.h"
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
    return [NSString stringWithFormat:@"<GHFeed resourceURL:'%@'>", resourceURL];
}

#pragma mark Feed parsing

- (void)parseData:(NSData *)theData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:theData];
	GHFeedParserDelegate *parserDelegate = [[GHFeedParserDelegate alloc] initWithTarget:self andSelector:@selector(parsingFinished:)];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotProcessed;
	} else {
		self.entries = theResult;
		self.lastReadingDate = [NSDate date];
		self.loadingStatus = GHResourceStatusProcessed;
	}
}

@end
