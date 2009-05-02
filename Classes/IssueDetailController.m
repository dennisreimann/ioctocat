#import "IssueDetailController.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "GHUser.h"
#import "GHRepository.h"


@implementation IssueDetailController

@synthesize issue;

- (id)initWithIssue:(GHIssue *)theIssue {    
    [super initWithNibName:@"IssueDetail" bundle:nil];
	self.issue = theIssue;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Issue Details";
	titleLabel.text = issue.title;
    voteLabel.text = [NSString stringWithFormat:@"%d votes", issue.votes];
    [contentView setText:issue.body];
	// Date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:issue.created];
	[dateFormatter release];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", @"issues_opened"];
	iconView.image = [UIImage imageNamed:icon];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[issue release];
	[contentView release];
	[dateLabel release];
	[titleLabel release];
    [voteLabel release];
	[iconView release];
    [super dealloc];
}

@end
