#import "GHOAuthClient.h"


@implementation GHOAuthClient

- (id)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	if (self) {
		NSSet *jsonTypes = [NSSet setWithObjects:
							kResourceContentTypeDefault,
							kResourceContentTypeText,
							kResourceContentTypeFull,
							kResourceContentTypeRaw, nil];
		[AFJSONRequestOperation addAcceptableContentTypes:jsonTypes];
		[self setDefaultHeader:@"Accept" value:kResourceContentTypeDefault];
		[self setParameterEncoding:AFJSONParameterEncoding];
		[self registerHTTPOperationClass:AFJSONRequestOperation.class];
	}
	return self;
}

@end