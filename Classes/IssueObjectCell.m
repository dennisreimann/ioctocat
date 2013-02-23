#import "IssueObjectCell.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@interface IssueObjectCell ()
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,assign)BOOL displayRepo;
@end


@implementation IssueObjectCell

+ (id)cell {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kIssueObjectCellIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.textLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	self.displayRepo = YES;
	return self;
}

- (void)setIssueObject:(id)issueObject {
	_issueObject = issueObject;
	NSString *objectType = [_issueObject isKindOfClass:GHPullRequest.class] ? @"pull_request" : @"issue";
	NSString *imageName = [NSString stringWithFormat:@"%@_%@.png", objectType, self.object.state];
	self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = self.object.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"#%d by %@ - %@", self.object.num, self.object.user.login, _displayRepo ? [NSString stringWithFormat:@"%@\n%@", [self.object.updated prettyDate], self.object.repository.repoId] : [self.object.created prettyDate]];
}

- (void)hideRepo {
	self.displayRepo = NO;
    self.detailTextLabel.numberOfLines = 2;
}

- (GHIssue *)object {
	return self.issueObject;
}

@end