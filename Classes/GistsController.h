#import <UIKit/UIKit.h>


@class GHGists;

@interface GistsController : UITableViewController
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingGistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noGistsCell;

+ (id)controllerWithGists:(GHGists *)theGists;
- (id)initWithGists:(GHGists *)theGists;
- (IBAction)refresh:(id)sender;
@end