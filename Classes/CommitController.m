#import "CommitController.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "TextCell.h"


@interface CommitController ()
- (void)displayCommit;
@end


@implementation CommitController

@synthesize commit;
@synthesize loadingCell;
@synthesize authorCell;
@synthesize committerCell;
@synthesize messageCell;
@synthesize tableHeaderView;
@synthesize authorLabel;
@synthesize committerLabel;

- (id)initWithCommit:(GHCommit *)theCommit {    
    [super initWithNibName:@"Commit" bundle:nil];
	self.commit = theCommit;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[commit addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [commit.commitID substringToIndex:8];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.tableView.tableHeaderView = tableHeaderView;
	(commit.isLoaded) ? [self displayCommit] : [commit loadCommit];
}

- (void)viewDidUnload {
	self.loadingCell = nil;
	self.authorCell = nil;
    self.committerCell = nil;
    self.messageCell = nil;
    self.tableHeaderView = nil;
    self.authorLabel = nil;
    self.committerLabel = nil;
}

- (void)dealloc {
	[commit removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commit release], commit = nil;
	[loadingCell release], loadingCell = nil;
    [authorCell release], authorCell = nil;
    [committerCell release], committerCell = nil;
    [messageCell release], messageCell = nil;
    [tableHeaderView release], tableHeaderView = nil;
    [authorLabel release], authorLabel = nil;
    [committerLabel release], committerLabel = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)displayCommit {
	[authorCell setContentText:commit.author.name];
	[committerCell setContentText:commit.committer.name];
	[messageCell setContentText:commit.message];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Show %@", commit.repository.name], @"Show on GitHub", nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	// TODO Implement
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (commit.isLoaded) {
			[self displayCommit];
			[self.tableView reloadData];
		} else if (commit.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the commit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (commit.isLoaded) ? 1 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!commit.isLoaded) return 1;
	if (section == 0) return 3;
//	if (section == 1) return 2;
//	return [repository.branches.branches count];
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!commit.isLoaded) return loadingCell;
	if (indexPath.row == 0) return messageCell;             
	if (indexPath.row == 1) return authorCell;
	return committerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (commit.isLoaded && indexPath.row == 0) return [(TextCell *)messageCell height];
	return 44.0f;
}

@end
