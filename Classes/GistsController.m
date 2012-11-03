#import "GHGists.h"
#import "GHGist.h"
#import "GistsController.h"
#import "GistController.h"
#import "AccountController.h"
#import "NSString+Extensions.h"
#import "NSDate+Nibware.h"


@interface GistsController ()
@property(nonatomic,retain)GHGists *gists;
@end


@implementation GistsController

@synthesize gists;

+ (id)controllerWithGists:(GHGists *)theGists {
	return [[[self.class alloc] initWithGists:theGists] autorelease];
}

- (id)initWithGists:(GHGists *)theGists {
    [super initWithNibName:@"Gists" bundle:nil];
	self.gists = theGists;
	[self.gists addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	
	return self;
}

- (void)dealloc {
	[gists removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [gists release], gists = nil;
    [loadingGistsCell release], loadingGistsCell = nil;
    [noGistsCell release], noGistsCell = nil;
    [super dealloc];
}

- (AccountController *)accountController {
	return [[iOctocat sharedInstance] accountController];
}

- (UIViewController *)parentViewController {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController : nil;
}

- (UINavigationItem *)navItem {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController.navigationItem : self.navigationItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    self.navItem.title = [self.title isEmpty] ? @"Gists" : self.title;
	self.navItem.titleView = nil;
	self.navItem.rightBarButtonItem = nil;
	
    if (!gists.isLoaded) [gists loadData];
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

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return (gists.isLoading || gists.gists.count == 0) ? 1 : gists.gists.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (gists.isLoading) return loadingGistsCell;
	if (gists.gists.count == 0) return noGistsCell;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
	GHGist *gist = [gists.gists objectAtIndex:indexPath.row];
	cell.textLabel.text = gist.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@, %d %@, %@", gist.files.count, gist.files.count == 1 ? @"file" : @"files", gist.commentsCount, gist.commentsCount == 1 ? @"comment" : @"comments", [gist.createdAtDate prettyDate]];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.imageView.image = [UIImage imageNamed:(gist.isPrivate ? @"private.png" : @"public.png")];
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!gists.isLoaded || gists.gists.count == 0) return;
	GHGist *gist = [gists.gists objectAtIndex:indexPath.row];
	GistController *gistController = [GistController controllerWithGist:gist];
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

