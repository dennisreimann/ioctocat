#import "GHCommit.h"
#import "GHUser.h"
#import "GHFiles.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "iOctocat.h"
#import "GHFMarkdown.h"
#import "NSURL_IOCExtensions.h"
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHCommit ()
@property(nonatomic,strong)NSMutableAttributedString *attributedMessage;
@end


@implementation GHCommit

- (id)initWithRepository:(GHRepository *)repo andCommitID:(NSString *)commitID {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.commitID = commitID;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitFormat, self.repository.owner, self.repository.name, self.commitID];
	}
	return self;
}

- (void)setValues:(id)dict {
	// users
	NSDictionary *authorDict = [dict ioc_dictForKey:@"author"];
	NSDictionary *committerDict = [dict ioc_dictForKey:@"committer"];
	if (!authorDict) authorDict = [dict ioc_dictForKeyPath:@"commit.author"];
	if (!committerDict) committerDict = [dict ioc_dictForKeyPath:@"commit.committer"];
	NSString *authorLogin = [authorDict ioc_stringForKey:@"login"];
	NSString *committerLogin = [committerDict ioc_stringForKey:@"login"];
	if (![authorLogin ioc_isEmpty]) {
		self.author = [iOctocat.sharedInstance userWithLogin:authorLogin];
		if (self.author.isUnloaded) [self.author setValues:authorDict];
	}
	if (![committerLogin ioc_isEmpty]) {
		self.committer = [iOctocat.sharedInstance userWithLogin:committerLogin];
		if (self.committer.isUnloaded) [self.committer setValues:committerDict];
	}
	// info
	self.authorEmail = [authorDict ioc_stringForKey:@"email"];
	self.authorName = [authorDict ioc_stringForKey:@"name"];
	self.authoredDate = [dict ioc_dateForKeyPath:@"commit.author.date"];
	self.committedDate = [dict ioc_dateForKeyPath:@"commit.committer.date"];
	self.message = [dict ioc_stringForKeyPath:@"commit.message"];
	if ([self.message ioc_isEmpty]) self.message = [dict ioc_stringForKey:@"message"];
    self.htmlURL = [dict ioc_URLForKey:@"html_url"];
	// files
	self.added = [[GHFiles alloc] init];
	self.removed = [[GHFiles alloc] init];
	self.modified = [[GHFiles alloc] init];
	NSArray *files = [dict ioc_arrayForKey:@"files"];
	for (NSDictionary *file in files) {
		NSString *status = [file ioc_stringForKey:@"status"];
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

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@/%@/commit/%@", self.repository.owner, self.repository.name, self.commitID];
    }
    return _htmlURL;
}

- (GHRepoComments *)comments {
    if (!_comments) {
        _comments = [[GHRepoComments alloc] initWithRepo:self.repository andCommitID:self.commitID];
    }
    return _comments;
}

- (NSMutableAttributedString *)attributedMessage {
    if (!_attributedMessage) {
        NSString *text = self.message;
        text = [text emojizedString];
        _attributedMessage = [text ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.repository.repoId];
    }
    return _attributedMessage;
}

- (NSString *)shortenedSha {
    return [self.commitID substringToIndex:7];
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

- (BOOL)hasExtendedMessage {
	return [self.message rangeOfString:@"\n"].location != NSNotFound;
}

@end
