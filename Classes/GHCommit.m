#import "GHCommit.h"
#import "GHUser.h"
#import "GHFiles.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHCommit

- (id)initWithRepository:(GHRepository *)repo andCommitID:(NSString *)commitID {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.commitID = commitID;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitFormat, self.repository.owner, self.repository.name, self.commitID];
		self.comments = [[GHRepoComments alloc] initWithRepo:self.repository andCommitID:self.commitID];
	}
	return self;
}

- (void)setValues:(id)dict {
	NSString *authorLogin = [dict safeStringForKeyPath:@"author.login"];
	NSString *committerLogin = [dict safeStringForKeyPath:@"committer.login"];
	self.author = [[iOctocat sharedInstance] userWithLogin:authorLogin];
	self.committer = [[iOctocat sharedInstance] userWithLogin:committerLogin];
	self.authoredDate = [dict safeDateForKeyPath:@"commit.author.date"];
	self.committedDate = [dict safeDateForKeyPath:@"commit.committer.date"];
	self.message = [dict safeStringForKeyPath:@"commit.message"];
	if (self.message.isEmpty) self.message = [dict safeStringForKey:@"message"];
	// Files
	self.added = [[GHFiles alloc] init];
	self.removed = [[GHFiles alloc] init];
	self.modified = [[GHFiles alloc] init];
	NSArray *files = [dict safeArrayForKey:@"files"];
	for (NSDictionary *file in files) {
		NSString *status = [file safeStringForKey:@"status"];
		if ([status isEqualToString:@"removed"]) {
			[self.removed addObject:file];
		} else if ([status isEqualToString:@"added"]) {
			[self.added addObject:file];
		} else {
			[self.modified addObject:file];
		}
	}
	[self.added markAsLoaded];
	[self.removed markAsLoaded];
	[self.modified markAsLoaded];
}

- (NSString *)shortenedSha {
	return [self.commitID substringToIndex:6];
}

- (NSString *)shortenedMessage {
	return [self.message componentsSeparatedByString:@"\n"][0];
}

- (NSString *)extendedMessage {
	int loc = [self.message rangeOfString:@"\n"].location;
	NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *ext = [self.message substringFromIndex:loc];
	return [ext stringByTrimmingCharactersInSet:trimSet];
}

@end
