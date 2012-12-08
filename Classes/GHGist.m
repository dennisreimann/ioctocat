#import "GHResource.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHGist

- (id)initWithId:(NSString *)theId {
	self = [super init];
	if (self) {
		self.gistId = theId;
		self.resourcePath = [NSString stringWithFormat:kGistFormat, theId];
		self.comments = [[GHGistComments alloc] initWithGist:self];
	}
	return self;
}

- (NSString *)title {
	return ([self.descriptionText isEmpty] && self.files.count > 0) ? [[self.files allKeys] objectAtIndex:0] : self.descriptionText;
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	NSString *login = [theDict valueForKeyPath:@"user.login"];
	self.gistId = [theDict valueForKey:@"id"];
	self.user = [[iOctocat sharedInstance] userWithLogin:login];
	self.files = [theDict valueForKey:@"files"];
	self.htmlURL = [NSURL URLWithString:[theDict objectForKey:@"html_url"]];
	self.descriptionText = [theDict valueForKeyPath:@"description" defaultsTo:@""];
	self.isPrivate = ![[theDict objectForKey:@"public"] boolValue];
	self.commentsCount = [[theDict objectForKey:@"comments"] integerValue];
	self.forksCount = [[theDict objectForKey:@"forks"] count];
	self.createdAtDate = [iOctocat parseDate:[theDict objectForKey:@"created_at"]];
}

@end
