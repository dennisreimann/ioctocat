#import "IOCFilesCell.h"
#import "GHFiles.h"


@implementation IOCFilesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.opaque = YES;
	}
	return self;
}

- (void)setFiles:(GHFiles *)files andDescription:(NSString *)description {
	self.files = files;
	self.description = description;
	NSString *imageName = [NSString stringWithFormat:@"file_%@.png", self.description];
	self.imageView.image = [UIImage imageNamed:imageName];
	self.textLabel.text = [NSString stringWithFormat:@"%d %@", self.files.count, self.description];
	if (self.files.isEmpty) {
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
}

@end