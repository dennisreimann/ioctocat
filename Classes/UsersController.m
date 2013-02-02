#import "UsersController.h"
#import "UserController.h"
#import "GHUsers.h"
#import "UserObjectCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface UsersController ()
@property(nonatomic,strong)GHUsers *users;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noUsersCell;
@end


@implementation UsersController

- (id)initWithUsers:(GHUsers *)users {
    self = [super initWithNibName:@"Users" bundle:nil];
	if (self) {
		self.users = users;
	}
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title.isEmpty ? @"Users" : self.title;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (!self.users.isLoaded) {
		[self.users loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the users"];
		}];
	} else if (self.users.isChanged) {
		[self.tableView reloadData];
	}
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
	if (!self.users.isLoaded) return self.loadingCell;
	if (self.users.isEmpty) return self.noUsersCell;
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

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.users.isLoaded && !self.users.isEmpty;
}

@end