//
//  ButtonGradientView.h
//
//  Created by Jeff LaMarche on 5/17/10.
//
#import <CoreGraphics/CoreGraphics.h>

@interface GradientButton : UIButton 
{
    // These two arrays define the gradient that will be used
    // when the button is in UIControlStateNormal
    NSArray  *normalGradientColors;     // Colors
    NSArray  *normalGradientLocations;  // Relative locations
    
    // These two arrays define the gradient that will be used
    // when the button is in UIControlStateHighlighted 
    NSArray  *highlightGradientColors;     // Colors
    NSArray  *highlightGradientLocations;  // Relative locations
    
    // This defines the corner radius of the button
    CGFloat         cornerRadius;
    
    // This defines the size and color of the stroke
    CGFloat         strokeWeight;
    UIColor         *strokeColor;
    
@private
    CGGradientRef   normalGradient;
    CGGradientRef   highlightGradient;
}

@property (nonatomic, strong) NSArray *normalGradientColors;
@property (nonatomic, strong) NSArray *normalGradientLocations;
@property (nonatomic, strong) NSArray *highlightGradientColors;
@property (nonatomic, strong) NSArray *highlightGradientLocations;
@property (nonatomic, strong) NSString *identifierTag;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat strokeWeight;
@property (nonatomic, strong) UIColor *strokeColor;

- (void)useAlertStyle;
- (void)useRedDeleteStyle;
- (void)useGithubStyle;
- (void)useDarkGithubStyle;
- (void)useWhiteStyle;
- (void)useBlackStyle;
- (void)useWhiteActionSheetStyle;
- (void)useBlackActionSheetStyle;
- (void)useSimpleOrangeStyle;
- (void)useGreenConfirmStyle;

@end
