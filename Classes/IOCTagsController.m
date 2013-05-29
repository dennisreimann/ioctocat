#import "IOCTagsController.h"
#import "GHTags.h"
#import "GHTag.h"
#import "IOCTreeController.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCTagsController ()
@property(nonatomic,strong)GHTags *tags;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCTagsController

- (id)initWithTags:(GHTags *)tags {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.tags = tags;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Tags";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.tags name:@"tags"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.tags.isUnloaded) {
		[self.tags loadWithSuccess:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		}];
	} else if (self.tags.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.tags.isLoading) return;
	[self.tags loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tags.isEmpty ? 1 : self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tags.isEmpty) return self.statusCell;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTagCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTagCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"tag.png"];
    }
    GHTag *tag = self.tags[indexPath.row];
    cell.textLabel.text = tag.tag;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tags.isEmpty) return;
	GHTag *tag = self.tags[indexPath.row];
	IOCTreeController *viewController = [[IOCTreeController alloc] initWithTree:tag.tree];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end