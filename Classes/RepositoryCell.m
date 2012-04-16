#import "RepositoryCell.h"

#define REPOSTAT_ICON [UIImage imageNamed:@"repostat"]
#define REPOSTAT_ICON_Y(index) (index * -25 -3)

@interface DetailView : UIView
@property (nonatomic, assign) NSInteger forkCount;
@property (nonatomic, assign) NSInteger watcherCount;
@end

@implementation DetailView
@synthesize forkCount, watcherCount;

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"forkCount"];
    [self removeObserver:self forKeyPath:@"watcherCount"];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self
               forKeyPath:@"forkCount"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"watcherCount"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSString *watcherText = [NSString stringWithFormat:@"%d", watcherCount];
    NSString *forkText = [NSString stringWithFormat:@"%d", forkCount];

    UIFont *font = [UIFont systemFontOfSize:13];

    [[UIColor grayColor] set];

    [REPOSTAT_ICON drawAtPoint:CGPointMake(0, REPOSTAT_ICON_Y(0))];
    [watcherText drawAtPoint:CGPointMake(24, 0) withFont:font];

    [REPOSTAT_ICON drawAtPoint:CGPointMake(60, REPOSTAT_ICON_Y(2))];
    [forkText drawAtPoint:CGPointMake(84, 0) withFont:font];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end


@interface RepositoryCell ()
@property (nonatomic, retain) DetailView *detailView;
@end

@implementation RepositoryCell

@synthesize repository, detailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:16.0f];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;

    detailView = nil;
    if (style == UITableViewCellStyleSubtitle) {
        detailView = [[DetailView alloc] initWithFrame:CGRectZero];
        detailView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:detailView];
    }
	return self;
}

- (void)dealloc {
    [detailView release];
	[repository release];
    [super dealloc];
}

- (void)setRepository:(GHRepository *)theRepository {
	[theRepository retain];
	[repository release];
	repository = theRepository;
	self.imageView.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
    
    self.detailTextLabel.text = [NSString stringWithFormat:@"W:%d F:%d", repository.watcherCount, repository.forkCount];

    self.detailView.forkCount = repository.forkCount;
    self.detailView.watcherCount = repository.watcherCount;
}

- (void)hideOwner {
	self.textLabel.text = repository.name;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.detailTextLabel.hidden = YES;
    detailView.frame = (CGRect){self.detailTextLabel.frame.origin, self.contentView.frame.size.width - 20 - self.imageView.frame.size.width, self.detailTextLabel.frame.size.height};
}

@end
