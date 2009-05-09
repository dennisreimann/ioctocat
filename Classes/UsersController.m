#import "UsersController.h"
#import "UserController.h"


@implementation UsersController

@synthesize users;

- (id)initWithUsers:(GHUsers *)theUsers {
    [super initWithNibName:@"Users" bundle:nil];
    self.users = theUsers;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!users.isLoaded) [users loadUsers];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!users.isLoaded) || (users.users.count == 0) ? 1 : users.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!users.isLoaded) return loadingFollowingCell;
	if (users.users.count == 0) return noFollowingCell;
	UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
		cell = userCell;
	}
    cell.user = [users.users objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHUser *selectedUser = [users.users objectAtIndex:indexPath.row];
    UserController *userController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)selectedUser];
    [self.navigationController pushViewController:userController animated:YES];
    [userController release];
}

- (void)dealloc {
    [noFollowingCell release];
	[noFollowersCell release];
    [loadingFollowingCell release];
    [userCell release];
    [super dealloc];
}

@end

