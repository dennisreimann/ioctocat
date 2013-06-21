#import "IOCTreeController.h"
#import "IOCBlobsController.h"
#import "IOCRepositoryController.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHSubmodule.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "NSString_IOCExtensions.h"


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
    NSString *title = self.title;
    if (!title || [title ioc_isEmpty]) title = [self.tree.path ioc_isEmpty] ? self.tree.ref : [self.tree.path lastPathComponent];
    if (!title || [title ioc_isEmpty]) title = self.tree.shortenedSha;
    self.navigationItem.title = title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.tree name:NSLocalizedString(@"entries", nil)];
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
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:NSLocalizedString(@"Reloading", @"Progress HUD hint: Reloading")];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Reloading failed", @"Progress HUD hint: Reloading failed")];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tree.isEmpty ? 1 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.tree.isEmpty) return 1;
	if (section == 0) return self.tree.trees.count;
    if (section == 1) return self.tree.blobs.count;
    return self.tree.submodules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tree.isEmpty) return self.statusCell;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	if (section == 0) {
		GHTree *obj = (GHTree *)self.tree.trees[row];
		cell.textLabel.text = [obj.path lastPathComponent];
		cell.imageView.image = [UIImage imageNamed:@"folder.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (section == 1) {
		GHBlob *obj = (GHBlob *)self.tree.blobs[row];
		cell.textLabel.text = [obj.path lastPathComponent];
		cell.imageView.image = [UIImage imageNamed:@"file.png"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		GHSubmodule *obj = (GHSubmodule *)self.tree.submodules[row];
        NSString *name = [obj.path lastPathComponent];
		cell.textLabel.text = [NSString stringWithFormat:@"%@ @ %@", name, obj.shortenedSha];
		cell.imageView.image = [UIImage imageNamed:@"submodule.png"];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
	} else if (section == 1) {
		IOCBlobsController *blobsController = [[IOCBlobsController alloc] initWithBlobs:self.tree.blobs currentIndex:row];
		[self.navigationController pushViewController:blobsController animated:YES];
	} else {
        GHSubmodule *obj = (GHSubmodule *)self.tree.submodules[row];
		IOCTreeController *treeController = [[IOCTreeController alloc] initWithTree:obj.tree];
        NSString *name = [obj.path lastPathComponent];
        treeController.title = [NSString stringWithFormat:@"%@ @ %@", name, obj.shortenedSha];
		[self.navigationController pushViewController:treeController animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.tree.isEmpty) return;
	if (indexPath.section == 2) {
        GHSubmodule *submodule = [self.tree.submodules objectAtIndex:indexPath.row];
        IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:submodule.repository];
        [self.navigationController pushViewController:repoController animated:YES];
    }
}

@end