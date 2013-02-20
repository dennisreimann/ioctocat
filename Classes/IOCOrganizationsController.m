#import "IOCOrganizationsController.h"
#import "IOCOrganizationController.h"
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
		[self.organizations loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	} else if (self.organizations.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.organizations.isLoading) return;
	[self.organizations loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.organizations.isEmpty ? 1 : self.organizations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.organizations.isEmpty) return self.statusCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) cell = [UserObjectCell cell];
    cell.userObject = self.organizations[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.organizations.isEmpty) return;
    GHOrganization *org = self.organizations[indexPath.row];
    IOCOrganizationController *viewController = [[IOCOrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end