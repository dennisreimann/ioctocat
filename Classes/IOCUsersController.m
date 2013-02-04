#import "IOCUsersController.h"
#import "UserController.h"
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
    if (!self.users.isLoaded) {
		[self.users loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[self.tableView reloadData];
		}];
	} else if (self.users.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return !self.users.isEmpty;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.users loadWithParams:nil success:^(GHResource *instance, id data) {
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
    return self.resourceHasData ? self.users.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return self.statusCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) cell = [UserObjectCell cell];
    cell.userObject = self.users[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.resourceHasData) return;
    GHUser *user = self.users[indexPath.row];
    UserController *userController = [[UserController alloc] initWithUser:user];
    [self.navigationController pushViewController:userController animated:YES];
}

@end