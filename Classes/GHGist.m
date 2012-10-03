#import "GHResource.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHGistComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHGist

@synthesize gistId;
@synthesize user;
@synthesize files;
@synthesize htmlURL;
@synthesize createdAtDate;
@synthesize descriptionText;
@synthesize commentsCount;
@synthesize comments;
@synthesize forksCount;
@synthesize isPrivate;

+ (id)gistWithId:(NSString *)theId {
	return [[[self.class alloc] initWithId:theId] autorelease];
}

- (id)initWithId:(NSString *)theId {
	[super init];
	self.gistId = theId;
	self.resourcePath = [NSString stringWithFormat:kGistFormat, theId];
	self.comments = [GHGistComments commentsWithGist:self];
	return self;
}

- (void)dealloc {
	[gistId release], gistId = nil;
	[user release], user = nil;
	[files release], files = nil;
	[htmlURL release], htmlURL = nil;
	[createdAtDate release], createdAtDate = nil;
	[descriptionText release], descriptionText = nil;
	[comments release], comments = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHGist id:'%@' user:'%@' isPrivate:'%@'>", gistId, user.login, isPrivate ? @"YES" : @"NO"];
}

- (NSString *)title {
	return ([descriptionText isEmpty] && files.count > 0) ? [[files allKeys] objectAtIndex:0] : descriptionText;
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
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
