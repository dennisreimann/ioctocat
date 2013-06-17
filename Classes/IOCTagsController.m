#import "IOCTagsController.h"
#import "GHTags.h"
#import "GHTag.h"
#import "IOCTreeController.h"


@implementation IOCTagsController

- (id)initWithTags:(GHTags *)tags {
	return [super initWithCollection:tags];
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Tags", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"TagCell";
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:self.collectionCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"tag.png"];
    }
    GHTag *tag = self.collection[indexPath.row];
    cell.textLabel.text = tag.tag;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	GHTag *tag = self.collection[indexPath.row];
	IOCTreeController *viewController = [[IOCTreeController alloc] initWithTree:tag.tree];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end