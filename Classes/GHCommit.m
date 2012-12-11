#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHCommit

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	self = [super init];
	if (self) {
		self.repository = theRepository;
		self.commitID = theCommitID;
		self.resourcePath = [NSString stringWithFormat:kRepoCommitFormat, self.repository.owner, self.repository.name, self.commitID];
		self.comments = [[GHRepoComments alloc] initWithRepo:self.repository andCommitID:self.commitID];
		[self.repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
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

	for (NSDictionary *file in theDict[@"files"]) {
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
