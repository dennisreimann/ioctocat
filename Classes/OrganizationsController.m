#import "OrganizationsController.h"
#import "OrganizationController.h"
#import "OrganizationCell.h"
#import "FeedController.h"
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

@synthesize organizations;

+ (id)controllerWithOrganizations:(GHOrganizations *)theOrganizations {
    return [[[OrganizationsController alloc] initWithOrganizations:theOrganizations] autorelease];
}

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations {
    [super initWithNibName:@"Organizations" bundle:nil];
    self.organizations = theOrganizations;
	[organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
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
	
    if (!organizations.isLoaded) [organizations loadData];
}

- (void)dealloc {
	[organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [noOrganizationsCell release], noOrganizationsCell = nil;
    [organizationCell release], organizationCell = nil;
    [loadingCell release], loadingCell = nil;
    [super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!organizations.isLoading && organizations.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the organizations"];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (!organizations.isLoaded) || (organizations.organizations.count == 0) ? 1 : organizations.organizations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!organizations.isLoaded) return loadingCell;
	if (organizations.organizations.count == 0) return noOrganizationsCell;
	OrganizationCell *cell = (OrganizationCell *)[tableView dequeueReusableCellWithIdentifier:kOrganizationCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OrganizationCell" owner:self options:nil];
		cell = organizationCell;
	}
    cell.organization = [organizations.organizations objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!organizations.isLoaded) return;
    if (organizations.organizations.count == 0) return;
    GHOrganization *org = [organizations.organizations objectAtIndex:indexPath.row];
    OrganizationController *viewController = [[OrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

