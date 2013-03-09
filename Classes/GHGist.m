#import "GHResource.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHFiles.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHGist

- (id)initWithId:(NSString *)gistId {
	self = [super init];
	if (self) {
		self.gistId = gistId;
		self.resourcePath = [NSString stringWithFormat:kGistFormat, gistId];
		self.comments = [[GHGistComments alloc] initWithGist:self];
	}
	return self;
}

- (NSString *)title {
	if (!self.descriptionText.isEmpty) {
		return self.descriptionText;
	} else if (!self.files.isEmpty) {
		return self.files[0][@"filename"];
	} else {
		return [NSString stringWithFormat:@"Gist %@", self.gistId];
	}
}

#pragma mark Loading

- (void)setValues:(id)dict {
    if (![dict isKindOfClass:NSDictionary.class]) return;
	NSDictionary *userDict = [dict safeDictForKey:@"user"];
	NSString *userLogin = [userDict safeStringForKey:@"login"];
	self.user = [[iOctocat sharedInstance] userWithLogin:userLogin];
	self.gistId = [dict safeStringForKey:@"id"];
	self.files = [[GHFiles alloc] init];
	[self.files setValues:[[dict safeDictForKey:@"files"] allValues]];
	self.htmlURL = [dict safeURLForKey:@"html_url"];
	self.descriptionText = [dict safeStringForKey:@"description"];
	self.isPrivate = ![dict safeBoolForKey:@"public"];
	self.forksCount = [dict safeArrayForKey:@"forks"].count;
	self.commentsCount = [dict safeIntegerForKey:@"comments"];
	self.createdAtDate = [dict safeDateForKey:@"created_at"];
	self.updatedAtDate = [dict safeDateForKey:@"updated_at"];
    // unfortunately atm the gist api does not state the fork
	// status of a gist, but in the future this might work
    self.isFork = [dict safeBoolForKey:@"fork"];
}

@end
