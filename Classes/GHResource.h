#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"


typedef enum {
	GHResourceStatusNotLoaded = 0,
	GHResourceStatusLoading = 1,
	GHResourceStatusLoaded = 2
} GHResourceStatus;


@interface GHResource : NSObject {
	GHResourceStatus status;
	NSError *error;
}

@property (nonatomic, retain) NSError *error;
@property (nonatomic, readwrite) GHResourceStatus status;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, readonly) BOOL isLoading;

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;

@end
