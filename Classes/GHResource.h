#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"


typedef enum {
	GHResourceStatusNotProcessed = 0,
	GHResourceStatusProcessing = 1,
	GHResourceStatusProcessed = 2
} GHResourceStatus;

@interface GHResource : NSObject {
	GHResourceStatus loadingStatus;
	GHResourceStatus savingStatus;
	NSMutableSet *delegates;
	NSURL *resourceURL;
	NSError *error;
	NSDictionary *data;
}

@property(nonatomic,assign)GHResourceStatus loadingStatus;
@property(nonatomic,assign)GHResourceStatus savingStatus;
@property(nonatomic,retain)NSURL *resourceURL;
@property(nonatomic,retain)NSError *error;
@property(nonatomic,retain)NSDictionary *data;

// Convenience Accessors
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;
+ (id)resourceWithURL:(NSURL *)theURL;
- (id)initWithURL:(NSURL *)theURL;
- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)loadData;
- (void)saveValues:(NSDictionary *)theValues withURL:(NSURL *)theURL andMethod:(NSString *)theMethod;
- (void)parseData:(NSData *)theData;
- (void)parsingFinished:(id)theResult;
- (void)setValuesFromDict:(NSDictionary *)theDict;

@end


@protocol GHResourceDelegate;

@protocol GHResourceDelegate <NSObject>
@optional
- (void)resource:(GHResource *)theResource finished:(NSDictionary *)resultDict;
- (void)resource:(GHResource *)theResource failed:(NSError *)theError;
@end
