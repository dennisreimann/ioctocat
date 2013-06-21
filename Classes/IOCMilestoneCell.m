#import "IOCMilestoneCell.h"
#import "GHMilestone.h"
#import "NSDate_IOCExtensions.h"
#import "NSString_IOCExtensions.h"


@interface IOCMilestoneCell ()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UIProgressView *progressView;
@end


@implementation IOCMilestoneCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.opaque = YES;
    }
	return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, self.bounds.size.width - 60.0f, 19.0f)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 26.0f, self.bounds.size.width - 60.0f, 19.0f)];
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _detailLabel.font = [UIFont systemFontOfSize:13.0f];
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.numberOfLines = 0;
        [self addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressView.frame = CGRectMake(10.0f, 80.0f, self.bounds.size.width - 60.0f, 9.0f);
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter = nil;
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

- (void)setMilestone:(GHMilestone *)milestone {
	_milestone = milestone;
    self.titleLabel.text = milestone.title;
    // due
    NSString *due = @"No due date";
    if (milestone.dueOn) {
        NSString *formattedDate = [self.dateFormatter stringFromDate:milestone.dueOn];
        NSString *prettyDate = [milestone.dueOn ioc_prettyDate];
        due = [NSString stringWithFormat:@"Due on %@ (%@)", formattedDate, prettyDate];
    }
    // detail
    NSString *body = [self.milestone.bodyForDisplay stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *detail = [NSString stringWithFormat:@"%@\n\n%@\nIssues: %d open, %d closed - %d%% done", body, due, milestone.openIssueCount, milestone.closedIssueCount, milestone.percentDone];
    self.detailLabel.text = [detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // progress
    self.progressView.progress = milestone.percentDone / 100.0f;
    [self adjustContentLayout];
}

#pragma mark Actions

- (void)editMilestone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editResource:)]) {
        [self.delegate editResource:self.milestone];
    }
}

- (void)deleteMilestone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteResource:)]) {
        [self.delegate deleteResource:self.milestone];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(editMilestone:) || action == @selector(deleteMilestone:)) {
        return [self.delegate canManageResource:self.milestone];
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

#pragma mark Layout

- (void)layoutSubviews {
	[super layoutSubviews];
    [self adjustContentLayout];
}

- (void)adjustContentLayout {
    // title
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.y = 10.0f;
    self.titleLabel.frame = titleFrame;
    // detail
    CGRect detailFrame = self.detailLabel.frame;
    CGSize constraint = CGSizeMake(detailFrame.size.width, CGFLOAT_MAX);
    CGSize size = [self.detailLabel sizeThatFits:constraint];
    detailFrame.size.height = size.height;
    detailFrame.origin.y = titleFrame.origin.y + titleFrame.size.height + 3.0f;
    self.detailLabel.frame = detailFrame;
    // progress
    CGRect progressFrame = self.progressView.frame;
    progressFrame.origin.y = detailFrame.origin.y + detailFrame.size.height + 11.0f;
    self.progressView.frame = progressFrame;
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
    CGRect progressFrame = self.progressView.frame;
    CGFloat height = progressFrame.origin.y + progressFrame.size.height + 13.0f;
	return height;
}

@end
