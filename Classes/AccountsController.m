#import "AccountsController.h"
#import "AccountController.h"
#import "AccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "UserCell.h"
#import "NSString+Extensions.h"
#import "NSMutableArray+Extensions.h"


@interface AccountsController ()
- (void)convertOldAccount;
@end

@implementation AccountsController

@synthesize accounts;

+ (void)saveAccounts:(NSMutableArray *)theAccounts {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:theAccounts forKey:kAccountsDefaultsKey];
	[defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *currentAccounts = [defaults objectForKey:kAccountsDefaultsKey];
	self.accounts = currentAccounts != nil ?
		[NSMutableArray arrayWithArray:currentAccounts] :
		[NSMutableArray array];

	// Try to convert old account to new one
	[self convertOldAccount];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)convertOldAccount {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *login = [defaults objectForKey:kLoginDefaultsKey];
    NSString *password = [defaults objectForKey:kPasswordDefaultsKey];
    NSString *token = [defaults objectForKey:kTokenDefaultsKey];

	if (login != nil) {
		// Convert if old account can be found
		NSMutableDictionary *account = [NSMutableDictionary dictionary];
		[account setValue:login forKey:kLoginDefaultsKey];
		[account setValue:password forKey:kPasswordDefaultsKey];
		[account setValue:token forKey:kTokenDefaultsKey];

		// Add new account to list of accounts and save
		[accounts addObject:account];
		[self.class saveAccounts:accounts];

		// Remove old data
		[defaults removeObjectForKey:kLoginDefaultsKey];
		[defaults removeObjectForKey:kPasswordDefaultsKey];
		[defaults removeObjectForKey:kTokenDefaultsKey];
		[defaults synchronize];
	}
}

#pragma mark Actions

- (IBAction)addAccount:(id)sender {
	AccountFormController *viewController = [[AccountFormController alloc] initWithAccounts:accounts andIndex:NSNotFound];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
		cell = userCell;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	NSDictionary *accountDict = [accounts objectAtIndex:indexPath.row];
	NSString *login = [accountDict objectForKey:kLoginDefaultsKey];
    cell.user = [[iOctocat sharedInstance] userWithLogin:login];
	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *accountDict = [accounts objectAtIndex:indexPath.row];
	GHAccount *account = [GHAccount accountWithDict:accountDict];
	AccountController *viewController = [[AccountController alloc] initWithAccount:account];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[accounts removeObjectAtIndex:indexPath.row];
		[self.class saveAccounts:accounts];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
	[accounts moveObjectFromIndex:fromPath.row toIndex:toPath.row];
	[self.class saveAccounts:accounts];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	AccountFormController *viewController = [[AccountFormController alloc] initWithAccounts:accounts andIndex:indexPath.row];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
