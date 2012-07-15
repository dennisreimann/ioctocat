#import "GHResource.h"
#import "GHReadme.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHReadme

@synthesize bodyHTML;
@synthesize repository;

+ (id)readmeWithRepository:(GHRepository *)theRepository {
	return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	[super init];
	self.repository = theRepository;
	self.resourcePath = [NSString stringWithFormat:kRepoReadmeFormat, repository.owner, repository.name];
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [repository release], repository = nil;
    [bodyHTML release], bodyHTML = nil;
	[super dealloc];
}

- (NSString *)resourceContentType {
	return kResourceContentTypeHTML;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self loadData];
		} else if (repository.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the repository"];
		}
	}
}

- (void)loadData {
	repository.isLoaded ? [super loadData] : [repository loadData];
}

- (void)loadingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ finished: %@\n\n====\n\n", [request url], [request responseString]);
	if (request.responseStatusCode == 404) {
		[self loadingFailed:request];
	} else {
		// Actually, this isn't a dictionary, because we requested
		// the html mime type which returns the HTML representation
		self.bodyHTML = [request responseString];
		// What would the superclass do?
		self.loadingStatus = GHResourceStatusProcessed;
		[self notifyDelegates:@selector(resource:finished:) withObject:self withObject:data];
	}
}

@end
