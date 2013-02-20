#import "IOCTreeController.h"
#import "BlobsController.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCTreeController ()
@property(nonatomic,strong)GHTree *tree;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCTreeController

- (id)initWithTree:(GHTree *)tree {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.tree = tree;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.tree.path ? self.tree.path : self.tree.sha;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.tree name:@"entries"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// tree
	if (self.tree.isUnloaded) {
		[self.tree loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	} else if (self.tree.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.tree.isLoading) return;
	[self.tree loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tree.isEmpty ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.tree.isEmpty) return 1;
	return section == 0 ? self.tree.trees.count : self.tree.blobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tree.isEmpty) return self.statusCell;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if (section == 0) {
		GHTree *obj = (GHTree *)self.tree.trees[row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"folder.png"];
	} else {
		GHBlob *obj = (GHBlob *)self.tree.blobs[row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"file.png"];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tree.isEmpty) return;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	if (section == 0) {
		GHTree *obj = (GHTree *)self.tree.trees[row];
		IOCTreeController *treeController = [[IOCTreeController alloc] initWithTree:obj];
		[self.navigationController pushViewController:treeController animated:YES];
	} else {
		BlobsController *blobsController = [[BlobsController alloc] initWithBlobs:self.tree.blobs currentIndex:row];
		[self.navigationController pushViewController:blobsController animated:YES];
	}
}

@end