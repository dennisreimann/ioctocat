#import "GHGists.h"
#import "GHGist.h"
#import "IOCGistsController.h"
#import "IOCGistController.h"
#import "GistCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCGistsController ()
@property(nonatomic,strong)GHGists *gists;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCGistsController

- (id)initWithGists:(GHGists *)gists {
	self = [super initWithStyle:UITableViewStylePlain];
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
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gists name:@"gists"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.gists.isUnloaded) {
		[self.gists loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	} else if (self.gists.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.gists.isLoading) return;
	[self.gists loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.gists.isEmpty ? 1 : self.gists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gists.isEmpty) return self.statusCell;
	GistCell *cell = (GistCell *)[tableView dequeueReusableCellWithIdentifier:kGistCellIdentifier];
	if (cell == nil) cell = [GistCell cell];
	cell.gist = self.gists[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gists.isEmpty) return;
	GHGist *gist = self.gists[indexPath.row];
	IOCGistController *gistController = [[IOCGistController alloc] initWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

@end