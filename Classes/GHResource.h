#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"


typedef enum {
	GHResourceStatusNotLoaded = 0,
	GHResourceStatusLoading = 1,
	GHResourceStatusLoaded = 2
} GHResourceLoadingStatus;

typedef enum {
	GHResourceStatusNotSaved = 0,
	GHResourceStatusSaving = 1,
	GHResourceStatusSaved = 2
} GHResourceSavingStatus;


@interface GHResource : NSObject {
	GHResourceLoadingStatus loadingStatus;
	GHResourceSavingStatus savingStatus;
	NSError *error;
}

@property (nonatomic, retain) NSError *error;
@property (nonatomic, readwrite) GHResourceLoadingStatus loadingStatus;
@property (nonatomic, readwrite) GHResourceSavingStatus savingStatus;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) BOOL isSaved;
@property (nonatomic, readonly) BOOL isSaving;

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;

@end
