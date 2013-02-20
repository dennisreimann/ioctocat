#import "IOCUsersController.h"
#import "IOCUserController.h"
#import "GHUsers.h"
#import "UserObjectCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCUsersController ()
@property(nonatomic,strong)GHUsers *users;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCUsersController

- (id)initWithUsers:(GHUsers *)users {
    self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.users = users;
	}
    return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Users";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.users name:@"users"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (self.users.isUnloaded) {
		[self.users loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	} else if (self.users.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.users.isLoading) return;
	[self.users loadWithParams:nil start:^(GHResource *instance) {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.isEmpty ? 1 : self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.users.isEmpty) return self.statusCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) cell = [UserObjectCell cell];
    cell.userObject = self.users[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.users.isEmpty) return;
    GHUser *user = self.users[indexPath.row];
    IOCUserController *userController = [[IOCUserController alloc] initWithUser:user];
    [self.navigationController pushViewController:userController animated:YES];
}

@end