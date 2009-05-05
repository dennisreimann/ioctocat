#import "IssueController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@implementation IssueController

@synthesize issue;

- (id)initWithIssue:(GHIssue *)theIssue {    
    [super initWithNibName:@"Issue" bundle:nil];
	self.issue = theIssue;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Issue";
	titleLabel.text = issue.title;
    voteLabel.text = [NSString stringWithFormat:@"%d votes", issue.votes];
    issueNumber.text = [NSString stringWithFormat:@"#%d", issue.num];
    [contentView setText:issue.body];
	dateLabel.text = [issue.created prettyDate];
    updatedLabel.text = [issue.updated prettyDate];
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
	iconView.image = [UIImage imageNamed:icon];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Issue on GitHub",nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSString *issueURLString = [NSString stringWithFormat:kIssueGithubFormat, issue.repository.owner, issue.repository.name, issue.num];
        NSURL *issueURL = [NSURL URLWithString:issueURLString];
		WebController *webController = [[WebController alloc] initWithURL:issueURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];                        
    }
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[issue release];
	[contentView release];
	[dateLabel release];
    [updatedLabel release];
    [issueNumber release];
	[titleLabel release];
    [voteLabel release];
	[iconView release];
    [super dealloc];
}

@end
