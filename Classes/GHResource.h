#import <Foundation/Foundation.h>


typedef enum {
	GHResourceStatusNotProcessed = 0,
	GHResourceStatusProcessing = 1,
	GHResourceStatusProcessed = 2
} GHResourceStatus;

@interface GHResource : NSObject {
	GHResourceStatus loadingStatus;
	GHResourceStatus savingStatus;
	NSMutableSet *delegates;
	NSString *resourcePath;
	NSError *error;
	NSDictionary *data;
}

@property(nonatomic,assign)GHResourceStatus loadingStatus;
@property(nonatomic,assign)GHResourceStatus savingStatus;
@property(nonatomic,retain)NSString *resourcePath;
@property(nonatomic,retain)NSError *error;
@property(nonatomic,retain)NSDictionary *data;

// Convenience Accessors
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

+ (id)resourceWithPath:(NSString *)thePath;
- (id)initWithPath:(NSString *)thePath;
- (GHAccount *)currentAccount;
- (void)loadData;
- (void)saveValues:(NSDictionary *)theValues withPath:(NSString *)thePath andMethod:(NSString *)theMethod useResult:(void (^)(id theResponse))useResult;
- (void)setValues:(id)theResponse;
- (void)setValuesFromDict:(NSDictionary *)theDict;
- (NSString *)resourceContentType;

@end