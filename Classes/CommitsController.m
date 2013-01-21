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
		self.title = @"Commits";
		self.commits = commits;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.commits.isLoaded) {
		[self.commits loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the commits"];
		}];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.commits.isLoading || self.commits.isEmpty) ? 1 : self.commits.count;
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
	if (!self.commits.isLoaded || self.commits.isEmpty) return;
	GHCommit *commit = self.commits[indexPath.row];
	CommitController *viewController = [[CommitController alloc] initWithCommit:commit];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end