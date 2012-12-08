#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHRepositories : GHResource

@property(nonatomic,strong)NSMutableArray *repositories;

- (id)initWithPath:(NSString *)thePath;

@end