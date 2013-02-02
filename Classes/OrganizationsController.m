#import "OrganizationsController.h"
#import "OrganizationController.h"
#import "UserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


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
	}
    return self;
}

#pragma mark View Events

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.title ? self.title : @"Organizations";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// organizations
	if (!self.organizations.isLoaded) {
		[self.organizations loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}];
	} else if (self.organizations.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
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
    return !self.organizations.isLoaded || self.organizations.isEmpty ? 1 : self.organizations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.organizations.isLoaded) return self.loadingCell;
	if (self.organizations.count == 0) return self.noOrganizationsCell;
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		cell = [UserObjectCell cell];
	}
    cell.userObject = self.organizations[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.organizations.isLoaded || self.organizations.isEmpty) return;
    GHOrganization *org = self.organizations[indexPath.row];
    OrganizationController *viewController = [[OrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end