#import "GHGists.h"
#import "GHGist.h"
#import "GistsController.h"
#import "GistController.h"
#import "NSString+Extensions.h"
#import "NSDate+Nibware.h"
#import "iOctocat.h"


@interface GistsController ()
@property(nonatomic,strong)GHGists *gists;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingGistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noGistsCell;

- (IBAction)refresh:(id)sender;
@end


@implementation GistsController

- (id)initWithGists:(GHGists *)theGists {
	self = [super initWithNibName:@"Gists" bundle:nil];
	if (self) {
		self.gists = theGists;
		[self.gists addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.gists removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = [self.title isEmpty] ? @"Gists" : self.title;
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	
	if (!self.gists.isLoaded) [self.gists loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHGists *theGists = (GHGists *)object;
		if (!theGists.isLoading && theGists.error) {
			[iOctocat reportLoadingError:@"Could not load the gists"];
		}
	}
}
#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[self.gists loadData];
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return (self.gists.isLoading || self.gists.isEmpty) ? 1 : self.gists.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gists.isLoading) return self.loadingGistsCell;
	if (self.gists.isEmpty) return self.noGistsCell;
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
	}
	GHGist *gist = (self.gists)[indexPath.row];
	cell.textLabel.text = gist.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %d %@", [gist.createdAtDate prettyDate], gist.commentsCount, gist.commentsCount == 1 ? @"comment" : @"comments"];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.imageView.image = [UIImage imageNamed:(gist.isPrivate ? @"private.png" : @"public.png")];
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.gists.isLoaded || self.gists.isEmpty) return;
	GHGist *gist = (self.gists)[indexPath.row];
	GistController *gistController = [[GistController alloc] initWithGist:gist];
	[self.navigationController pushViewController:gistController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end