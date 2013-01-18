#import "TreeController.h"
#import "BlobsController.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "iOctocat.h"


@interface TreeController ()
@property(nonatomic,strong)GHTree *tree;

- (void)displayTree;
@end


@implementation TreeController

- (id)initWithTree:(GHTree *)tree {
	self = [super initWithNibName:@"Tree" bundle:nil];
	if (self) {
		self.tree = tree;
		[self.tree addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self displayTree];
	if (![self.tree isLoaded]) [self.tree loadData];
}

- (void)dealloc {
	[self.tree removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)displayTree {
	self.title = self.tree.path ? self.tree.path : self.tree.sha;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHTree *tree = (GHTree *)object;
		if (tree.isLoaded) {
			[self displayTree];
		} else if (!tree.isLoading && tree.error) {
			[iOctocat reportLoadingError:@"Could not load the tree"];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tree.isLoading ? 1 : 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.tree.isLoading) return 1;
	return section == 0 ? self.tree.trees.count : self.tree.blobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tree.isLoading) return self.loadingTreeCell;
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
		GHTree *obj = (GHTree *)(self.tree.trees)[row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"folder.png"];
	} else {
		GHBlob *obj = (GHBlob *)(self.tree.blobs)[row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"file.png"];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.tree.isLoaded) return;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	if (section == 0) {
		GHTree *obj = (GHTree *)(self.tree.trees)[row];
		TreeController *treeController = [[TreeController alloc] initWithTree:obj];
		[self.navigationController pushViewController:treeController animated:YES];
	} else {
		BlobsController *blobsController = [[BlobsController alloc] initWithBlobs:self.tree.blobs currentIndex:row];
		[self.navigationController pushViewController:blobsController animated:YES];
	}
}

@end