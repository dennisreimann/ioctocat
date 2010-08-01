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
	GHResourceLoadingStatus loadingStatus;
	GHResourceSavingStatus savingStatus;
	NSMutableSet *delegates;
	NSURL *resourceURL;
	NSError *error;
	NSDictionary *result;
}

@property(nonatomic,assign)GHResourceLoadingStatus loadingStatus;
@property(nonatomic,assign)GHResourceSavingStatus savingStatus;
@property(nonatomic,retain)NSURL *resourceURL;
@property(nonatomic,retain)NSError *error;
@property(nonatomic,retain)NSDictionary *result;

// Convenience Accessors
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;
- (id)initWithURL:(NSURL *)theURL;
- (void)loadData;
- (void)saveValues:(NSDictionary *)theValues withURL:(NSURL *)theURL;

@end


@protocol GHResourceDelegate <NSObject>
@optional
- (void)resource:(GHResource *)theResource didFinishWithResult:(NSDictionary *)resultDict;
- (void)resource:(GHResource *)theResource didFailWithError:(NSError *)theError;
@end
