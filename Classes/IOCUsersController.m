#import "IOCUsersController.h"
#import "IOCUserController.h"
#import "GHUsers.h"
#import "IOCUserObjectCell.h"
#import "NSString_IOCExtensions.h"


@implementation IOCUsersController

- (id)initWithUsers:(GHUsers *)users {
	return [super initWithCollection:users];
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Users", nil);
}

- (NSString *)collectionCellIdentifier {
    return kUserObjectCellIdentifier;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCUserObjectCell *cell = (IOCUserObjectCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCUserObjectCell cellWithReuseIdentifier:self.collectionCellIdentifier];
    cell.userObject = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return;
    GHUser *user = self.collection[indexPath.row];
    IOCUserController *userController = [[IOCUserController alloc] initWithUser:user];
    [self.navigationController pushViewController:userController animated:YES];
}

@end