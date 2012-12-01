#import "GHResource.h"
#import "GHTag.h"
#import "GHCommit.h"
#import "GHRepository.h"


@implementation GHTag

+ (id)tagWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	return [[[self.class alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.sha = theSha;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.sha];
	}
	return self;
}

- (void)dealloc {
	[_repository release], _repository = nil;
	[_sha release], _sha = nil;
	[_tag release], _tag = nil;
	[_message release], _message = nil;
	[_taggerName release], _taggerName = nil;
	[_taggerEmail release], _taggerEmail = nil;
	[_taggerDate release], _taggerDate = nil;
	[_commit release], _commit = nil;
	[super dealloc];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	self.tag = [theDict valueForKey:@"tag"];
	self.message = [theDict valueForKey:@"message"];
	self.taggerName = [theDict valueForKeyPath:@"tagger.name"];
	self.taggerEmail = [theDict valueForKeyPath:@"tagger.email"];
	self.taggerDate = [iOctocat parseDate:[theDict valueForKey:@"tagger.date"]];
	self.commit = [GHCommit commitWithRepository:self.repository andCommitID:[theDict valueForKey:@"object.sha"]];
}

@end