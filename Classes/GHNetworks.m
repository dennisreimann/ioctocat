#import "GHNetworks.h"
#import "GHNetworksParserDelegate.h"
#import "GHUser.h"
#import "ASIFormDataRequest.h"

@interface GHNetworks ()
- (void)parseNetworks;
@end

@implementation GHNetworks

@synthesize entries, repository;

- (id)initWithRepository:(GHRepository *)theRepository {
    [super init];
    self.repository = theRepository;
	return self;    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHNetworks repository:'%@'>", repository];
}


- (NSURL *)networksURL {
	NSString *networksURLString = [NSString stringWithFormat:kNetworksUrl, repository.owner, repository.name];
	return [NSURL URLWithString:networksURLString];
}



#pragma mark -
#pragma mark Networks parsing

- (void)loadNetworks {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseNetworks) withObject:nil];
}

- (void)parseNetworks {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:self.networksURL];
	[request start];	
	GHNetworksParserDelegate *parserDelegate = [[GHNetworksParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedNetworks:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];	
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedNetworks:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.entries = theResult;
		self.status = GHResourceStatusLoaded;
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[repository release];
	[entries release];
    [super dealloc];
}

@end
