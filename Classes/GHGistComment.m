#import "GHGistComment.h"
#import "GHGist.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"


@interface GHGistComment ()
@property(nonatomic,weak)GHGist *gist;
@end


@implementation GHGistComment

- (id)initWithGist:(GHGist *)gist {
	self = [super init];
	if (self) {
		self.gist = gist;
	}
	return self;
}

- (NSString *)savePath {
	return [NSString stringWithFormat:kGistCommentsFormat, self.gist.gistId];
}

@end