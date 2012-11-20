#import <UIKit/UIKit.h>


@interface DiffFilesController : UITableViewController {
	NSArray *files;
}

- (id)initWithFiles:(NSArray *)theFiles;

@end