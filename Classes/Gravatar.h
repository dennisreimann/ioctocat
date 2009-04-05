#import <UIKit/UIKit.h>


@interface Gravatar : NSObject {
	UIImage *image;
	BOOL isLoaded;
	BOOL isLoading;
  @private
	NSMutableData *responseData;
	NSString *email;
	NSUInteger size;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, readwrite) BOOL isLoading;

- (id)initWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize;
- (void)loadImage;

@end

