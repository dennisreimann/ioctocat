#import "GHUser.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHFiles.h"
#import "GHGistComment.h"
#import "GHGistComments.h"
#import "WebController.h"
#import "IOCGistController.h"
#import "CodeController.h"
#import "IOCUserController.h"
#import "CommentController.h"
#import "CommentCell.h"
#import "iOctocat.h"
#import "NSDictionary+Extensions.h"
#import "NSDate+Nibware.h"
#import "SVProgressHUD.h"
#import "LabeledCell.h"
#import "IOCResourceStatusCell.h"
#import "GradientButton.h"


@interface IOCGistController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHGist *gist;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *filesStatusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,weak,readonly)GHUser *currentUser;
@property(nonatomic,readwrite)BOOL isStarring;
@property(nonatomic,weak)IBOutlet UILabel *descriptionLabel;
@property(nonatomic,weak)IBOutlet UILabel *forksCountLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UIImageView *forksIconView;
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet LabeledCell *ownerCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@end


@implementation IOCGistController

- (id)initWithGist:(GHGist *)gist {
	self = [super initWithNibName:@"Gist" bundle:nil];
	if (self) {
		self.gist = gist;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	[self layoutCommentButton];
	self.title = self.title ? self.title : @"Gist";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist name:@"gist"];
	self.filesStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.files name:@"files"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.comments name:@"comments"];
	[self displayGist];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	// check starring state
	[self.currentUser checkGistStarring:self.gist success:^(GHResource *instance, id data) {
		self.isStarring = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isStarring = NO;
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// gist
	if (self.gist.isUnloaded) {
		[self.gist loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayGistChange];
		} failure:nil];
	} else if (self.gist.isChanged) {
		[self displayGistChange];
	}
	// comments
	if (self.gist.comments.isUnloaded) {
		[self.gist.comments loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		} failure:nil];
	} else if (self.gist.comments.isChanged) {
		[self displayCommentsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)displayGist {
	self.iconView.image = [UIImage imageNamed:(self.gist.isPrivate ? @"Private.png" : @"Public.png")];
	self.descriptionLabel.text = self.gist.title;
	self.forksIconView.hidden = !self.gist.isLoaded;
	self.ownerCell.contentText = self.gist.user.login;
	self.createdCell.contentText = [self.gist.createdAtDate prettyDate];
	self.updatedCell.contentText = [self.gist.updatedAtDate prettyDate];
	self.forksCountLabel.text = self.gist.isLoaded ? [NSString stringWithFormat:@"%d %@", self.gist.forksCount, self.gist.forksCount == 1 ? @"fork" : @"forks"] : nil;
}

- (void)displayGistChange {
	[self displayGist];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.gist.isEmpty || self.gist.comments.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
	[self layoutCommentButton];
}

// ugly fix for the problem described here:
// https://github.com/dennisreimann/ioctocat/issues/264
- (void)layoutCommentButton {
	CGRect btnFrame = self.commentButton.frame;
	CGFloat margin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 10 : 45;
	CGFloat width = self.view.frame.size.width - margin * 2;
	btnFrame.origin.x = margin;
	btnFrame.size.width = width;
	self.commentButton.frame = btnFrame;
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(self.isStarring ? @"Unstar" : @"Star"), @"Add comment", @"Show on GitHub", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self toggleGistStarring];
	} else if (buttonIndex == 1) {
		[self addComment:nil];
	} else if (buttonIndex == 2) {
		WebController *webController = [[WebController alloc] initWithURL:self.gist.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (IBAction)addComment:(id)sender {
	GHGistComment *comment = [[GHGistComment alloc] initWithGist:self.gist];
	comment.userLogin = self.currentUser.login;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.gist.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)toggleGistStarring {
	BOOL state = !self.isStarring;
	NSString *action = state ? @"Starring" : @"Unstarring";
	NSString *status = [NSString stringWithFormat:@"%@ gist", action];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setStarring:state forGist:self.gist success:^(GHResource *instance, id data) {
		NSString *action = state ? @"Starred" : @"Unstarred";
		NSString *status = [NSString stringWithFormat:@"%@ gist", action];
		self.isStarring = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? @"Starring" : @"Unstarring";
		NSString *status = [NSString stringWithFormat:@"%@ gist failed", action];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.gist.isLoaded ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.gist.isEmpty) return 1;
	if (section == 0) {
		return 3;
	} else if (section == 1) {
		return self.gist.files.isEmpty ? 1 : self.gist.files.count;
	} else {
		return self.gist.comments.isEmpty ? 1 : self.gist.comments.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Files";
	} else if (section == 2) {
		return @"Comments";
	} else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	if (self.gist.isEmpty) return self.statusCell;
	if (section == 0) {
		switch (row) {
			case 0: cell = self.ownerCell; break;
			case 1: cell = self.createdCell; break;
			case 2: cell = self.updatedCell; break;
			default: cell = nil;
		}
		BOOL isSelectable = row == 0 && [(LabeledCell *)cell hasContent];
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if (section == 1) {
		if (self.gist.files.isEmpty) return self.filesStatusCell;
		static NSString *CellIdentifier = @"FileCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:15.0];
		}
		NSDictionary *file = self.gist.files[row];
		NSString *fileContent = [file safeStringForKey:@"content"];
		cell.textLabel.text = [file safeStringForKey:@"filename"];
		cell.selectionStyle = fileContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = fileContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	} else if (section == 2) {
		if (self.gist.comments.isEmpty) return self.commentsStatusCell;
		cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
			cell = self.commentCell;
		}
		GHComment *comment = self.gist.comments[indexPath.row];
		[(CommentCell *)cell setComment:comment];
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return section == 2 ? self.tableFooterView : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && !self.gist.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 2) {
		return 56;
	} else {
		return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gist.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && self.gist.user) {
		IOCUserController *userController = [[IOCUserController alloc] initWithUser:self.gist.user];
		[self.navigationController pushViewController:userController animated:YES];
	} if (section == 1) {
		CodeController *codeController = [[CodeController alloc] initWithFiles:self.gist.files currentIndex:row];
		[self.navigationController pushViewController:codeController animated:YES];
	}
}

@end