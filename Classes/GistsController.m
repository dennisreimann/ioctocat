#import "GHGists.h"
#import "GHGist.h"
#import "GistsController.h"
#import "GistController.h"
#import "GistCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface GistsController ()
@property(nonatomic,strong)GHGists *gists;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingGistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noGistsCell;
@end


@implementation GistsController

- (id)initWithGists:(GHGists *)gists {
	self = [super initWithNibName:@"Gists" bundle:nil];
	if (self) {
		self.gists = gists;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Gists";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (!self.gists.isLoaded) {
		[self.gists loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the gists"];
		}];
	} else if (self.gists.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.gists.isLoaded && !self.gists.isEmpty;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.gists loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.resourceHasData ? self.gists.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gists.isLoading) return self.loadingGistsCell;
	if (self.gists.isEmpty) return self.noGistsCell;
	GistCell *cell = (GistCell *)[tableView dequeueReusableCellWithIdentifier:kGistCellIdentifier];
	if (cell == nil) cell = [GistCell cell];
	cell.gist = self.gists[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHGist *gist = self.gists[indexPath.row];
	GistController *gistController = [[GistController alloc] initWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

@end