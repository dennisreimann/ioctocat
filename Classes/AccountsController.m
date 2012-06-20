#import "AccountsController.h"
#import "AccountController.h"
#import "AccountFormController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "UserCell.h"
#import "NSMutableArray+Extensions.h"


@implementation AccountsController

@synthesize accounts;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *currentAccounts = [defaults objectForKey:kAccountsDefaultsKey];
	self.accounts = (currentAccounts != nil) ?
		[NSMutableArray arrayWithArray:currentAccounts] :
		[NSMutableArray array];
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
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
		[AccountFormController saveAccounts:accounts];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
	[accounts moveObjectFromIndex:fromPath.row toIndex:toPath.row];
	[AccountFormController saveAccounts:accounts];
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
