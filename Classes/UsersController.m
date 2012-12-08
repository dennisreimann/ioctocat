#import "UsersController.h"
#import "UserController.h"
#import "GHUsers.h"
#import "UserCell.h"
#import "iOctocat.h"


@interface UsersController ()
@property(nonatomic,strong)GHUsers *users;
@end


@implementation UsersController

- (id)initWithUsers:(GHUsers *)theUsers {
    self = [super initWithNibName:@"Users" bundle:nil];
	if (self) {
		self.users = theUsers;
		[self.users addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.users.isLoaded) [self.users loadData];
}

- (void)dealloc {
	[self.users removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!self.users.isLoading && self.users.error) {
			[iOctocat reportLoadingError:@"Could not load the users"];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!self.users.isLoaded) || (self.users.users.count == 0) ? 1 : self.users.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.users.isLoaded) return self.loadingCell;
	if (self.users.users.count == 0) return self.noUsersCell;
	UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
		cell = self.userCell;
	}
    cell.user = [self.users.users objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.users.isLoaded || self.users.users.count == 0) return;
    GHUser *selectedUser = [self.users.users objectAtIndex:indexPath.row];
    UserController *userController = [[UserController alloc] initWithUser:(GHUser *)selectedUser];
    [self.navigationController pushViewController:userController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end