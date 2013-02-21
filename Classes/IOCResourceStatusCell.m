#import "IOCResourceStatusCell.h"
#import "GHResource.h"


@interface IOCResourceStatusCell ()
@property(nonatomic,weak)GHResource *resource;
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
		self.name = name;
		self.resource = resource;
		[self.resource addObserver:self forKeyPath:ResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self handleResourceStatusChange];
	}
	return self;
}

- (void)dealloc {
	[self.resource removeObserver:self forKeyPath:ResourceStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:ResourceStatusKeyPath]) {
		[self handleResourceStatusChange];
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

- (void)handleResourceStatusChange {
	NSTextAlignment align = NSTextAlignmentLeft;
	NSString *text = nil;
	UIImage *image = nil;
	if (self.resource.isLoading) {
		[self.spinner startAnimating];
		text = [NSString stringWithFormat:@"Loading %@", self.name];
		image = [UIImage imageNamed:@"UIActivityIndicatorPlaceholder.png"];
	} else if (self.resource.isFailed) {
		text = [NSString stringWithFormat:@"Loading %@ failed", self.name];
		image = [UIImage imageNamed:@"LoadingError.png"];
	} else if (self.resource.isEmpty) {
		text = [NSString stringWithFormat:@"No %@", self.name];
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