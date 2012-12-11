#import "GHResource.h"
#import "GHReadme.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHReadme

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.resourcePath = [NSString stringWithFormat:kRepoReadmeFormat, self.repository.owner, self.repository.name];
		[self.repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.repository.isLoaded) {
			[self loadData];
		} else if (self.repository.error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
		}
	}
}

- (void)loadData {
	self.repository.isLoaded ? [super loadData] : [self.repository loadData];
}

- (NSString *)resourceContentType {
	return kResourceContentTypeHTML;
}

- (void)setValues:(id)theResponse {
	// the response is not a dictionary, because we requested
	// the html mime type which returns the HTML representation
	self.bodyHTML = [[NSString alloc] initWithData:(NSData *)theResponse encoding:NSUTF8StringEncoding];
}

@end