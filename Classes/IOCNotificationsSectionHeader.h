#import "IOCTableViewSectionHeader.h"


@class GradientButton;

@interface IOCNotificationsSectionHeader : IOCTableViewSectionHeader
@property(nonatomic,readonly)UIButton *titleButton;
@property(nonatomic,readonly)GradientButton *markReadButton;
@end