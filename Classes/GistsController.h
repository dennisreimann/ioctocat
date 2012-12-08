#import <UIKit/UIKit.h>


@class GHGists;

@interface GistsController : UITableViewController
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingGistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noGistsCell;

- (id)initWithGists:(GHGists *)theGists;
- (IBAction)refresh:(id)sender;
@end