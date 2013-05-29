#import "GHCollection.h"


@interface GHSearch : GHCollection
@property(nonatomic,strong)NSString *searchTerm;

- (id)initWithURLFormat:(NSString *)format;
@end