#import "GHRepoComment.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


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
	self.commitID = [dict ioc_stringForKey:@"commit_id"];
	self.position = [dict ioc_integerForKey:@"position"];
	self.line = [dict ioc_integerForKey:@"line"];
	self.path = [dict ioc_stringForKey:@"path"];
}

- (NSString *)resourcePath {
    if (self.isNew) {
        return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
    } else {
        return [NSString stringWithFormat:kRepoCommentFormat, self.repository.owner, self.repository.name, self.commentID];
    }
}

@end