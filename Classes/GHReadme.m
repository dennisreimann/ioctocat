#import "GHResource.h"
#import "GHReadme.h"
#import "GHRepository.h"
#import "iOctocat.h"


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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self loadData];
		} else if (repository.error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
		}
	}
}

- (void)loadData {
	repository.isLoaded ? [super loadData] : [repository loadData];
}

- (NSString *)resourceContentType {
	return kResourceContentTypeHTML;
}

- (void)setValues:(id)theResponse {
	// the response is not a dictionary, because we requested
	// the html mime type which returns the HTML representation
	self.bodyHTML = [[[NSString alloc] initWithData:(NSData *)theResponse encoding:NSUTF8StringEncoding] autorelease];
}

@end