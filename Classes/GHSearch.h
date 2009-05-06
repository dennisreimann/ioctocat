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

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, readonly) NSString *searchTerm;

- (id)initWithURLFormat:(NSString *)theFormat andParserDelegateClass:(Class)theDelegateClass;
- (void)loadResultsForSearchTerm:(NSString *)theSearchTerm;
- (void)loadedResults:(id)theResult;

@end


