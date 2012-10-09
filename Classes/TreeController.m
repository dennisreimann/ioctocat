#import "TreeController.h"
#import "BlobsController.h"
#import "GHTree.h"
#import "GHBlob.h"


@interface TreeController ()
@property(nonatomic,retain)GHTree *tree;

- (void)displayTree;
@end


@implementation TreeController

@synthesize tree;

+ (id)controllerWithTree:(GHTree *)theTree {
	return [[[self.class alloc] initWithTree:theTree] autorelease];
}

- (id)initWithTree:(GHTree *)theTree {
    [super initWithNibName:@"Tree" bundle:nil];
	self.tree = theTree;
    [tree addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self displayTree];
	if (![tree isLoaded]) [tree loadData];
}

- (void)dealloc {
    [tree removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [loadingTreeCell release], loadingTreeCell = nil;
    [noEntriesCell release], noEntriesCell = nil;
    [super dealloc];
}

- (void)displayTree {
	self.title = tree.path ? tree.path : tree.sha;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHTree *theTree = (GHTree *)object;
		if (theTree.isLoaded) {
			[self displayTree];
		} else if (!theTree.isLoading && theTree.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the tree"];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return tree.isLoading ? 1 : 2;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tree.isLoading) return 1;
	return section == 0 ? tree.trees.count : tree.blobs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tree.isLoading) return loadingTreeCell;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	if (section == 0) {
		GHTree *obj = (GHTree *)[tree.trees objectAtIndex:row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"folder.png"];
	} else {
		GHBlob *obj = (GHBlob *)[tree.blobs objectAtIndex:row];
		cell.textLabel.text = obj.path;
		cell.imageView.image = [UIImage imageNamed:@"file.png"];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!tree.isLoaded) return;
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	if (section == 0) {
		GHTree *obj = (GHTree *)[tree.trees objectAtIndex:row];
		TreeController *treeController = [TreeController controllerWithTree:obj];
		[self.navigationController pushViewController:treeController animated:YES];
	} else {
		BlobsController *blobsController = [BlobsController controllerWithBlobs:tree.blobs currentIndex:row];
		[self.navigationController pushViewController:blobsController animated:YES];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
