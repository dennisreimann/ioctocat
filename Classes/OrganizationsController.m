#import "OrganizationsController.h"
#import "OrganizationController.h"
#import "UserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"


@interface OrganizationsController ()
@property(nonatomic,strong)GHOrganizations *organizations;
@property(nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noOrganizationsCell;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;
@end


@implementation OrganizationsController

- (id)initWithOrganizations:(GHOrganizations *)organizations {
    self = [super initWithNibName:@"Organizations" bundle:nil];
	if (self) {
		self.organizations = organizations;
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
    return (!self.organizations.isLoaded) || (self.organizations.isEmpty) ? 1 : self.organizations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.organizations.isLoaded) return self.loadingCell;
	if (self.organizations.count == 0) return self.noOrganizationsCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		cell = [UserObjectCell cell];
	}
    cell.userObject = (self.organizations)[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.organizations.isLoaded || self.organizations.isEmpty) return;
    GHOrganization *org = (self.organizations)[indexPath.row];
    OrganizationController *viewController = [[OrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end