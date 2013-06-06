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

- (void)setFiles:(GHFiles *)files description:(NSString *)description {
	self.files = files;
	self.description = description;
	NSString *imageName = [NSString stringWithFormat:@"file_%@.png", self.description];
    NSString *localizedDescription = NSLocalizedString(self.description, nil);
	self.imageView.image = [UIImage imageNamed:imageName];
	self.textLabel.text = [NSString stringWithFormat:@"%d %@", self.files.count, localizedDescription];
	if (self.files.isEmpty) {
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
}

@end