#import "CommitsController.h"
#import "CommitController.h"
#import "CommitCell.h"
#import "GHCommit.h"


@interface CommitsController ()
@property(nonatomic,strong)NSArray *commits;
@end


@implementation CommitsController

+ (id)controllerWithCommits:(NSArray *)theCommits {
	return [[[self.class alloc] initWithCommits:theCommits] autorelease];
}

- (id)initWithCommits:(NSArray *)theCommits {
	self = [super initWithNibName:@"Commits" bundle:nil];
	if (self) {
		self.title = @"Commits";
		self.commits = theCommits;
	}
	return self;
}

- (void)dealloc {
	[_commits release], _commits = nil;
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CommitCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommitCellIdentifier];
	if (cell == nil) cell = [CommitCell cell];
	cell.commit = [self.commits objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHCommit *commit = [self.commits objectAtIndex:indexPath.row];
	CommitController *viewController = [CommitController controllerWithCommit:commit];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end