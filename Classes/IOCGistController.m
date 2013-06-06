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
#import "NSDictionary+Extensions.h"
#import "NSDate+Nibware.h"
#import "SVProgressHUD.h"
#import "IOCLabeledCell.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "GradientButton.h"
#import "NSURL+Extensions.h"


@interface IOCGistController () <UIActionSheetDelegate, IOCTextCellDelegate>
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
	self.title = self.title ? self.title : @"Gist";
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectZero];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist name:@"gist"];
	self.filesStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.files name:@"files"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.gist.comments name:@"comments"];
	[self layoutTableHeader];
	[self layoutTableFooter];
	[self displayGist];
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
	self.createdCell.contentText = [self.gist.createdAt prettyDate];
	self.updatedCell.contentText = [self.gist.updatedAt prettyDate];
	self.forksCountLabel.text = self.gist.isLoaded ? [NSString stringWithFormat:@"%d %@", self.gist.forksCount, self.gist.forksCount == 1 ? @"fork" : @"forks"] : nil;
}

- (void)displayGistChange {
	[self displayGist];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.gist.isEmpty) return;
	[self.tableView reloadData];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

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
		IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.gist.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (IBAction)addComment:(id)sender {
	GHGistComment *comment = [[GHGistComment alloc] initWithGist:self.gist];
	comment.user = self.currentUser;
	IOCCommentController *viewController = [[IOCCommentController alloc] initWithComment:comment andComments:self.gist.comments];
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
		return @"Files";
	} else if (section == 3) {
		return @"Comments";
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
		NSString *fileContent = [file safeStringForKey:@"content"];
		cell.textLabel.text = [file safeStringForKey:@"filename"];
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
        viewController.title = @"Forks";
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

@end