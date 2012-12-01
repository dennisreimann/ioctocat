#import "GHResource.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHGist

+ (id)gistWithId:(NSString *)theId {
	return [[[self.class alloc] initWithId:theId] autorelease];
}

- (id)initWithId:(NSString *)theId {
	self = [super init];
	if (self) {
		self.gistId = theId;
		self.resourcePath = [NSString stringWithFormat:kGistFormat, theId];
		self.comments = [GHGistComments commentsWithGist:self];
	}
	return self;
}

- (void)dealloc {
	[_gistId release], _gistId = nil;
	[_user release], _user = nil;
	[_files release], _files = nil;
	[_htmlURL release], _htmlURL = nil;
	[_createdAtDate release], _createdAtDate = nil;
	[_descriptionText release], _descriptionText = nil;
	[_comments release], _comments = nil;
	[super dealloc];
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
