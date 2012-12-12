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
	}
	return self;
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