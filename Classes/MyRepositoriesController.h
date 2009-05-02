#import <UIKit/UIKit.h>


@interface MyRepositoriesController : UITableViewController {
  @private
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
	IBOutlet UITableViewCell *noPrivateReposCell;
	NSMutableArray *publicRepositories;
	NSMutableArray *privateRepositories;
	BOOL isLoaded;
}

@property (nonatomic, retain) NSMutableArray *publicRepositories;
@property (nonatomic, retain) NSMutableArray *privateRepositories;

- (void)loadedRepositories:(id)theResult;

@end
