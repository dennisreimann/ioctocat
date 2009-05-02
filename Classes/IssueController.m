#import "IssueController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "GHUser.h"
#import "GHRepository.h"


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
    [contentView setText:issue.body];
	// Date
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:issue.created];
	[dateFormatter release];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
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
