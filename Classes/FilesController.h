#import <UIKit/UIKit.h>


@interface FilesController : UITableViewController {
	NSArray *files;
}

- (id)initWithFiles:(NSArray *)theFiles;

@end
