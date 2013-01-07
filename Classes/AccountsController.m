#import "AccountsController.h"
#import "MyEventsController.h"
#import "MenuController.h"
#import "AccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHApiClient.h"
#import "UserObjectCell.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "NSMutableArray+Extensions.h"
#import "iOctocat.h"
#import "AuthenticationController.h"


@interface AccountsController () <AuthenticationControllerDelegate>
@property(nonatomic,strong)NSMutableArray *accounts;
@property(nonatomic,strong)NSMutableDictionary *accountsByEndpoint;
@property(nonatomic,strong)NSMutableArray *endpoints;
@property(nonatomic,strong)AuthenticationController *authController;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;

- (void)editAccountAtIndex:(NSUInteger)idx;
- (void)openOrAuthenticateAccountAtIndex:(NSUInteger)idx;
- (IBAction)addAccount:(id)sender;
- (IBAction)toggleEditAccounts:(id)sender;
- (NSUInteger)accountIndexFromIndexPath:(NSIndexPath *)indexPath;
@end


@implementation AccountsController

+ (void)saveAccounts:(NSMutableArray *)accounts {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:accounts forKey:kAccountsDefaultsKey];
	[defaults synchronize];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *currentAccounts = [defaults objectForKey:kAccountsDefaultsKey];
	self.accounts = currentAccounts != nil ?
		[NSMutableArray arrayWithArray:currentAccounts] :
		[NSMutableArray array];

	self.accountsByEndpoint = [NSMutableDictionary dictionary];
	for (NSDictionary *dict in self.accounts) {
		NSString *endpoint = [dict safeStringForKey:kEndpointDefaultsKey];
		if ([endpoint isEmpty]) endpoint = @"https://github.com";
		NSMutableArray *endpointArray = [self.accountsByEndpoint objectForKey:endpoint];
		if (endpointArray == nil) {
			endpointArray = [NSMutableArray array];
			[self.accountsByEndpoint setObject:endpointArray forKey:endpoint];
		}
		[endpointArray addObject:dict];
	}
	self.endpoints = [NSMutableArray arrayWithArray:[self.accountsByEndpoint allKeys]];
	[self.endpoints sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([iOctocat sharedInstance].currentAccount) {
		[iOctocat sharedInstance].currentAccount = nil;
	}
	[self.tableView reloadData];
	[self updateEditButtonItem];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// Open account if there is only one
	if (self.accounts.count == 1) {
		[self openOrAuthenticateAccountAtIndex:0];
	}
}

#pragma mark Accounts

- (BOOL (^)(id obj, NSUInteger idx, BOOL *stop))blockTestingForAccount:(GHAccount*)account {
	return [^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj[kLoginDefaultsKey] isEqualToString:account.user.login] &&
			[obj[kEndpointDefaultsKey] isEqualToString:[account.apiClient.baseURL description]]) {
			*stop = YES;
			return YES;
		}
		return NO;
	} copy];
}

#pragma mark Actions

- (void)editAccountAtIndex:(NSUInteger)idx {
	AccountFormController *viewController = [[AccountFormController alloc] initWithAccounts:self.accounts andIndex:idx];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)toggleEditAccounts:(id)sender {
	self.tableView.editing = !self.tableView.isEditing;
}

- (IBAction)addAccount:(id)sender {
	[self editAccountAtIndex:NSNotFound];
}

- (void)openOrAuthenticateAccountAtIndex:(NSUInteger)idx {
	NSDictionary *dict = self.accounts[idx];
	GHAccount *account = [[GHAccount alloc] initWithDict:dict];
	[iOctocat sharedInstance].currentAccount = account;
	if (!account.user.isAuthenticated) {
		[self.authController authenticateAccount:account];
	}
}

- (NSUInteger)accountIndexFromIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *accountDict = [(NSArray *)[self.accountsByEndpoint
											 objectForKey:[self.endpoints objectAtIndex:indexPath.section]]
								 objectAtIndex:indexPath.row];
	if (accountDict) {
		return [self.accounts indexOfObject:accountDict];
	} else {
		return NSNotFound;
	}
}

- (void)updateEditButtonItem {
	self.navigationItem.rightBarButtonItem = (self.accounts.count > 0) ? self.editButtonItem : nil;
	if (self.accounts.count == 0) self.editing = NO;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.endpoints.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((NSArray *)[self.accountsByEndpoint objectForKey:[self.endpoints objectAtIndex:section]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserObjectCell" owner:self options:nil];
		cell = self.userObjectCell;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	NSDictionary *accountDict = (self.accounts)[idx];
	NSString *login = accountDict[kLoginDefaultsKey];
	cell.userObject = [[iOctocat sharedInstance] userWithLogin:login];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	[self openOrAuthenticateAccountAtIndex:idx];
}

#pragma mark Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.accounts removeObjectAtIndex:indexPath.row];
		[self.class saveAccounts:self.accounts];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self updateEditButtonItem];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
	[self.accounts moveObjectFromIndex:fromPath.row toIndex:toPath.row];
	[self.class saveAccounts:self.accounts];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	[self editAccountAtIndex:idx];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.endpoints objectAtIndex:section];
}

#pragma mark Authentication

- (AuthenticationController *)authController {
	if (!_authController) _authController = [[AuthenticationController alloc] initWithDelegate:self];
	return _authController;
}

- (void)authenticatedAccount:(GHAccount *)account {
	[iOctocat sharedInstance].currentAccount = account;
	if (!account.user.isAuthenticated) {
		[iOctocat reportError:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your credentials are correct"];
		NSUInteger idx = [self.accounts indexOfObjectPassingTest:[self blockTestingForAccount:account]];
		[self editAccountAtIndex:idx];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end