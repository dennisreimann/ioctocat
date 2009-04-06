#import <UIKit/UIKit.h>


@interface Gravatar : NSObject {
	UIImage *image;
  @private
	NSString *email;
	NSUInteger size;
}

@property (nonatomic, retain) UIImage *image;

- (id)initWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize;
+ (id)gravatarWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize;

@end

