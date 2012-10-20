#import "OrganizationFeedsController.h"
#import "OrganizationController.h"
#import "OrganizationCell.h"
#import "FeedController.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"


@interface OrganizationFeedsController ()
@property(nonatomic,retain) GHOrganizations *organizations;
@end


@implementation OrganizationFeedsController

@synthesize organizations;

+ (id)controllerWithOrganizations:(GHOrganizations *)theOrganizations {
	return [[[self.class alloc] initWithOrganizations:theOrganizations] autorelease];
}

- (id)initWithOrganizations:(GHOrganizations *)theOrganizations {
    [super initWithNibName:@"Organizations" bundle:nil];
    self.organizations = theOrganizations;
	[organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Organizations";
    if (!organizations.isLoaded) [organizations loadData];
}

- (void)dealloc {
	[organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [noOrganizationsCell release], noOrganizationsCell = nil;
    [organizationCell release], organizationCell = nil;
    [loadingCell release], loadingCell = nil;
    [super dealloc];
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
    if (!organizations.isLoaded || organizations.organizations.count == 0) return;
    GHOrganization *org = [organizations.organizations objectAtIndex:indexPath.row];
    FeedController *viewController = [[FeedController alloc] initWithFeed:org.recentActivity andTitle:org.login];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end

