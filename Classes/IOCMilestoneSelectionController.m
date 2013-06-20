#import "IOCMilestoneSelectionController.h"
#import "IOCMilestoneCell.h"
#import "IOCTitleBodyFormController.h"
#import "GHRepository.h"
#import "GHMilestones.h"
#import "GHMilestone.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "UIViewController_IOCExtensions.h"


@interface IOCMilestoneSelectionController () <IOCResourceEditingDelegate>
@property(nonatomic,weak)GHIssue *issue;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,readwrite)BOOL isAssignee;
@end


@implementation IOCMilestoneSelectionController

- (id)initWithIssue:(GHIssue *)issue {
    self = [super initWithCollection:issue.repository.milestones];
    if (self) {
        _issue = issue;
    }
    return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Milestones", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"MilestoneCell";
}

- (BOOL)canReload {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createMilestone:)];
    self.isAssignee = NO;
    GHMilestone *currentMilestone = self.issue.milestone;
    if (currentMilestone) {
        [self.collection whenLoaded:^(GHResource *instance, id data) {
            NSInteger index = [self.collection indexOfObject:currentMilestone];
            self.selectedIndexPath = index != NSNotFound ? [NSIndexPath indexPathForRow:index inSection:0] : nil;
            [self displayCollection];
        }];
    } else {
        self.selectedIndexPath = nil;
    }
    [self.issue.repository checkAssignment:self.currentUser usingBlock:^(BOOL isAssignee) {
        self.isAssignee = isAssignee;
    }];
    // menu
    UIMenuController.sharedMenuController.menuItems = @[
                                                        [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) action:@selector(editMilestone:)],
                                                        [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(deleteMilestone:)]];
    [UIMenuController.sharedMenuController update];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.collection.isLoaded || !self.ioc_isBeingPopped) return;
    GHMilestone *oldMilestone = self.issue.milestone;
    GHMilestone *newMilestone = self.selectedIndexPath ? self.collection[self.selectedIndexPath.row] : nil;
    if (newMilestone != oldMilestone) {
        NSDictionary *params = @{@"milestone": newMilestone ? [NSString stringWithFormat:@"%d", newMilestone.number] : @""};
        [self.issue saveWithParams:params start:^(GHResource *instance) {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Saving milestone", nil) maskType:SVProgressHUDMaskTypeGradient];
        } success:^(GHResource *instance, id data) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Saved milestone", nil)];
            self.issue.milestone = newMilestone;
            [self.issue markAsChanged];
            [self.delegate performSelector:@selector(savedResource:) withObject:self.issue];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(GHResource *instance, NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Saving milestone failed", nil)];
        }];
    }
}

#pragma mark Actions

- (IBAction)createMilestone:(id)sender {
	GHMilestone *milestone = [[GHMilestone alloc] initWithRepository:self.issue.repository];
	[self editResource:milestone];
}

- (void)editResource:(GHMilestone *)milestone {
    IOCTitleBodyFormController *formController = [[IOCTitleBodyFormController alloc] initWithResource:milestone name:NSLocalizedString(@"milestone", nil)];
    formController.apiBodyAttributeName = @"description";
	formController.delegate = self;
	[self.navigationController pushViewController:formController animated:YES];
}

- (void)deleteResource:(GHMilestone *)milestone {
    GHMilestone *selectedMilestone = self.selectedIndexPath ? self.collection[self.selectedIndexPath.row] : nil;
    [self.collection deleteObject:milestone start:^(GHResource *instance) {
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting milestone", nil) maskType:SVProgressHUDMaskTypeGradient];
    } success:^(GHResource *instance, id data) {
        // renew or unset selection
        if (selectedMilestone) {
            NSInteger index = [self.collection indexOfObject:selectedMilestone];
            self.selectedIndexPath = index != NSNotFound ? [NSIndexPath indexPathForRow:index inSection:0] : nil;
        }
		[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted milestone", nil)];
        [self displayCollection];
    } failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Deleting milestone failed", nil)];
    }];
}

- (BOOL)canManageResource:(GHMilestone *)milestone {
    return self.isAssignee;
}

// delegation method for newly created milestones
- (void)savedResource:(id)resource {
    if (![self.collection containsObject:resource]) {
        [self.collection addObject:resource];
        self.selectedIndexPath = [NSIndexPath indexPathForRow:self.collection.count-1 inSection:0];
    }
    [self displayCollection];
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCMilestoneCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) {
        cell = [IOCMilestoneCell cellWithReuseIdentifier:self.collectionCellIdentifier];
        cell.delegate = self;
    }
	cell.milestone = self.collection[indexPath.row];
	cell.accessoryType = self.selectedIndexPath && self.selectedIndexPath.row == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return;
    UITableViewCell *cell = nil;
    if (self.selectedIndexPath) {
        cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([self.selectedIndexPath isEqual:indexPath]) {
        self.selectedIndexPath = nil;
    } else {
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndexPath = indexPath;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return 44.0f;
    IOCMilestoneCell *cell = (IOCMilestoneCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell heightForTableView:tableView];
    return height;
}

#pragma mark Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:IOCMilestoneCell.class];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
}

@end