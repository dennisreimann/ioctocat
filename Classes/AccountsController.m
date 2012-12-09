#import "AccountsController.h"
#import "MyEventsController.h"
#import "MenuController.h"
#import "AccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "UserCell.h"
#import "NSString+Extensions.h"
#import "NSMutableArray+Extensions.h"
#import "iOctocat.h"


@interface AccountsController ()
@property(nonatomic,strong)NSMutableArray *accounts;
@property(nonatomic,strong)AuthenticationController *authController;

- (void)editAccountAtIndex:(NSUInteger)theIndex;
- (void)openOrAuthenticateAccountAtIndex:(NSUInteger)theIndex;
@end


@implementation AccountsController

+ (void)saveAccounts:(NSMutableArray *)theAccounts {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:theAccounts forKey:kAccountsDefaultsKey];
	[defaults synchronize];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *currentAccounts = [defaults objectForKey:kAccountsDefaultsKey];
	self.accounts = currentAccounts != nil ?
		[NSMutableArray arrayWithArray:currentAccounts] :
		[NSMutableArray array];
	// Open account if there is only one
	if (self.accounts.count == 1) {
		[self openOrAuthenticateAccountAtIndex:0];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([iOctocat sharedInstance].currentAccount) {
		[iOctocat sharedInstance].currentAccount = nil;
	}
	[self.tableView reloadData];
}

#pragma mark Accounts

- (BOOL (^)(id obj, NSUInteger idx, BOOL *stop))blockTestingForLogin:(NSString*)theLogin {
	return [^(id obj, NSUInteger idx, BOOL *stop) {
		if ([[obj objectForKey:kLoginDefaultsKey] isEqualToString:theLogin]) {
			*stop = YES;
			return YES;
		}
		return NO;
	} copy];
}

#pragma mark Actions

- (void)editAccountAtIndex:(NSUInteger)theIndex {
	AccountFormController *viewController = [[AccountFormController alloc] initWithAccounts:self.accounts andIndex:theIndex];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)addAccount:(id)sender {
	[self editAccountAtIndex:NSNotFound];
}

- (void)openOrAuthenticateAccountAtIndex:(NSUInteger)theIndex {
	NSDictionary *accountDict = [self.accounts objectAtIndex:theIndex];
	GHAccount *account = [[GHAccount alloc] initWithDict:accountDict];
	[iOctocat sharedInstance].currentAccount = account;
	if (!account.user.isAuthenticated) {
		[self.authController authenticateAccount:account];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
		cell = self.userCell;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	NSDictionary *accountDict = [self.accounts objectAtIndex:indexPath.row];
	NSString *login = [accountDict objectForKey:kLoginDefaultsKey];
	cell.user = [[iOctocat sharedInstance] userWithLogin:login];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self openOrAuthenticateAccountAtIndex:indexPath.row];
}

#pragma mark Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.accounts removeObjectAtIndex:indexPath.row];
		[self.class saveAccounts:self.accounts];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	[self editAccountAtIndex:indexPath.row];
}

#pragma mark Authentication

- (AuthenticationController *)authController {
	if (!_authController) _authController = [[AuthenticationController alloc] initWithDelegate:self];
	return _authController;
}

- (void)authenticatedAccount:(GHAccount *)theAccount {
	[iOctocat sharedInstance].currentAccount = theAccount;
	if (!theAccount.user.isAuthenticated) {
		[iOctocat reportError:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your credentials are correct"];
		NSUInteger index = [self.accounts indexOfObjectPassingTest:[self blockTestingForLogin:theAccount.login]];
		[self editAccountAtIndex:index];
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