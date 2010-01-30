#import <UIKit/UIKit.h>


@interface FilesController : UITableViewController {
	NSArray *files;
}

@property(nonatomic,retain)NSArray *files;

- (id)initWithFiles:(NSArray *)theFiles;

@end
