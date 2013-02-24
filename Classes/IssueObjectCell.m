#import "IssueObjectCell.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@interface IssueObjectCell ()
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,assign)BOOL displayRepo;
@property(nonatomic,strong)UILabel *repoLabel;
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
    self.repoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.repoLabel.backgroundColor = [UIColor clearColor];
    self.repoLabel.font = [UIFont systemFontOfSize:13];
    self.repoLabel.textColor = [UIColor grayColor];
    self.repoLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:self.repoLabel];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	self.displayRepo = YES;
	return self;
}

- (void)setIssueObject:(id)issueObject {
	_issueObject = issueObject;
	NSString *objectType = [_issueObject isKindOfClass:GHPullRequest.class] ? @"pull_request" : @"issue";
	NSString *imageName = [NSString stringWithFormat:@"%@_%@.png", objectType, self.object.state];
    NSString *userInfo = self.object.user ? [NSString stringWithFormat:@"by %@ - ", self.object.user.login] : @"";
	self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = self.object.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"#%d %@%@", self.object.num, userInfo, [_displayRepo ? self.object.updated : self.object.created prettyDate]];
    self.repoLabel.text = _displayRepo ? self.object.repository.repoId : @"";
}

- (void)hideRepo {
	self.displayRepo = NO;
    [self.repoLabel removeFromSuperview];
}

- (GHIssue *)object {
	return self.issueObject;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.displayRepo) {
        CGRect frame;
        frame = self.textLabel.frame;
        frame.origin.y = 4.0f;
        self.textLabel.frame = frame;
        frame = self.detailTextLabel.frame;
        frame.origin.y = 23.0f;
        self.detailTextLabel.frame = frame;
        frame.origin.y = 39.0f;
        frame.size.width = self.contentView.bounds.size.width - frame.origin.x;
        self.repoLabel.frame = frame;
    }
}

@end