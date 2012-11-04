#import "GHFeedClient.h"

@implementation GHFeedClient

+ (id)clientWithBaseURL:(NSURL *)url {
    return [[[self.class alloc] initWithBaseURL:url] autorelease];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
	
	// Setup GitHub content types
	NSSet *xmlTypes = [NSSet setWithObject:kResourceContentTypeAtom];
	[AFXMLRequestOperation addAcceptableContentTypes:xmlTypes];
	
	[self setDefaultHeader:@"Accept" value:kResourceContentTypeAtom];
	[self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    return self;
}

@end
