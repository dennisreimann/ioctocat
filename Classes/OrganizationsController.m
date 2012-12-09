#import "OrganizationsController.h"
#import "OrganizationController.h"
#import "UserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@interface OrganizationsController ()
@property(nonatomic,strong)GHOrganizations *organizations;
@property(weak, nonatomic,readonly)GHUser *currentUser;
@end


@implementation OrganizationsController

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations {
    self = [super initWithNibName:@"Organizations" bundle:nil];
	if (self) {
		self.organizations = theOrganizations;
		[self.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Organizations";
	self.navigationItem.rightBarButtonItem = nil;
    if (!self.organizations.isLoaded) [self.organizations loadData];
}

- (void)dealloc {
	[self.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!self.organizations.isLoading && self.organizations.error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!self.organizations.isLoaded) || (self.organizations.organizations.count == 0) ? 1 : self.organizations.organizations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.organizations.isLoaded) return self.loadingCell;
	if (self.organizations.organizations.count == 0) return self.noOrganizationsCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserObjectCell" owner:self options:nil];
		cell = self.userObjectCell;
	}
    cell.userObject = [self.organizations.organizations objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.organizations.isLoaded || self.organizations.organizations.count == 0) return;
    GHOrganization *org = [self.organizations.organizations objectAtIndex:indexPath.row];
    OrganizationController *viewController = [[OrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end