#import <Foundation/Foundation.h>


@interface GHFeed : NSObject {
	NSURL *url;
	NSMutableArray *entries;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableArray *entries;

- (id)initWithURL:(NSURL *)theURL;

@end
