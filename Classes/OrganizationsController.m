#import "OrganizationsController.h"
#import "OrganizationController.h"
#import "OrganizationCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "AccountController.h"


@interface OrganizationsController ()
@property(nonatomic,retain)GHOrganizations *organizations;
@property(nonatomic,readonly)GHUser *currentUser;
@end


@implementation OrganizationsController

+ (id)controllerWithOrganizations:(GHOrganizations *)theOrganizations {
    return [[[OrganizationsController alloc] initWithOrganizations:theOrganizations] autorelease];
}

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations {
    self = [super initWithNibName:@"Organizations" bundle:nil];
	if (self) {
		self.organizations = theOrganizations;
		[self.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (AccountController *)accountController {
	return [[iOctocat sharedInstance] accountController];
}

- (UIViewController *)parentViewController {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController : nil;
}

- (UINavigationItem *)navItem {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController.navigationItem : self.navigationItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.navItem.title = @"Organizations";
	self.navItem.titleView = nil;
	self.navItem.rightBarButtonItem = nil;
    if (!self.organizations.isLoaded) [self.organizations loadData];
}

- (void)dealloc {
	[self.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [_noOrganizationsCell release], _noOrganizationsCell = nil;
    [_organizationCell release], _organizationCell = nil;
    [_loadingCell release], _loadingCell = nil;
    [super dealloc];
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
	OrganizationCell *cell = (OrganizationCell *)[tableView dequeueReusableCellWithIdentifier:kOrganizationCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OrganizationCell" owner:self options:nil];
		cell = self.organizationCell;
	}
    cell.organization = [self.organizations.organizations objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.organizations.isLoaded || self.organizations.organizations.count == 0) return;
    GHOrganization *org = [self.organizations.organizations objectAtIndex:indexPath.row];
    OrganizationController *viewController = [OrganizationController controllerWithOrganization:org];
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