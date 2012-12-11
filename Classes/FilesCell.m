#import "FilesCell.h"


@implementation FilesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.opaque = YES;
	}
	return self;
}

- (void)setFiles:(NSArray *)theFiles andDescription:(NSString *)theDescription {
	self.files = theFiles;
	self.description = theDescription;
	NSString *imageName = [NSString stringWithFormat:@"file_%@.png", self.description];
	self.imageView.image = [UIImage imageNamed:imageName];
	self.textLabel.text = [NSString stringWithFormat:@"%d %@", self.files.count, self.description];
	if (self.files.count == 0) {
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
}

@end