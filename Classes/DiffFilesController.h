#import <UIKit/UIKit.h>


@interface DiffFilesController : UITableViewController

+ (id)controllerWithFiles:(NSArray *)theFiles;
- (id)initWithFiles:(NSArray *)theFiles;

@end