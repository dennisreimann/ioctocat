#import "GHGistComment.h"
#import "GHGist.h"
#import "iOctocat.h"
#import "NSDictionary_IOCExtensions.h"


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

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kGistCommentsFormat, self.gist.gistId];
    } else {
        return [NSString stringWithFormat:kGistCommentFormat, self.gist.gistId, self.commentID];
    }
}

@end