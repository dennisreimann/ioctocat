#import "IOCCollectionController.h"

@class GHRepositories;

@interface IOCRepositoriesController : IOCCollectionController
- (id)initWithRepositories:(GHRepositories *)repos;
@end