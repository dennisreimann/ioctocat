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
		self.title = @"Gists";
		self.gists = gists;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = [self.title isEmpty] ? @"Gists" : self.title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	if (!self.gists.isLoaded) {
		[self.gists loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the gists"];
		}];
	}
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
	return (self.gists.isLoading || self.gists.isEmpty) ? 1 : self.gists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gists.isLoading) return self.loadingGistsCell;
	if (self.gists.isEmpty) return self.noGistsCell;
	GistCell *cell = (GistCell *)[tableView dequeueReusableCellWithIdentifier:kGistCellIdentifier];
	if (cell == nil) {
		cell = [GistCell cell];
	}
	cell.gist = self.gists[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.gists.isLoaded || self.gists.isEmpty) return;
	GHGist *gist = self.gists[indexPath.row];
	GistController *gistController = [[GistController alloc] initWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

@end