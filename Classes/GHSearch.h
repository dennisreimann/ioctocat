#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHResource.h"


@interface GHSearch : GHResource {
	NSArray *results;
  @private
	NSString *urlFormat;
	NSString *searchTerm;
	GHResourcesParserDelegate *parserDelegate;
}

@property(nonatomic,retain)NSArray *results;
@property(nonatomic,retain)NSString *searchTerm;

- (id)initWithURLFormat:(NSString *)theFormat andParserDelegateClass:(Class)theDelegateClass;

@end


