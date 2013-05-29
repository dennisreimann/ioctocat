#import "GHResource.h"
#import "GHReadme.h"
#import "GHRepository.h"
#import "iOctocat.h"


@interface GHReadme ()
@property(nonatomic,weak)GHRepository *repository;
@end


@implementation GHReadme

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoReadmeFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (NSString *)resourceContentType {
	return kResourceContentTypeHTML;
}

- (void)setValues:(id)response {
	// the response is not a dictionary, because we requested
	// the html mime type which returns the HTML representation
	self.bodyHTML = [[NSString alloc] initWithData:(NSData *)response encoding:NSUTF8StringEncoding];
}

@end