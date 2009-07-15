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

- (void)dealloc {
	[repository release];
	[entries release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHNetworks repository:'%@'>", repository];
}

- (void)loadNetworks {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseNetworks) withObject:nil];
}

- (void)parseNetworks {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *networksURLString = [NSString stringWithFormat:kNetworksFormat, repository.owner, repository.name];
	NSURL *networksURL = [NSURL URLWithString:networksURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:networksURL];
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
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		self.entries = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
