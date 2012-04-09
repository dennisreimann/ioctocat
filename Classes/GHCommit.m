#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@implementation GHCommit

@synthesize commitID;
@synthesize message;
@synthesize commitURL;
@synthesize authorName;
@synthesize authorEmail;
@synthesize committerName;
@synthesize committerEmail;
@synthesize committedDate;
@synthesize authoredDate;
@synthesize added;
@synthesize modified;
@synthesize removed;
@synthesize author;
@synthesize committer;
@synthesize repository;

+ (id)commitWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	return [[[[self class] alloc] initWithRepository:theRepository andCommitID:theCommitID] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	[super init];
	self.repository = theRepository;
	self.commitID = theCommitID;
	self.resourceURL = [NSURL URLWithFormat:kRepoCommitFormat, repository.owner, repository.name, commitID];
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commitID release], commitID = nil;
    [message release], message = nil;
    [commitURL release], commitURL = nil;
    [authorName release], authorName = nil;
    [authorEmail release], authorEmail = nil;
    [committerName release], committerName = nil;
    [committerEmail release], committerEmail = nil;
    [committedDate release], committedDate = nil;
    [authoredDate release], authoredDate = nil;
    [added release], added = nil;
    [modified release], modified = nil;
    [removed release], removed = nil;
    [author release], author = nil;
    [committer release], committer = nil;
    [repository release], repository = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self loadData];
		} else if (repository.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)loadData {
	repository.isLoaded ? [super loadData] : [repository loadData];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSString *authorLogin = [theDict valueForKeyPath:@"author.login"];
    NSString *committerLogin = [theDict valueForKeyPath:@"committer.login"];
    NSString *authorDateString = [theDict valueForKeyPath:@"commit.author.date"];
    NSString *committerDateString = [theDict valueForKeyPath:@"commit.committer.date"];
    
    self.author = [[iOctocat sharedInstance] userWithLogin:authorLogin];
    self.committer = [[iOctocat sharedInstance] userWithLogin:committerLogin];
    self.authoredDate = [iOctocat parseDate:authorDateString withFormat:kISO8601TimeFormat];
    self.committedDate = [iOctocat parseDate:committerDateString withFormat:kISO8601TimeFormat];
    self.message = [theDict valueForKeyPath:@"commit.message"];
    
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
