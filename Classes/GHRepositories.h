#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHRepositories : GHResource

@property(nonatomic,strong)NSMutableArray *repositories;

+ (id)repositoriesWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

@end