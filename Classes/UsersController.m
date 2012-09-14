#import "UsersController.h"
#import "UserController.h"
#import "GHUsers.h"
#import "UserCell.h"


@interface UsersController ()
@property(nonatomic,retain)GHUsers *users;
@end


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
    if (!users.isLoaded) [users loadData];
}

- (void)dealloc {
	[users removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [noUsersCell release], noUsersCell = nil;
    [loadingCell release], loadingCell = nil;
    [userCell release], userCell = nil;
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!users.isLoading && users.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the users"];
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

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end

