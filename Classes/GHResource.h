#import <Foundation/Foundation.h>


typedef enum {
	GHResourceStatusNotProcessed = 0,
	GHResourceStatusProcessing = 1,
	GHResourceStatusProcessed = 2
} GHResourceStatus;


@class GHAccount;

@interface GHResource : NSObject

@property(nonatomic,assign)GHResourceStatus loadingStatus;
@property(nonatomic,assign)GHResourceStatus savingStatus;
@property(nonatomic,strong)NSString *resourcePath;
@property(nonatomic,strong)NSError *error;
@property(nonatomic,strong)NSDictionary *data;
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

- (id)initWithPath:(NSString *)thePath;
- (GHAccount *)currentAccount;
- (void)loadData;
- (void)saveValues:(NSDictionary *)theValues withPath:(NSString *)thePath andMethod:(NSString *)theMethod useResult:(void (^)(id theResponse))useResult;
- (void)setValues:(id)theResponse;
- (NSString *)resourceContentType;

@end