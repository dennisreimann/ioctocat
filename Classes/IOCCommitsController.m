#import "IOCCommitsController.h"
#import "IOCCommitController.h"
#import "IOCCommitCell.h"
#import "GHCommits.h"
#import "GHCommit.h"


@implementation IOCCommitsController

- (id)initWithCommits:(GHCommits *)commits {
	return [super initWithCollection:commits];
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Commits", nil);
}

- (NSString *)collectionCellIdentifier {
    return kCommitCellIdentifier;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCCommitCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCCommitCell cellWithReuseIdentifier:self.collectionCellIdentifier];
	cell.commit = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	GHCommit *commit = self.collection[indexPath.row];
	IOCCommitController *viewController = [[IOCCommitController alloc] initWithCommit:commit];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.collection.isEmpty;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    GHCommit *commit = self.collection[indexPath.row];
    [UIPasteboard generalPasteboard].string = commit.shortenedSha;
}

#pragma mark Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end