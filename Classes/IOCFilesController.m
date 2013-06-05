#import "IOCFilesController.h"
#import "IOCCodeController.h"
#import "GHFiles.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation IOCFilesController

- (id)initWithFiles:(GHFiles *)files {
	return [super initWithCollection:files];
}

- (NSString *)collectionName {
    return @"Files";
}

- (NSString *)collectionCellIdentifier {
    return @"FileCell";
}

- (BOOL)canReload {
    return NO;
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.collectionCellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	}
	NSDictionary *fileInfo = self.collection[indexPath.row];
	NSString *patch = [fileInfo safeStringForKeyPath:@"patch"];
	cell.textLabel.text = [fileInfo safeStringForKeyPath:@"filename"];
	cell.selectionStyle = patch.isEmpty ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
	cell.accessoryType = patch.isEmpty ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	id fileInfo = self.collection[indexPath.row];
	if ([fileInfo isKindOfClass:NSDictionary.class]) {
		IOCCodeController *codeController = [[IOCCodeController alloc] initWithFiles:(GHFiles *)self.collection currentIndex:indexPath.row];
		[self.navigationController pushViewController:codeController animated:YES];
	}
}

@end