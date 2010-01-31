#import "FilesCell.h"


@implementation FilesCell

@synthesize files;
@synthesize description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.opaque = YES;
	return self;
}

- (void)dealloc {
    [files release], files = nil;
    [description release], description = nil;
    [super dealloc];
}

- (void)setFiles:(NSArray *)theFiles andDescription:(NSString *)theDescription {
	self.files = theFiles;
	self.description = theDescription;
	NSString *imageName = [NSString stringWithFormat:@"file_%@.png", description];
	self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = [NSString stringWithFormat:@"%d %@", [files count], description];
	if ([files count] == 0) {
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
}

@end
