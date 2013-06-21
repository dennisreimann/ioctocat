#import "IOCIssueObjectCell.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate_IOCExtensions.h"


@interface IOCIssueObjectCell ()
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,assign)BOOL displayRepo;
@property(nonatomic,strong)UILabel *repoLabel;
@end


@implementation IOCIssueObjectCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
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
    NSString *userInfo = self.object.user ? [NSString stringWithFormat:@"by %@ ", self.object.user.login] : @"";
	self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = self.object.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"#%d %@- %@", self.object.number, userInfo, [_displayRepo ? self.object.updatedAt : self.object.createdAt ioc_prettyDate]];
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
        CGRect textFrame = self.textLabel.frame;
        CGRect detailFrame = self.detailTextLabel.frame;
        CGRect repoFrame;
        textFrame.origin.y = 4.0f;
        detailFrame.origin.y = 23.0f;
        repoFrame.origin.x = 36.0f;
        repoFrame.origin.y = 39.0f;
        repoFrame.size.width = self.contentView.bounds.size.width - repoFrame.origin.x;
        repoFrame.size.height = 16.0f;
        self.textLabel.frame = textFrame;
        self.detailTextLabel.frame = detailFrame;
        self.repoLabel.frame = repoFrame;
    }
}

@end