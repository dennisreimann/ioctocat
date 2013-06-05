#import "IOCOrganizationsController.h"
#import "IOCOrganizationController.h"
#import "UserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"


@implementation IOCOrganizationsController

- (id)initWithOrganizations:(GHOrganizations *)organizations {
    return [super initWithCollection:organizations];
}

- (NSString *)collectionName {
    return @"Organizations";
}

- (NSString *)collectionCellIdentifier {
    return kUserObjectCellIdentifier;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [UserObjectCell cellWithReuseIdentifier:self.collectionCellIdentifier];
    cell.userObject = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return;
    GHOrganization *org = self.collection[indexPath.row];
    IOCOrganizationController *viewController = [[IOCOrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end