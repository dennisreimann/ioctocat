#import "CommitsController.h"
#import "CommitController.h"
#import "CommitCell.h"
#import "GHCommits.h"
#import "GHCommit.h"
#import "iOctocat.h"


@interface CommitsController ()
@property(nonatomic,strong)GHCommits *commits;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommitsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommitsCell;
@end


@implementation CommitsController

- (id)initWithCommits:(GHCommits *)commits {
	self = [super initWithNibName:@"Commits" bundle:nil];
	if (self) {
		self.commits = commits;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Commits";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.commits.isLoaded) {
		[self.commits loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the commits"];
		}];
	} else if (self.commits.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.commits.isLoaded && !self.commits.isEmpty;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.resourceHasData ? self.commits.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.commits.isLoading) return self.loadingCommitsCell;
	if (self.commits.isEmpty) return self.noCommitsCell;
	CommitCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommitCellIdentifier];
	if (cell == nil) cell = [CommitCell cell];
	cell.commit = self.commits[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHCommit *commit = self.commits[indexPath.row];
	CommitController *viewController = [[CommitController alloc] initWithCommit:commit];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end