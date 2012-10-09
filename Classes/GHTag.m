#import "GHResource.h"
#import "GHTag.h"
#import "GHCommit.h"
#import "GHRepository.h"


@implementation GHTag

@synthesize sha;
@synthesize repository;
@synthesize commit;
@synthesize tag;
@synthesize message;
@synthesize taggerName;
@synthesize taggerEmail;
@synthesize taggerDate;

+ (id)tagWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
  return [[[self.class alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	self.resourcePath = [NSString stringWithFormat:kTagFormat, repository.owner, repository.name, sha];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	[tag release], tag = nil;
	[message release], message = nil;
	[taggerName release], taggerName = nil;
	[taggerEmail release], taggerEmail = nil;
	[taggerDate release], taggerDate = nil;
	[commit release], commit = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHTag sha:'%@', tag:'%@'>", sha, tag];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
	self.tag = [theDict valueForKey:@"tag"];
	self.message = [theDict valueForKey:@"message"];
	self.taggerName = [theDict valueForKeyPath:@"tagger.name"];
	self.taggerEmail = [theDict valueForKeyPath:@"tagger.email"];
	self.taggerDate = [iOctocat parseDate:[theDict valueForKey:@"tagger.date"]];
	self.commit = [GHCommit commitWithRepository:repository andCommitID:[theDict valueForKey:@"object.sha"]];
}

@end
