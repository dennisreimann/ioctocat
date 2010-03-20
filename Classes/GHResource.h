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

@protocol GHResourceDelegate;

@interface GHResource : NSObject {
	id<GHResourceDelegate> delegate;
	GHResourceLoadingStatus loadingStatus;
	GHResourceSavingStatus savingStatus;
	NSError *error;
	NSURL *resourceURL;
}

@property(nonatomic,retain)NSError *error;
@property(nonatomic,retain)NSURL *resourceURL;
@property(nonatomic,assign)id<GHResourceDelegate> delegate;
@property(nonatomic,readwrite)GHResourceLoadingStatus loadingStatus;
@property(nonatomic,readwrite)GHResourceSavingStatus savingStatus;
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;
+ (id)resourceWithURL:(NSURL *)theURL;
- (id)initWithURL:(NSURL *)theURL;
- (void)loadResource;

@end


@protocol GHResourceDelegate <NSObject>

@optional
- (void)resource:(GHResource *)theResource didFinishWithResult:(NSDictionary *)resultDict;
- (void)resource:(GHResource *)theResource didFailWithError:(NSError *)theError;

@end