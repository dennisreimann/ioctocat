#import "GHUser.h"
#import "GHGist.h"
#import "GHGists.h"
#import "GHFiles.h"
#import "GHGistComment.h"
#import "GHGistComments.h"
#import "IOCWebController.h"
#import "IOCGistController.h"
#import "IOCGistsController.h"
#import "IOCCodeController.h"
#import "IOCUserController.h"
#import "IOCCommentController.h"
#import "IOCCommentCell.h"
#import "iOctocat.h"
#import "NSDictionary_IOCExtensions.h"
#import "NSDate_IOCExtensions.h"
#import "SVProgressHUD.h"
#import "IOCLabeledCell.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "GradientButton.h"
#import "NSURL_IOCExtensions.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface IOCGistController () <UIActionSheetDelegate, IOCTextCellDelegate, IOCResourceEditingDelegate>
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
@property(nonatomic,strong)IBOutlet UITableViewCell *forkCell;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *ownerCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet IOCCommentCell *commentCell;
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
	self.title = self.title ? self.title : NSLocalizedString(@"Gist", nil);
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectZero];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist name:NSLocalizedString(@"gist", nil)];
	self.filesStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.files name:NSLocalizedString(@"files", nil)];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.comments name:NSLocalizedString(@"comments", nil)];
	[self layoutTableHeader];
	[self layoutTableFooter];
	[self setupInfiniteScrolling];
	[self displayGist];
    [self.currentUser checkGistStarring:self.gist usingBlock:^(BOOL isStarring) {
        self.isStarring = isStarring;
    }];
    // comment menu
    UIMenuController.sharedMenuController.menuItems = @[
                                                        [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) action:@selector(editComment:)],
                                                        [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(deleteComment:)]];
    [UIMenuController.sharedMenuController update];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// gist
	if (self.gist.isUnloaded) {
		[self.gist loadWithSuccess:^(GHResource *instance, id data) {
			[self displayGistChange];
		}];
	} else if (self.gist.isChanged) {
		[self displayGistChange];
	}
	// comments
	if (self.gist.comments.isUnloaded) {
		[self.gist.comments loadWithSuccess:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		}];
	} else if (self.gist.comments.isChanged) {
		[self displayCommentsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (void)displayGist {
	self.iconView.image = [UIImage imageNamed:(self.gist.isPrivate ? @"GistPrivate.png" : @"GistPublic.png")];
	self.descriptionLabel.text = self.gist.title;
	self.forksIconView.hidden = !self.gist.isLoaded;
	self.ownerCell.contentText = self.gist.user.login;
	self.createdCell.contentText = [self.gist.createdAt ioc_prettyDate];
	self.updatedCell.contentText = [self.gist.updatedAt ioc_prettyDate];
    self.tableView.showsInfiniteScrolling = self.gist.comments.hasNextPage;
    if (self.gist.isLoaded) {
        self.forksCountLabel.text = [NSString stringWithFormat:self.gist.forksCount == 1 ? NSLocalizedString(@"%d fork", @"Single fork") : NSLocalizedString(@"%d forks", @"Multiple forks"), self.gist.forksCount];
    } else {
        self.forksCountLabel.text = nil;
    }
}

- (void)displayGistChange {
	[self displayGist];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.gist.isEmpty) return;
	[self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.gist.comments.hasNextPage;
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.gist.comments loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayCommentsChange];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:error.localizedDescription];
        }];
	}];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:(self.isStarring ? NSLocalizedString(@"Unstar", @"Action Sheet: Unstar") : NSLocalizedString(@"Star", @"Action Sheet: Star")), NSLocalizedString(@"Add comment", @"Action Sheet: Add comment"), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self toggleGistStarring];
	} else if (buttonIndex == 1) {
		[self addComment:nil];
	} else if (buttonIndex == 2) {
		IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.gist.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)toggleGistStarring {
	BOOL state = !self.isStarring;
	NSString *status = state ? NSLocalizedString(@"Starring gist", @"Progress HUD: Starring gist") : NSLocalizedString(@"Unstarring gist", @"Progress HUD: Unstarring gist");
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setStarring:state forGist:self.gist success:^(GHResource *instance, id data) {
		NSString *status = state ? NSLocalizedString(@"Starred gist", @"Progress HUD: Starred gist") : NSLocalizedString(@"Unstarred gist", @"Progress HUD: Unstarred gist");
		self.isStarring = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *status = state ? NSLocalizedString(@"Starring gist failed", @"Progress HUD: Starring gist failed") : NSLocalizedString(@"Unstarring gist failed", @"Progress HUD: Unstarring gist failed");
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

- (IBAction)addComment:(id)sender {
	GHGistComment *comment = [[GHGistComment alloc] initWithGist:self.gist];
	[self editResource:comment];
}

- (void)editResource:(GHComment *)comment {
    IOCCommentController *viewController = [[IOCCommentController alloc] initWithComment:comment andComments:self.gist.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)deleteResource:(GHComment *)comment {
    [self.gist.comments deleteObject:comment start:^(GHResource *instance) {
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting comment", nil) maskType:SVProgressHUDMaskTypeGradient];
    } success:^(GHResource *instance, id data) {
		[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted comment", nil)];
        [self displayCommentsChange];
    } failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Deleting comment failed", nil)];
    }];
}

- (BOOL)canManageResource:(GHComment *)comment {
    return self.gist.user == self.currentUser || comment.user == self.currentUser;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.gist.isLoaded ? 4 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.gist.isEmpty) return 1;
	if (section == 0) {
		return 3;
	} else if (section == 1) {
		return 1;
	} else if (section == 2) {
		return self.gist.files.isEmpty ? 1 : self.gist.files.count;
	} else {
		return self.gist.comments.isEmpty ? 1 : self.gist.comments.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) {
		return NSLocalizedString(@"Files", nil);
	} else if (section == 3) {
		return NSLocalizedString(@"Comments", nil);
	} else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (self.gist.isEmpty) return self.statusCell;
	if (section == 0) {
        UITableViewCell *cell = nil;
		switch (row) {
			case 0: cell = self.ownerCell; break;
			case 1: cell = self.createdCell; break;
			case 2: cell = self.updatedCell; break;
			default: cell = nil;
		}
		BOOL isSelectable = row == 0 && [(IOCLabeledCell *)cell hasContent];
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    } else if (section == 1) {
		return self.forkCell;
	} else if (section == 2) {
        if (self.gist.files.isEmpty) return self.filesStatusCell;
		static NSString *CellIdentifier = @"FileCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:15.0];
		}
		NSDictionary *file = self.gist.files[row];
		NSString *fileContent = [file ioc_stringForKey:@"content"];
		cell.textLabel.text = [file ioc_stringForKey:@"filename"];
		cell.selectionStyle = fileContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = fileContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        return cell;
    } else {
		if (self.gist.comments.isEmpty) return self.commentsStatusCell;
		IOCCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
		if (!cell) {
			[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
			cell = self.commentCell;
		}
		cell.delegate = self;
		GHComment *comment = self.gist.comments[indexPath.row];
		cell.comment = comment;
        return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 3 && !self.gist.comments.isEmpty) {
		IOCCommentCell *cell = (IOCCommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.gist.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
    UIViewController *viewController = nil;
	if (section == 0 && row == 0 && self.gist.user) {
        viewController = [[IOCUserController alloc] initWithUser:self.gist.user];
    } else if (section == 1) {
        viewController = [[IOCGistsController alloc] initWithGists:self.gist.forks];
        viewController.title = NSLocalizedString(@"Forks", nil);
    } else if (section == 2) {
        viewController = [[IOCCodeController alloc] initWithFiles:self.gist.files currentIndex:row];
    }
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)layoutTableHeader {
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)layoutTableFooter {
	self.tableView.tableFooterView = self.tableFooterView;
	CGRect btnFrame = self.commentButton.frame;
	CGFloat margin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 10 : 45;
	CGFloat width = self.view.frame.size.width - margin * 2;
	btnFrame.origin.x = margin;
	btnFrame.size.width = width;
	self.commentButton.frame = btnFrame;
}

#pragma mark Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:IOCTextCell.class];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell isKindOfClass:IOCTextCell.class] && action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
}

@end