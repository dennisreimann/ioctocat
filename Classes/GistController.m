#import "GHUser.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHGistComment.h"
#import "GHGistComments.h"
#import "WebController.h"
#import "GistController.h"
#import "CodeController.h"
#import "CommentController.h"
#import "CommentCell.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDate+Nibware.h"


@interface GistController ()
@property(nonatomic,retain)GHGist *gist;
@property(nonatomic,readonly)GHUser *currentUser;

- (void)displayGist;
- (void)displayComments;
@end


@implementation GistController

@synthesize gist;

+ (id)controllerWithGist:(GHGist *)theGist {
	return [[[self alloc] initWithGist:theGist] autorelease];
}

- (id)initWithGist:(GHGist *)theGist {
	[super initWithNibName:@"Gist" bundle:nil];
	self.gist = theGist;
	[gist addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[gist.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Gist";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	[self displayGist];
	if (!gist.isLoaded) [gist loadData];
	(gist.comments.isLoaded) ? [self displayComments] : [gist.comments loadData];
    if (!self.currentUser.starredGists.isLoaded) [self.currentUser.starredGists loadData];

	// Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[gist.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[gist removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[gist release], gist = nil;
	[tableHeaderView release], tableHeaderView = nil;
	[tableFooterView release], tableFooterView = nil;
	[descriptionLabel release], descriptionLabel = nil;
	[numbersLabel release], numbersLabel = nil;
	[ownerLabel release], ownerLabel = nil;
	[loadingCell release], loadingCell = nil;
	[noFilesCell release], noFilesCell = nil;
	[loadingCommentsCell release], loadingCommentsCell = nil;
	[noCommentsCell release], noCommentsCell = nil;
	[commentCell release], commentCell = nil;
    [iconView release], iconView = nil;
    [super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:
								  ([self.currentUser isStarringGist:gist] ? @"Unstar" : @"Star"),
								  @"Show on GitHub",
								  nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.currentUser isStarringGist:gist] ? [self.currentUser unstarGist:gist] : [self.currentUser starGist:gist];
    } else if (buttonIndex == 1) {
		WebController *webController = [[WebController alloc] initWithURL:gist.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
    }
}

#pragma mark Actions

- (void)displayGist {
    iconView.image = [UIImage imageNamed:(gist.isPrivate ? @"private.png" : @"public.png")];
	descriptionLabel.text = gist.title;
	if (gist.createdAtDate) {
		ownerLabel.text = [NSString stringWithFormat:@"%@, %@", gist.user ? gist.user.login : @"unknown user", [gist.createdAtDate prettyDate]];
		numbersLabel.text = gist.isLoaded ? [NSString stringWithFormat:@"%d %@", gist.forksCount, gist.forksCount == 1 ? @"fork" : @"forks"] : @"";
	}
}

- (void)displayComments {
	self.tableView.tableFooterView = tableFooterView;
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == gist && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (gist.isLoaded) {
			[self displayGist];
			[self.tableView reloadData];
		} else if (gist.error) {
			[iOctocat reportLoadingError:@"Could not load the gist"];
		}
	} else if (object == gist.comments && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (gist.comments.isLoaded) {
			[self displayComments];
		} else if (gist.comments.error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
		}
	}
}

- (IBAction)addComment:(id)sender {
	GHGistComment *comment = [[GHGistComment alloc] initWithGist:gist];
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:gist.comments];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	[comment release];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (gist.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!gist.isLoaded) return 1;
	if (section == 0)	return gist.files.count;
	if (section == 1 && !gist.comments.isLoaded) return 1;
	return gist.comments.comments.count == 0 ? 1 : gist.comments.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (!gist.isLoaded) return loadingCell;
	if (gist.isLoaded && gist.files.count == 0) return noFilesCell;
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
	if (section == 0) {
		NSDictionary *file = [[gist.files allValues] objectAtIndex:row];
		cell.textLabel.text = [file valueForKey:@"filename"];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (section == 1) {
		if (!gist.comments.isLoaded) return loadingCommentsCell;
		if (gist.comments.comments.count == 0) return noCommentsCell;
		
		cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
			cell = commentCell;
		}
		GHComment *comment = [gist.comments.comments objectAtIndex:indexPath.row];
		[(CommentCell *)cell setComment:comment];
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && gist.comments.isLoaded && gist.comments.comments.count > 0) {
		CommentCell *cell = (CommentCell *)[self tableView:theTableView cellForRowAtIndexPath:indexPath];
		return [cell height];
	}
	return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!gist.isLoaded) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0) {
		NSArray *files = [gist.files allValues];
		CodeController *codeController = [CodeController controllerWithFiles:files currentIndex:row];
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
