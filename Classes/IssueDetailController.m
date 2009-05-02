#import "IssueDetailController.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"


@implementation IssueDetailController

@synthesize issue, repository;

- (id)initWithIssue:(GHIssue *)theIssue andRepository:(NSString *)theRepo {    
    [super initWithNibName:@"IssueDetail" bundle:nil];
	self.issue = theIssue;
    self.repository = theRepo;
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
	[contentView release];
	[issue release];
	[dateLabel release];
	[titleLabel release];
    [voteLabel release];
	[iconView release];
    [super dealloc];
}

@end
