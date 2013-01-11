#import "GHUser.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHFiles.h"
#import "GHGistComment.h"
#import "GHGistComments.h"
#import "WebController.h"
#import "GistController.h"
#import "CodeController.h"
#import "CommentController.h"
#import "CommentCell.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"
#import "NSDate+Nibware.h"


@interface GistController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHGist *gist;
@property(weak, nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,weak)IBOutlet UILabel *descriptionLabel;
@property(nonatomic,weak)IBOutlet UILabel *numbersLabel;
@property(nonatomic,weak)IBOutlet UILabel *ownerLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noFilesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;

- (void)displayGist;
- (void)displayComments;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;
@end


@implementation GistController

NSString *const GistLoadingKeyPath = @"loadingStatus";
NSString *const GistCommentsLoadingKeyPath = @"comments.loadingStatus";

- (id)initWithGist:(GHGist *)gist {
	self = [super initWithNibName:@"Gist" bundle:nil];
	if (self) {
		self.gist = gist;
		[self.gist addObserver:self forKeyPath:GistLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.gist addObserver:self forKeyPath:GistCommentsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Gist";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	if (!self.currentUser.starredGists.isLoaded) [self.currentUser.starredGists loadData];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	(self.gist.isLoaded) ? [self displayGist] : [self.gist loadData];
	(self.gist.comments.isLoaded) ? [self displayComments] : [self.gist.comments loadData];
}

- (void)dealloc {
	[self.gist removeObserver:self forKeyPath:GistCommentsLoadingKeyPath];
	[self.gist removeObserver:self forKeyPath:GistLoadingKeyPath];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
															 delegate:self
													cancelButtonTitle:@"Cancel"
												 destructiveButtonTitle:nil
													otherButtonTitles:
									([self.currentUser isStarringGist:self.gist] ? @"Unstar" : @"Star"),
									@"Show on GitHub",
									nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self.currentUser isStarringGist:self.gist] ? [self.currentUser unstarGist:self.gist] : [self.currentUser starGist:self.gist];
	} else if (buttonIndex == 1) {
		WebController *webController = [[WebController alloc] initWithURL:self.gist.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)displayGist {
	self.iconView.image = [UIImage imageNamed:(self.gist.isPrivate ? @"Private.png" : @"Public.png")];
	self.descriptionLabel.text = self.gist.title;
	if (self.gist.createdAtDate) {
		self.ownerLabel.text = [NSString stringWithFormat:@"%@, %@", self.gist.user ? self.gist.user.login : @"unknown user", [self.gist.createdAtDate prettyDate]];
		self.numbersLabel.text = self.gist.isLoaded ? [NSString stringWithFormat:@"%d %@", self.gist.forksCount, self.gist.forksCount == 1 ? @"fork" : @"forks"] : @"";
	}
	[self.tableView reloadData];
}

- (void)displayComments {
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:GistLoadingKeyPath]) {
		if (self.gist.isLoaded) {
			[self displayGist];
		} else if (self.gist.error) {
			[iOctocat reportLoadingError:@"The gist could not be loaded completely"];
			[self.tableView reloadData];
		}
	} else if ([keyPath isEqualToString:GistCommentsLoadingKeyPath]) {
		if (self.gist.comments.isLoading && self.gist.isLoaded) {
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
		} else if (self.gist.comments.isLoaded) {
			[self displayComments];
		} else if (self.gist.comments.error && !self.gist.error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
			[self.tableView reloadData];
		}
	}
}

- (IBAction)addComment:(id)sender {
	GHGistComment *comment = [[GHGistComment alloc] initWithGist:self.gist];
	comment.userLogin = self.currentUser.login;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.gist.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (!self.gist.isLoaded) ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.gist.isLoaded) return 1;
	if (section == 0) return self.gist.files.count;
	if (section == 1 && !self.gist.comments.isLoaded) return 1;
	if (self.gist.comments.isEmpty) return 1;
	return self.gist.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (self.gist.isLoading) return self.loadingCell;
	if (!self.gist.isLoading && self.gist.files.count == 0) return self.noFilesCell;
	static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		}
	if (section == 0) {
		NSDictionary *file = self.gist.files[row];
		NSString *fileContent = [file safeStringForKey:@"content"];
		cell.textLabel.text = [file safeStringForKey:@"filename"];
		cell.selectionStyle = fileContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = fileContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if (section == 1) {
		if (!self.gist.comments.isLoaded) return self.loadingCommentsCell;
		if (self.gist.comments.isEmpty) return self.noCommentsCell;
		cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
			cell = self.commentCell;
		}
		GHComment *comment = (self.gist.comments)[indexPath.row];
		[(CommentCell *)cell setComment:comment];
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return self.tableFooterView;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && self.gist.comments.isLoaded && !self.gist.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return 56;
	} else {
		return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.gist.isLoaded) return;
	if (indexPath.section == 0) {
		CodeController *codeController = [[CodeController alloc] initWithFiles:self.gist.files currentIndex:indexPath.row];
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