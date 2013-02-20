#import "IOCFilesController.h"
#import "CodeController.h"
#import "GHFiles.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "IOCResourceStatusCell.h"


@interface IOCFilesController ()
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCFilesController

- (id)initWithFiles:(GHFiles *)files {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.title = @"Files";
		self.files = files;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.files name:@"files"];
	if (self.files.isUnloaded) {
		[self.files loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.files.isEmpty ? 1 : self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.files.isEmpty) return self.statusCell;
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	}
	NSDictionary *fileInfo = self.files[indexPath.row];
	NSString *patch = [fileInfo safeStringForKeyPath:@"patch"];
	cell.textLabel.text = [fileInfo safeStringForKeyPath:@"filename"];
	cell.selectionStyle = patch.isEmpty ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
	cell.accessoryType = patch.isEmpty ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.files.isEmpty) return;
	id fileInfo = self.files[indexPath.row];
	if ([fileInfo isKindOfClass:NSDictionary.class]) {
		CodeController *codeController = [[CodeController alloc] initWithFiles:self.files currentIndex:indexPath.row];
		[self.navigationController pushViewController:codeController animated:YES];
	}
}

@end