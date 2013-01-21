#import "UsersController.h"
#import "UserController.h"
#import "GHUsers.h"
#import "UserObjectCell.h"
#import "iOctocat.h"


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
    if (!self.users.isLoaded) {
		[self.users loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the users"];
		}];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return !self.users.isLoaded || self.users.isEmpty ? 1 : self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.users.isLoaded) return self.loadingCell;
	if (self.users.isEmpty) return self.noUsersCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		cell = [UserObjectCell cell];
	}
    cell.userObject = self.users[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.users.isLoaded || self.users.isEmpty) return;
    GHUser *selectedUser = self.users[indexPath.row];
    UserController *userController = [[UserController alloc] initWithUser:(GHUser *)selectedUser];
    [self.navigationController pushViewController:userController animated:YES];
}

@end