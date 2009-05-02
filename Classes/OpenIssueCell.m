#import "OpenIssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"


@implementation OpenIssueCell

@synthesize issue;


//NSString *issueId;
//NSString *user;    
//NSString *title;
//NSString *body;
//NSString *state;
//NSString *type;
//NSInteger *votes;    
//NSInteger *num;
//NSDate    *created;
//NSDate    *updated;    
//
//IBOutlet UILabel *dateLabel;
//IBOutlet UILabel *titleLabel;
//IBOutlet UILabel *detailLabel;
//IBOutlet UILabel *votesLabel;    
//IBOutlet UIImageView *iconView;

- (void)setIssue:(GHIssue *)anIssue {
	[issue release];
	issue = [anIssue retain];
	titleLabel.text = issue.title;
    detailLabel.text = issue.body;
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:issue.created];
	[dateFormatter release];
    
    
    
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
//	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//	dateLabel.text = [dateFormatter stringFromDate:entry.date];
//	[dateFormatter release];
//	// Icon
	NSString *icon = [NSString stringWithFormat:@"%@.png", @"issues_opened"];
	iconView.image = [UIImage imageNamed:icon];
//	// Gravatar
//	gravatarView.image = entry.user.gravatar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
//	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
//		gravatarView.image = entry.user.gravatar;
//	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[issue release];
	[dateLabel release];
	[titleLabel release];
	[detailLabel release];    
    [votesLabel release];        
    [iconView release];        
    [super dealloc];
}

@end
