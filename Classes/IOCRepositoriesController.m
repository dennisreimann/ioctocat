#import "IOCRepositoriesController.h"
#import "IOCRepositoryController.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCRepositoryCell.h"
#import "NSString_IOCExtensions.h"


@implementation IOCRepositoriesController

- (id)initWithRepositories:(GHRepositories *)repos {
	return [super initWithCollection:repos];
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Repositories", nil);
}

- (NSString *)collectionCellIdentifier {
    return kRepositoryCellIdentifier;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCRepositoryCell *cell = (IOCRepositoryCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCRepositoryCell cellWithReuseIdentifier:self.collectionCellIdentifier];
	cell.repository = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	GHRepository *repo = self.collection[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end