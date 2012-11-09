#import "GHGistComments.h"
#import "GHGistComment.h"
#import "GHGist.h"
#import "NSURL+Extensions.h"


@implementation GHGistComments

@synthesize comments;
@synthesize gist;

+ (id)commentsWithGist:(GHGist *)theGist {
	return [[[self.class alloc] initWithGist:theGist] autorelease];
}

- (id)initWithGist:(GHGist *)theGist {
	[super init];
	self.gist = theGist;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[gist release], gist = nil;
	[super dealloc];
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// gist id which isn't always available in advance
	return [NSString stringWithFormat:kGistCommentsFormat, gist.gistId];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHGistComments gist:'%@'>", gist];
}

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHGistComment *comment = [[GHGistComment alloc] initWithGist:gist andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    self.comments = resources;
}

@end
