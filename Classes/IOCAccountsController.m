#import "IOCAccountsController.h"
#import "IOCDefaultsPersistence.h"
#import "IOCMyEventsController.h"
#import "IOCMenuController.h"
#import "IOCAccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOAuthClient.h"
#import "IOCUserObjectCell.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "NSMutableArray_IOCExtensions.h"
#import "iOctocat.h"
#import "IOCAuthenticationService.h"
#import "IOCTableViewSectionHeader.h"
#import "ECSlidingViewController.h"


@interface IOCAccountsController () <IOCAccountFormControllerDelegate>
@property(nonatomic,strong)NSMutableDictionary *accountsByEndpoint;
@end


@implementation IOCAccountsController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuMovedOff) name:ECSlidingViewTopDidAnchorRight object:nil];
    if (iOctocat.sharedInstance.currentAccount) {
		iOctocat.sharedInstance.currentAccount = nil;
	}
	[self handleAccountsChange];
	[self.tableView reloadData];
    // create account if there is none, open account if there is only one
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        if (self.accounts.count == 0) {
            [self addAccount:nil];
        } else if (self.accounts.count == 1) {
            [self authenticateAccountAtIndex:0];
        }
	});
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationItem.rightBarButtonItem = (self.accounts.count > 0) ? self.editButtonItem : nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationItem.rightBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSlidingViewTopDidAnchorRight object:nil];
}

- (void)menuMovedOff {
    self.slidingViewController.topViewController = nil;
}

- (NSMutableArray *)accounts {
    return iOctocat.sharedInstance.accounts;
}

#pragma mark IOCAccountFormControllerDelegate

- (void)updateAccount:(GHAccount *)account atIndex:(NSUInteger)idx callback:(void (^)(NSUInteger idx))callback {
	// add new account to list of accounts
	if (idx == NSNotFound) {
		[self.accounts addObject:account];
        [self handleAccountsChange];
		if (callback) {
			idx = [self.accounts indexOfObject:account];
			callback(idx);
		}
	} else {
		self.accounts[idx] = account;
        [self handleAccountsChange];
        if (callback) callback(idx);
	}
}

- (void)removeAccountAtIndex:(NSUInteger)idx callback:(void (^)(NSUInteger idx))callback {
    if (idx == NSNotFound) return;
    GHAccount *account = [self.accounts objectAtIndex:idx];
    [IOCDefaultsPersistence removeAccount:account];
    [self.accounts removeObjectAtIndex:idx];
	[self handleAccountsChange];
    if (callback) callback(idx);
}

- (NSUInteger)indexOfAccountWithLogin:(NSString *)login endpoint:(NSString *)endpoint {
    // compare the hosts, because there might be slight differences in the full URL notation
    NSString *endpointHost = [[NSURL ioc_smartURLFromString:endpoint] host];
    return [self.accounts indexOfObjectPassingTest:^(GHAccount *account, NSUInteger idx, BOOL *stop) {
        NSString *accountHost = [[NSURL ioc_smartURLFromString:account.endpoint] host];
        if ([login isEqualToString:account.login] && [endpointHost isEqualToString:accountHost]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
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
        // FIXME This is only here to stay compatible with old versions upgrading
        // to >= v1.8, because empty endpoints got deprecated with that update.
        // Should get removed once v1.9 gets released.
		if (!endpoint || [endpoint ioc_isEmpty]) endpoint = kGitHubComURL;
        // use hosts as key, because there might be slight differences in the full URL notation
        NSString *host = [[NSURL URLWithString:endpoint] host];
		if (!self.accountsByEndpoint[host]) {
			self.accountsByEndpoint[host] = [NSMutableArray array];
		}
		[self.accountsByEndpoint[host] addObject:account];
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
	GHAccount *account = (idx == NSNotFound) ? [[GHAccount alloc] initWithDict:@{}] : self.accounts[idx];
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

- (void)authenticateAccountAtIndex:(NSUInteger)idx {
	GHAccount *account = self.accounts[idx];
	iOctocat.sharedInstance.currentAccount = account;
	[IOCAuthenticationService authenticateAccount:account success:^(GHAccount *account) {
        iOctocat.sharedInstance.currentAccount = account;
		IOCMenuController *menuController = [[IOCMenuController alloc] initWithUser:account.user];
        [self.navigationController pushViewController:menuController animated:YES];
    } failure:^(GHAccount *account) {
        [iOctocat reportError:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your credentials are correct"];
		NSUInteger idx = [self.accounts indexOfObject:account];
		[self editAccountAtIndex:idx];
    }];
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
	return self.accountsByEndpoint.allKeys[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IOCUserObjectCell *cell = (IOCUserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (!cell) {
		cell = [IOCUserObjectCell cellWithReuseIdentifier:kUserObjectCellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	GHAccount *account = self.accounts[idx];
	cell.userObject = account.user;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger idx = [self accountIndexFromIndexPath:indexPath];
	[self authenticateAccountAtIndex:idx];
}

#pragma mark Editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
    if (toPath.row != fromPath.row) {
        [self.accounts ioc_moveObjectFromIndex:fromPath.row toIndex:toPath.row];
        [self handleAccountsChange];
    }
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

@end