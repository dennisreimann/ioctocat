#import "IOCTableViewSectionHeader.h"


@class GradientButton;

@interface IOCNotificationsSectionHeader : IOCTableViewSectionHeader
@property(nonatomic,readonly)GradientButton *titleButton;
@property(nonatomic,readonly)GradientButton *markReadButton;
@end