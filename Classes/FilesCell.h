#import <UIKit/UIKit.h>


@interface FilesCell : UITableViewCell {
	NSArray *files;
	NSString *description;
}

@property(nonatomic,retain)NSArray *files;
@property(nonatomic,copy)NSString *description;

- (void)setFiles:(NSArray *)theFiles andDescription:(NSString *)theDescription;

@end