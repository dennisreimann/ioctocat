#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHSearch : GHResource

@property(nonatomic,strong)NSArray *results;
@property(nonatomic,strong)NSString *searchTerm;
@property(nonatomic,strong)NSString *urlFormat;

+ (id)searchWithURLFormat:(NSString *)theFormat;
- (id)initWithURLFormat:(NSString *)theFormat;

@end