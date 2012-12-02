#import "GHGistComments.h"
#import "GHGistComment.h"
#import "GHGist.h"
#import "NSURL+Extensions.h"


@implementation GHGistComments

+ (id)commentsWithGist:(GHGist *)theGist {
	return [[self.class alloc] initWithGist:theGist];
}

- (id)initWithGist:(GHGist *)theGist {
	self = [super init];
	if (self) {
		self.gist = theGist;
		self.comments = [NSMutableArray array];
	}
	return self;
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// gist id which isn't always available in advance
	return [NSString stringWithFormat:kGistCommentsFormat, self.gist.gistId];
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHGistComment *comment = [GHGistComment commentWithGist:self.gist andDictionary:dict];
		[resources addObject:comment];
	}
	self.comments = resources;
}

@end