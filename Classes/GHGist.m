#import "GHResource.h"
#import "GHUser.h"
#import "GHGists.h"
#import "GHGist.h"
#import "GHFiles.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHGist

- (id)initWithId:(NSString *)gistId {
	self = [super init];
	if (self) {
		self.gistId = gistId;
		self.resourcePath = [NSString stringWithFormat:kGistFormat, gistId];
	}
	return self;
}

- (NSString *)title {
	if (![self.descriptionText ioc_isEmpty]) {
		return self.descriptionText;
	} else if (!self.files.isEmpty) {
		return self.files[0][@"filename"];
	} else {
		return [NSString stringWithFormat:@"Gist %@", self.gistId];
	}
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL ioc_URLWithFormat:@"https://gist.github.com/%@/%@", self.user.login, self.gistId];
    }
    return _htmlURL;
}

- (GHGists *)forks {
	if (!_forks) {
		NSString *path = [NSString stringWithFormat:kGistForksFormat, self.gistId];
		_forks = [[GHGists alloc] initWithPath:path];
	}
	return _forks;
}

- (GHGistComments *)comments {
    if (!_comments) {
        _comments = [[GHGistComments alloc] initWithGist:self];
    }
    return _comments;
}

#pragma mark Loading

- (void)setValues:(id)dict {
    if (![dict isKindOfClass:NSDictionary.class]) return;
	NSDictionary *userDict = [dict ioc_dictForKey:@"user"];
	NSString *userLogin = [userDict ioc_stringForKey:@"login"];
	self.user = [iOctocat.sharedInstance userWithLogin:userLogin];
	self.gistId = [dict ioc_stringForKey:@"id"];
	self.files = [[GHFiles alloc] init];
	[self.files setValues:[[dict ioc_dictForKey:@"files"] allValues]];
	self.htmlURL = [dict ioc_URLForKey:@"html_url"];
	self.descriptionText = [dict ioc_stringForKey:@"description"];
	self.isPrivate = ![dict ioc_boolForKey:@"public"];
	self.forksCount = [dict ioc_arrayForKey:@"forks"].count;
	self.commentsCount = [dict ioc_integerForKey:@"comments"];
	self.createdAt = [dict ioc_dateForKey:@"created_at"];
	self.updatedAt = [dict ioc_dateForKey:@"updated_at"];
    // unfortunately atm the gist api does not state the fork
	// status of a gist, but in the future this might work
    self.isFork = [dict ioc_boolForKey:@"fork"];
}

@end
