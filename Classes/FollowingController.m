#import "FollowingController.h"
#import "GHUser.h"


@implementation FollowingController

@synthesize user;

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"Following" bundle:nil];
	self.title = @"Following";
    self.user = theUser;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFollowing];
    if (!self.user.isFollowingLoaded) [self.user loadFollowing];
}

- (void)setupFollowing {
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!self.user.isFollowingLoaded) || (self.user.following.count == 0) ? 1 : self.user.following.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.user.isFollowingLoaded) return loadingFollowingCell;
	if (self.user.following.count == 0) return noFollowingCell;
	FollowCell *cell = (FollowCell *)[tableView dequeueReusableCellWithIdentifier:kFollowCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FollowCell" owner:self options:nil];
		cell = followingCell;
	}
    cell.user = [self.user.following objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	GHUser *user = [user.following objectAtIndex:indexPath.row];
//	IssueController *issueController = [[IssueController alloc] initWithIssue:issue];
//	[self.navigationController pushViewController:issueController animated:YES];
//	[issueController release];
}


- (void)dealloc {
    [noFollowingCell release];
    [loadingFollowingCell release];
    [followingCell release];
    [super dealloc];
}

@end

