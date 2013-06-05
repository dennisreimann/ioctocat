#import "IOCUsersController.h"
#import "IOCUserController.h"
#import "GHUsers.h"
#import "UserObjectCell.h"
#import "NSString+Extensions.h"


@implementation IOCUsersController

- (id)initWithUsers:(GHUsers *)users {
	return [super initWithCollection:users];
}

- (NSString *)collectionName {
    return @"Users";
}

- (NSString *)collectionCellIdentifier {
    return kRepositoryCellIdentifier;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
	if (!cell) cell = [UserObjectCell cellWithReuseIdentifier:kUserObjectCellIdentifier];
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