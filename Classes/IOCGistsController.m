#import "GHGists.h"
#import "GHGist.h"
#import "IOCGistsController.h"
#import "IOCGistController.h"
#import "IOCGistCell.h"


@implementation IOCGistsController

- (id)initWithGists:(GHGists *)gists {
	self = [super initWithCollection:gists];
	if (self) {
		self.hideUser = NO;
	}
	return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Gists", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"GistCell";
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCGistCell *cell = (IOCGistCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCGistCell cellWithReuseIdentifier:self.collectionCellIdentifier];
	if (self.hideUser) [cell hideUser];
	cell.gist = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	GHGist *gist = self.collection[indexPath.row];
	IOCGistController *gistController = [[IOCGistController alloc] initWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

@end