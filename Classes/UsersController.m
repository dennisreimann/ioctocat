#import "UsersController.h"
#import "UserController.h"


@implementation UsersController

@synthesize users;

- (id)initWithUsers:(GHUsers *)theUsers {
    [super initWithNibName:@"Users" bundle:nil];
    self.users = theUsers;
	[users addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!users.isLoaded) [users loadUsers];
}

- (void)dealloc {
	[users removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [noUsersCell release];
    [loadingCell release];
    [userCell release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!users.isLoading && users.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the list of users" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!users.isLoaded) || (users.users.count == 0) ? 1 : users.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!users.isLoaded) return loadingCell;
	if (users.users.count == 0) return noUsersCell;
	UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
		cell = userCell;
	}
    cell.user = [users.users objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!users.isLoaded) return;
    if (users.users.count == 0) return;
    GHUser *selectedUser = [users.users objectAtIndex:indexPath.row];
    UserController *userController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)selectedUser];
    [self.navigationController pushViewController:userController animated:YES];
    [userController release];
}

@end

