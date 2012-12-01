#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHCommit

+ (id)commitWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	return [self commitWithRepository:theRepo andCommitID:theSha];
}

+ (id)commitWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	return [[[self.class alloc] initWithRepository:theRepository andCommitID:theCommitID] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.commitID = theCommitID;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitFormat, self.repository.owner, self.repository.name, self.commitID];
		self.comments = [GHRepoComments commentsWithRepo:self.repository andCommitID:self.commitID];
		[self.repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[_commitID release], _commitID = nil;
	[_message release], _message = nil;
	[_commitURL release], _commitURL = nil;
	[_authorName release], _authorName = nil;
	[_authorEmail release], _authorEmail = nil;
	[_committerName release], _committerName = nil;
	[_committerEmail release], _committerEmail = nil;
	[_committedDate release], _committedDate = nil;
	[_authoredDate release], _authoredDate = nil;
	[_added release], _added = nil;
	[_modified release], _modified = nil;
	[_removed release], _removed = nil;
	[_author release], _author = nil;
	[_committer release], _committer = nil;
	[_repository release], _repository = nil;
	[_comments release], _comments = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.repository.isLoaded) {
			[self loadData];
		} else if (self.repository.error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
		}
	}
}

- (void)loadData {
	self.repository.isLoaded ? [super loadData] : [self.repository loadData];
}

- (void)setValues:(id)theDict {
	NSString *authorLogin = [theDict valueForKeyPath:@"author.login" defaultsTo:nil];
	NSString *committerLogin = [theDict valueForKeyPath:@"committer.login" defaultsTo:nil];
	NSString *authorDateString = [theDict valueForKeyPath:@"commit.author.date" defaultsTo:nil];
	NSString *committerDateString = [theDict valueForKeyPath:@"commit.committer.date" defaultsTo:nil];

	self.author = [[iOctocat sharedInstance] userWithLogin:authorLogin];
	self.committer = [[iOctocat sharedInstance] userWithLogin:committerLogin];
	self.authoredDate = [iOctocat parseDate:authorDateString];
	self.committedDate = [iOctocat parseDate:committerDateString];
	self.message = [theDict valueForKeyPath:@"commit.message" defaultsTo:nil];

	// Files
	self.added = [NSMutableArray array];
	self.modified = [NSMutableArray array];
	self.removed = [NSMutableArray array];

	for (NSDictionary *file in [theDict objectForKey:@"files"]) {
		NSString *status = [file valueForKey:@"status"];
		if ([status isEqualToString:@"removed"]) {
			[self.removed addObject:file];
		} else if ([status isEqualToString:@"added"]) {
			[self.added addObject:file];
		} else {
			[self.modified addObject:file];
		}
	}
}

@end
