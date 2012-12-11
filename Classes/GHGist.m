#import "GHResource.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
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
	return ([self.descriptionText isEmpty] && self.files.count > 0) ? [self.files allKeys][0] : self.descriptionText;
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:self.userLogin];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.gistId = dict[@"id"];
	self.files = dict[@"files"];
	self.htmlURL = [NSURL URLWithString:dict[@"html_url"]];
	self.userLogin = [dict valueForKeyPath:@"user.login" defaultsTo:nil];
	self.descriptionText = [dict valueForKeyPath:@"description" defaultsTo:@""];
	self.isPrivate = ![dict[@"public"] boolValue];
	self.forksCount = [dict[@"forks"] count];
	self.commentsCount = [dict[@"comments"] integerValue];
	self.createdAtDate = [iOctocat parseDate:dict[@"created_at"]];
}

@end
