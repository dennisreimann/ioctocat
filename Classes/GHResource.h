#import <Foundation/Foundation.h>


typedef enum {
	GHResourceStatusNotLoaded,
	GHResourceStatusLoading,
	GHResourceStatusLoaded
} GHResourceStatus;


@interface GHResource : NSObject {
  @private
	GHResourceStatus status;
	NSError *error;
}

@property (nonatomic, retain) NSError *error;
@property (nonatomic, readwrite) GHResourceStatus status;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, readonly) BOOL isLoading;

@end
