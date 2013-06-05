#import "IOCCollectionController.h"
#import "IOCResourceStatusCell.h"
#import "GHCollection.h"
#import "SVProgressHUD.h"
#import "iOctocat.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface IOCCollectionController ()
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,assign)BOOL canReload;
@end


@implementation IOCCollectionController

- (id)initWithCollection:(GHCollection *)collection {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.collection = collection;
	}
	return self;
}

- (NSString *)collectionName {
    return @"Items";
}

- (NSString *)collectionCellIdentifier {
    return @"ItemCell";
}

- (BOOL)canReload {
    return YES;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : self.collectionName;
	if (self.canReload) self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.collection name:self.collectionName.lowercaseString];
	[self setupInfiniteScrolling];
    [self displayCollection];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.collection.isUnloaded) {
		[self.collection loadWithSuccess:^(GHResource *instance, id data) {
            [self displayCollection];
		}];
	} else if (self.collection.isChanged) {
		[self displayCollection];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (void)displayCollection {
    [self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.collection.hasNextPage;
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.collection loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayCollection];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:error.localizedDescription];
        }];
	}];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.collection.isLoading) return;
	[self.collection loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self displayCollection] : [SVProgressHUD showWithStatus:NSLocalizedString(@"Reloading", nil)];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self displayCollection];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self displayCollection] : [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Reloading failed", nil)];
	}];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.collection.isEmpty ? 1 : self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return self.statusCell;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.collectionCellIdentifier];
	return cell;
}

@end