#import "IOCAccountsController.h"
#import "MyEventsController.h"
#import "MenuController.h"
#import "IOCAccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHApiClient.h"
#import "UserObjectCell.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "NSMutableArray+Extensions.h"
#import "iOctocat.h"
#import "IOCAuthenticationController.h"
#import "IOCTableViewSectionHeader.h"


@interface IOCAccountsController () <IOCAuthenticationControllerDelegate, IOCAccountFormControllerDelegate>
@property(nonatomic,strong)NSMutableArray *accounts;
@property(nonatomic,strong)NSMutableDictionary *accountsByEndpoint;
@property(nonatomic,strong)IOCAuthenticationController *authController;
@end


@implementation IOCAccountsController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id currentData = [defaults objectForKey:kAccountsDefaultsKey];
	if ([currentData isKindOfClass:NSData.class]) {
		NSArray *currentAccounts = [NSKeyedUnarchiver unarchiveObjectWithData:currentData];
		self.accounts = [NSMutableArray arrayWithArray:currentAccounts];
	} else {
		self.accounts = currentData ? [NSMutableArray arrayWithArray:currentData] : [NSMutableArray array];
		// convert old accounts
		for (NSInteger i = 0; i < self.accounts.count; i++) {
			id currentAccount = self.accounts[i];
			if ([currentAccount isKindOfClass:NSDictionary.class]) {
				GHAccount *account = [[GHAccount alloc] initWithDict:currentAccount];
				[self.accounts replaceObjectAtIndex:i withObject:account];
			}
		}
	}
	// open account if there is only one
	if (self.accounts.count == 1) {
		[self openOrAuthenticateAccountAtIndex:0];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([iOctocat sharedInstance].currentAccount) {
		[iOctocat sharedInstance].currentAccount = nil;
	}
	[self handleAccountsChange];
	[self.tableView reloadData];
}

- (void)updateAccount:(GHAccount *)account atIndex:(NSUInteger)idx {
	// add new account to list of accounts
	if (idx == NSNotFound) {
		[self.accounts addObject:account];
	} else {
		self.accounts[idx] = account;
	}
	[self handleAccountsChange];
}

#pragma mark Helpers

- (void)handleAccountsChange {
	// persist the accounts
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *encodedAccounts = [NSKeyedArchiver archivedDataWithRootObject:self.accounts];
	[defaults setValue:encodedAccounts forKey:kAccountsDefaultsKey];
	[defaults synchronize];
	// update cache for presenting the accounts
	self.accountsByEndpoint = [NSMutableDictionary dictionary];
	for (GHAccount *account in self.accounts) {
		NSString *endpoint = account.endpoint;
		if (!endpoint || endpoint.isEmpty) endpoint = @"https://github.com";
		if (!self.accountsByEndpoint[endpoint]) {
			self.accountsByEndpoint[endpoint] = [NSMutableArray array];
		}
		[self.accountsByEndpoint[endpoint] addObject:account];
	}
	// update UI
	self.navigationItem.rightBarButtonItem = (self.accounts.count > 0) ? self.editButtonItem : nil;
	if (self.accounts.count == 0) self.editing = NO;
}

- (NSUInteger)accountIndexFromIndexPath:(NSIndexPath *)indexPath {
	GHAccount *account = [[self accountsInSection:indexPath.section] objectAtIndex:indexPath.row];
	if (account) {
		return [self.accounts indexOfObject:account];
	} else {
		return NSNotFound;
	}
}

- (NSArray *)accountsInSection:(NSInteger)section {
	NSArray *keys = self.accountsByEndpoint.allKeys;
	NSString *key = keys[section];
	return self.accountsByEndpoint[key];
}

#pragma mark Actions

- (void)editAccountAtIndex:(NSUInteger)idx {
	GHAccount *account = (idx == NSNotFound) ? [[GHAccount alloc] init] : self.accounts[idx];
	IOCAccountFormController *viewController = [[IOCAccountFormController alloc] initWithAccount:account andIndex:idx];
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)toggleEditAccounts:(id)sender {
	self.tableView.editing = !self.tableView.isEditing;
}

- (IBAction)addAccount:(id)sender {
	[self editAccountAtIndex:NSNotFound];
}

- (void)openOrAuthenticateAccountAtIndex:(NSUInteger)idx {
	GHAccount *account = self.accounts[idx];
	[iOctocat sharedInstance].currentAccount = account;
	if (!account.user.isAuthenticated) {
		[self.authController authenticateAccount:account];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.accountsByEndpoint.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self accountsInSection:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 24 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    return (title == nil) ? nil : [IOCTableViewSectionHeader headerForTableView:tableView title:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSArray *keys = self.accountsByEndpoint.allKeys;
	NSString *endpoint = keys[section];
	NSURL *url = [NSURL URLWithString:endpoint];
	return url.host;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (cell == nil) {
		cell = [UserObjectCell cell];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	GHAccount *account = self.accounts[idx];
	cell.userObject = [[iOctocat sharedInstance] userWithLogin:account.login];
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
		NSInteger section = indexPath.section;
		NSArray *keys = self.accountsByEndpoint.allKeys;
		NSString *endpoint = keys[section];
		NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
		[self.accounts removeObjectAtIndex:idx];
		[self handleAccountsChange];
		// update table:
		// remove the section if it was the last account in this section
		if (!self.accountsByEndpoint[endpoint]) {
			NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:section];
			[self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
		}
		// remove the cell
		else {
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
    if (toPath.row != fromPath.row) {
        [self.accounts moveObjectFromIndex:fromPath.row toIndex:toPath.row];
        [self handleAccountsChange];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	[self editAccountAtIndex:idx];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section == sourceIndexPath.section) {
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

#pragma mark Authentication

- (IOCAuthenticationController *)authController {
	if (!_authController) _authController = [[IOCAuthenticationController alloc] initWithDelegate:self];
	return _authController;
}

- (void)authenticatedAccount:(GHAccount *)account {
	[iOctocat sharedInstance].currentAccount = account;
	if (!account.user.isAuthenticated) {
		[iOctocat reportError:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your credentials are correct"];
		NSUInteger idx = [self.accounts indexOfObjectPassingTest:^(GHAccount *otherAccount, NSUInteger idx, BOOL *stop) {
			if ([otherAccount.login isEqualToString:account.login] && [otherAccount.endpoint isEqualToString:account.endpoint]) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		[self editAccountAtIndex:idx];
	}
}

@end