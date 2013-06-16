#import "GHRepoComment.h"
#import "GHRepository.h"
#import "NSDictionary+Extensions.h"


@implementation GHRepoComment

- (id)initWithRepo:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (void)setValues:(id)dict {
	[super setValues:dict];
	self.commitID = [dict safeStringForKey:@"commit_id"];
	self.position = [dict safeIntegerForKey:@"position"];
	self.line = [dict safeIntegerForKey:@"line"];
	self.path = [dict safeStringForKey:@"path"];
}

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
    } else {
        return [NSString stringWithFormat:kRepoCommentFormat, self.repository.owner, self.repository.name, self.commentID];
    }
}

@end