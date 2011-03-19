#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHSearch : GHResource {
	NSArray *results;
  @private
	NSString *urlFormat;
	NSString *searchTerm;
}

@property(nonatomic,retain)NSArray *results;
@property(nonatomic,retain)NSString *searchTerm;

+ (id)searchWithURLFormat:(NSString *)theFormat;
- (id)initWithURLFormat:(NSString *)theFormat;

@end


