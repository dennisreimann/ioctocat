#import "IOCResourceStatusCell.h"
#import "GHResource.h"


@interface IOCResourceStatusCell ()
@property(nonatomic,strong)GHResource *resource;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,strong)UIActivityIndicatorView *spinner;
@end

@implementation IOCResourceStatusCell

static NSString *const ResourceStatusKeyPath = @"resourceStatus";

- (id)initWithResource:(GHResource *)resource name:(NSString *)name {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResourceStatusCell"];
	if (self) {
		self.textLabel.textColor = [UIColor grayColor];
		self.textLabel.font = [UIFont systemFontOfSize:15];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		self.opaque = YES;
		_name = name;
		_resource = resource;
		_loadingText = [NSString stringWithFormat:@"Loading %@", self.name];
		_failedText = [NSString stringWithFormat:@"Loading %@ failed", self.name];
		_emptyText = [NSString stringWithFormat:@"No %@", self.name];
		[_resource addObserver:self forKeyPath:ResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self setupWithCurrentStatus];
	}
	return self;
}

- (void)dealloc {
	[_resource removeObserver:self forKeyPath:ResourceStatusKeyPath];
}

- (void)setLoadingText:(NSString *)text {
	_loadingText = text;
	[self setupWithCurrentStatus];
}

- (void)setFailedText:(NSString *)text {
	_failedText = text;
	[self setupWithCurrentStatus];
}

- (void)setEmptyText:(NSString *)text {
	_emptyText = text;
	[self setupWithCurrentStatus];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:ResourceStatusKeyPath]) {
		[self setupWithCurrentStatus];
	}
}

- (UIActivityIndicatorView *)spinner {
	if (!_spinner) {
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_spinner.hidesWhenStopped = YES;
		[self.imageView addSubview:_spinner];
	}
	return _spinner;
}

- (void)setupWithCurrentStatus {
	NSTextAlignment align = NSTextAlignmentLeft;
	NSString *text = nil;
	UIImage *image = nil;
	if (self.resource.isLoading) {
		[self.spinner startAnimating];
		text = self.loadingText;
		image = [UIImage imageNamed:@"UIActivityIndicatorPlaceholder.png"];
	} else if (self.resource.isFailed) {
		text = self.failedText;
		image = [UIImage imageNamed:@"LoadingError.png"];
	} else if (self.resource.isEmpty) {
		text = self.emptyText;
		align = NSTextAlignmentCenter;
	}
	if (self.spinner && !self.resource.isLoading) {
		[self.spinner stopAnimating];
	}
	self.textLabel.textAlignment = align;
	self.textLabel.text = text;
	self.imageView.image = image;
}

@end