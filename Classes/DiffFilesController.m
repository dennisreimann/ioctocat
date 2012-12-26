#import "DiffFilesController.h"
#import "CodeController.h"
#import "GHFiles.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface DiffFilesController ()
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingFilesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noFilesCell;
@end


@implementation DiffFilesController

- (id)initWithFiles:(GHFiles *)files {
	self = [super initWithNibName:@"Files" bundle:nil];
	self.title = @"Files";
	self.files = files;
	[self.files addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.files.isLoaded) [self.files loadData];
}

- (void)dealloc {
	[self.files removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		if (!self.files.isLoading && self.files.error) {
			[iOctocat reportLoadingError:@"Could not load the files"];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.files.isLoading || self.files.isEmpty) ? 1 : self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.files.isLoading) return self.loadingFilesCell;
	if (self.files.isEmpty) return self.noFilesCell;
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
	if ([fileInfo isKindOfClass:[NSDictionary class]]) {
		CodeController *codeController = [[CodeController alloc] initWithFiles:self.files currentIndex:indexPath.row];
		[self.navigationController pushViewController:codeController animated:YES];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end