#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHSearch : GHResource
@property(nonatomic,strong)NSString *searchTerm;
@property(nonatomic,strong)NSArray *searchResults;
@property(nonatomic,readonly)BOOL isEmpty;

- (id)initWithURLFormat:(NSString *)format;
@end