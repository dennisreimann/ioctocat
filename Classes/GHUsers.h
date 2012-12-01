#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHUsers : GHResource

@property(nonatomic,strong)NSMutableArray *users;

+ (id)usersWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;

@end