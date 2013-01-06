#import <MessageUI/MessageUI.h>
#import "UserController.h"
#import "RepositoryController.h"
#import "OrganizationController.h"
#import "WebController.h"
#import "GHUsers.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "LabeledCell.h"
#import "RepositoryCell.h"
#import "UserObjectCell.h"
#import "IOCAvatarLoader.h"
#import "iOctocat.h"
#import "UsersController.h"
#import "EventsController.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "GistsController.h"


@interface UserController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *companyLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingUserCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *followersCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *followingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *gistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,strong)IBOutlet LabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet LabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet LabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;

- (void)displayUser;
- (IBAction)showActions:(id)sender;
@end


@implementation UserController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"User" bundle:nil];
	if (self) {
		self.user = user;
		[self.user addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	BOOL isProfile = [self.user.login isEqualToString:self.currentUser.login];
	self.navigationItem.title = isProfile ? @"Profile" : self.user.login;
	self.navigationItem.rightBarButtonItem = isProfile ? nil : [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	if (!self.currentUser.following.isLoaded) [self.currentUser.following loadData];
	(self.user.isLoaded) ? [self displayUser] : [self.user loadData];
	if (!self.user.repositories.isLoaded) [self.user.repositories loadData];
	if (!self.user.organizations.isLoaded) [self.user.organizations loadData];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
	[self.user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:([self.currentUser isFollowing:self.user] ? @"Stop Following" : @"Follow"), @"Open in GitHub",  nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self.currentUser isFollowing:self.user] ? [self.currentUser unfollowUser:self.user] : [self.currentUser followUser:self.user];
	} else if (buttonIndex == 1) {
		WebController *webController = [[WebController alloc] initWithURL:self.user.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)displayUser {
	self.nameLabel.text = (!self.user.name || [self.user.name isEmpty]) ? self.user.login : self.user.name;
	self.companyLabel.text = (!self.user.company || [self.user.company isEmpty]) ? [NSString stringWithFormat:@"%d followers", self.user.followersCount] : self.user.company;
	if (self.user.gravatar) self.gravatarView.image = self.user.gravatar;
	[self.locationCell setContentText:self.user.location];
	[self.blogCell setContentText:[self.user.blogURL host]];
	[self.emailCell setContentText:self.user.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		self.gravatarView.image = self.user.gravatar;
	} else if (object == self.user && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.user.isLoaded) {
			[self displayUser];
			[self.tableView reloadData];
		} else if (self.user.error) {
			[iOctocat reportLoadingError:@"Could not load the user"];
		}
	} else if (object == self.user.repositories && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.user.repositories.isLoaded) {
			[self.tableView reloadData];
		} else if (self.user.repositories.error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}
	} else if (object == self.user.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.user.organizations.isLoaded) {
			[self.tableView reloadData];
		} else if (self.user.organizations.error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!self.user.isLoaded) return 1;
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.user.isLoaded) return 1;
	if (section == 0) return 3;
	if (section == 1) return 4;
	if (section == 2 && (!self.user.repositories.isLoaded || self.user.repositories.isEmpty)) return 1;
	if (section == 2) return self.user.repositories.count;
	if (section == 3 && (!self.user.organizations.isLoaded || self.user.organizations.isEmpty)) return 1;
	if (section == 3) return self.user.organizations.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return @"Repositories";
	if (section == 3) return @"Organizations";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (!self.user.isLoaded) return self.loadingUserCell;
	if (section == 0) {
		LabeledCell *cell;
		switch (row) {
			case 0: cell = self.locationCell; break;
			case 1: cell = self.blogCell; break;
			case 2: cell = self.emailCell; break;
			default: cell = nil;
		}
		BOOL isSelectable = row != 0 && cell.hasContent;
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
	if (section == 1 && row == 0) return self.recentActivityCell;
	if (section == 1 && row == 1) return self.followingCell;
	if (section == 1 && row == 2) return self.followersCell;
	if (section == 1 && row == 3) return self.gistsCell;
	if (section == 2 && !self.user.repositories.isLoaded) return self.loadingReposCell;
	if (section == 2 && self.user.repositories.isEmpty) return self.noPublicReposCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		cell.repository = (self.user.repositories)[indexPath.row];
		[cell hideOwner];
		return cell;
	}
	if (section == 3 && !self.user.organizations.isLoaded) return self.loadingOrganizationsCell;
	if (section == 3 && self.user.organizations.isEmpty) return self.noPublicOrganizationsCell;
	if (section == 3) {
		UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"UserObjectCell" owner:self options:nil];
			cell = self.userObjectCell;
		}
		cell.userObject = (self.user.organizations)[indexPath.row];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.user.isLoaded) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && self.user.blogURL) {
		viewController = [[WebController alloc] initWithURL:self.user.blogURL];
	} else if (section == 0 && row == 2 && self.user.email) {
		MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		[mailComposer setToRecipients:@[self.user.email]];
		[self presentModalViewController:mailComposer animated:YES];
	} else if (section == 1 && row == 0) {
		viewController = [[EventsController alloc] initWithEvents:self.user.events];
		viewController.title = @"Recent Activity";
	} else if (section == 1 && row == 3) {
		viewController = [[GistsController alloc] initWithGists:self.user.gists];
		viewController.title = @"Gists";
	} else if (section == 1) {
		viewController = [[UsersController alloc] initWithUsers:(row == 1 ? self.user.following : self.user.followers)];
		viewController.title = (row == 1) ? @"Following" : @"Followers";
	} else if (section == 2) {
		GHRepository *repo = (self.user.repositories)[indexPath.row];
		viewController = [[RepositoryController alloc] initWithRepository:repo];
	} else if (section == 3) {
		GHOrganization *org = (self.user.organizations)[indexPath.row];
		viewController = [[OrganizationController alloc] initWithOrganization:org];
	}
	// Maybe push a controller
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark MessageComposer Delegate

-(void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end