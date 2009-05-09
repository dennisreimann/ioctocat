#import "MyRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHReposParserDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RepositoryCell.h"


@implementation MyRepositoriesController

@synthesize privateRepositories, publicRepositories;

- (void)viewDidLoad {
    [super viewDidLoad];
	isLoaded = NO;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)parseXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Load settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [[defaults stringForKey:kUsernameDefaultsKey] retain];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *url = [NSString stringWithFormat:kUserReposFormat, username];
	NSURL *reposURL = [NSURL URLWithString:url];	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:reposURL] autorelease];
	[request setPostValue:username forKey:@"login"];
	[request setPostValue:token forKey:@"token"];	
	[request start];
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedRepositories:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[request responseData]];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];	
	[username release];
}

- (void)loadedRepositories:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		self.privateRepositories = [NSMutableArray array];
		self.publicRepositories = [NSMutableArray array];
		for (GHRepository *repo in theResult) {
			(repo.isPrivate) ? [privateRepositories addObject:repo] : [publicRepositories addObject:repo];
		}
	}
	isLoaded = YES;
    
    [self.publicRepositories sortUsingSelector:@selector(compareByName:)];
    [self.privateRepositories sortUsingSelector:@selector(compareByName:)];
    
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!isLoaded) return 1;
	NSArray *repos = (section == 0) ? privateRepositories : publicRepositories;
	return (repos.count == 0) ? 1 : repos.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!isLoaded) return @"";
	return (section == 0) ? @"Private" : @"Public";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!isLoaded) return loadingReposCell;
	NSArray *repos = (indexPath.section == 0) ? privateRepositories : publicRepositories;
	if (indexPath.section == 0 && repos.count == 0) return noPrivateReposCell;
	if (indexPath.section == 1 && repos.count == 0) return noPublicReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [[[RepositoryCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
	cell.repository = [repos objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *repos = (indexPath.section == 0) ? privateRepositories : publicRepositories;
	if (repos.count == 0) return;
	GHRepository *repo = [repos objectAtIndex:indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
	[repoController release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[noPublicReposCell release];
	[noPrivateReposCell release];
	[publicRepositories release];
	[privateRepositories release];
    [super dealloc];
}

@end

