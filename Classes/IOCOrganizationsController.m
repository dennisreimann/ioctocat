#import "IOCOrganizationsController.h"
#import "IOCOrganizationController.h"
#import "IOCUserObjectCell.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"


@implementation IOCOrganizationsController

- (id)initWithOrganizations:(GHOrganizations *)organizations {
    return [super initWithCollection:organizations];
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Organizations", nil);
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
    GHOrganization *org = self.collection[indexPath.row];
    IOCOrganizationController *viewController = [[IOCOrganizationController alloc] initWithOrganization:org];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end