#import "IOCOrganizationsController.h"
#import "OrganizationController.h"
#import "UserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCOrganizationsController ()
@property(nonatomic,strong)GHOrganizations *organizations;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,readonly)GHUser *currentUser;
@end


@implementation IOCOrganizationsController

- (id)initWithOrganizations:(GHOrganizations *)organizations {
    self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.organizations = organizations;
	}
    return self;
}

#pragma mark View Events

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.title ? self.title : @"Organizations";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.organizations name:@"organizations"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// organizations
	if (self.organizations.isUnloaded) {
		[self.organizations loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[self.tableView reloadData];
		}];
	} else if (self.organizations.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)resourceHasData {
	return !self.organizations.isEmpty;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.organizations loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resourceHasData ? self.organizations.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return self.statusCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) cell = [UserObjectCell cell];
    cell.userObject = self.organizations[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.resourceHasData) return;
    GHOrganization *org = self.organizations[indexPath.row];
    OrganizationController *viewController = [[OrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end