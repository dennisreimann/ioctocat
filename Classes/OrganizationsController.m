#import "OrganizationsController.h"
//#import "OrganizationController.h"


@implementation OrganizationsController

@synthesize organizations;

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations {
    [super initWithNibName:@"Organizations" bundle:nil];
    self.organizations = theOrganizations;
	[organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!organizations.isLoaded) [organizations loadData];
}

- (void)dealloc {
	[organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [noOrganizationsCell release];
    [loadingCell release];
    [organizationCell release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!organizations.isLoading && organizations.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the list of organizations" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (!organizations.isLoaded) return;
//    if (organizations.organizations.count == 0) return;
//    GHOrganization *org = [users.users objectAtIndex:indexPath.row];
//    OrganizationController *orgController = [(OrganizationController *)[OrganizationController alloc] initWithOrganization:(GHOrganization *)org];
//    [self.navigationController pushViewController:orgController animated:YES];
//    [orgController release];
//}

@end

