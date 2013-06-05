#import "IOCCollectionController.h"

@class GHGists;

@interface IOCGistsController : IOCCollectionController
@property(nonatomic,assign)BOOL *hideUser;

- (id)initWithGists:(GHGists *)gists;
@end