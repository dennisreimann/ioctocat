@class GHBlob;

@interface IOCBlobsController : UIViewController
- (id)initWithBlobs:(NSArray *)blobs currentIndex:(NSUInteger)idx;
- (id)initWithBlob:(GHBlob *)blob;
@end