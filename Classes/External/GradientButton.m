//
//  ButtonGradientView.m
//
//  Created by Jeff LaMarche on 5/17/10.
//

#import "GradientButton.h"

@interface GradientButton()
@property (nonatomic, readonly) CGGradientRef normalGradient;
@property (nonatomic, readonly) CGGradientRef highlightGradient;
- (void)hesitateUpdate; // Used to catch and fix problem where quick taps don't get updated back to normal state
@end


@implementation GradientButton

@synthesize normalGradientColors;
@synthesize normalGradientLocations;
@synthesize highlightGradientColors;
@synthesize highlightGradientLocations;
@synthesize cornerRadius;
@synthesize strokeWeight, strokeColor;
@synthesize normalGradient, highlightGradient;

#pragma mark -

- (CGGradientRef)normalGradient {
    if (normalGradient == NULL)
    {
        int locCount = [normalGradientLocations count];
        CGFloat locations[locCount];
        for (int i = 0; i < [normalGradientLocations count]; i++)
        {
            NSNumber *location = normalGradientLocations[i];
            locations[i] = [location floatValue];
        }
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)normalGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return normalGradient;
}

- (CGGradientRef)highlightGradient {
    if (highlightGradient == NULL)
    {
        CGFloat locations[[highlightGradientLocations count]];
        for (int i = 0; i < [highlightGradientLocations count]; i++)
        {
            NSNumber *location = highlightGradientLocations[i];
            locations[i] = [location floatValue];
        }
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        highlightGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)highlightGradientColors, locations);
        CGColorSpaceRelease(space);
    }
    return highlightGradient;
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) 
    {
		[self setOpaque:NO];
        self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

#pragma mark Appearances

- (void)useAlertStyle {
    // Oddly enough, if I create the color array using arrayWithObjects:, it
    // doesn't work - the gradient comes back NULL
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
    UIColor *color = [UIColor colorWithRed:0.283 green:0.32 blue:0.414 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.82 green:0.834 blue:0.87 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.186 green:0.223 blue:0.326 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = @[@0.0f,
                                    @1.0f,
                                    @0.483f];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:4];
    color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.656 green:0.683 blue:0.713 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.137 green:0.155 blue:0.208 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.237 green:0.257 blue:0.305 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = @[@0.0f,
                                       @1.0f,
                                       @0.51f,
                                       @0.654f];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
}

- (void)useRedDeleteStyle {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    UIColor *color = [UIColor colorWithRed:0.525 green:0.055 blue:0.000 alpha:1.000];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.780 green:0.161 blue:0.196 alpha:1.000];
    [colors addObject:(id)[color CGColor]];
    
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, @0.0f, nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:2];
    color = [UIColor colorWithRed:0.574 green:0.237 blue:0.209 alpha:1.000];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.647 green:0.265 blue:0.231 alpha:1.000];
    [colors addObject:(id)[color CGColor]];
    
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, @0.1f, nil];
    
    self.strokeColor = [UIColor colorWithRed:0.745 green:0.359 blue:0.326 alpha:1.000];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)useGithubStyle {
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
	UIColor *color = [UIColor colorWithWhite:0.9 alpha:1.000];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithWhite:0.97 alpha:1.000];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.147 green:0.362 blue:0.670 alpha:1.000];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.278 green:0.521 blue:0.852 alpha:1.000];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, @0.601f, nil];
    self.strokeColor = [UIColor colorWithWhite:0.853 alpha:1.000];
    
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)useDarkGithubStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
	UIColor *color = [UIColor colorWithWhite:0.8 alpha:1.000];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithWhite:0.87 alpha:1.000];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, nil];

    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.147 green:0.362 blue:0.670 alpha:1.000];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.278 green:0.521 blue:0.852 alpha:1.000];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:@0.0f, @1.0f, @0.601f, nil];
    self.strokeColor = [UIColor colorWithWhite:0.78 alpha:1.000];
    self.strokeWeight = 1.f;
    
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)useWhiteStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
	UIColor *color = [UIColor colorWithRed:0.864 green:0.864 blue:0.864 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.995 green:0.995 blue:0.995 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.956 green:0.956 blue:0.955 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    @0.601f,
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:3];
	color = [UIColor colorWithRed:0.692 green:0.692 blue:0.691 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.995 green:0.995 blue:0.995 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.601f,
                                       nil];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
}
- (void)useBlackStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:4];
	UIColor *color = [UIColor colorWithRed:0.154 green:0.154 blue:0.154 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.307 green:0.307 blue:0.307 alpha:1.0];
	[colors addObject:(id)[color CGColor]];;
	color = [UIColor colorWithRed:0.166 green:0.166 blue:0.166 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.118 green:0.118 blue:0.118 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    @0.548f,
                                    @0.462f,
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:4];
	color = [UIColor colorWithRed:0.199 green:0.199 blue:0.199 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.04 green:0.04 blue:0.04 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.074 green:0.074 blue:0.074 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.112 green:0.112 blue:0.112 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.548f,
                                       @0.462f,
                                       nil];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (void)useWhiteActionSheetStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
	UIColor *color = [UIColor colorWithRed:0.864 green:0.864 blue:0.864 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.995 green:0.995 blue:0.995 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.956 green:0.956 blue:0.955 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    @0.601f,
                                    nil];
    
	NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:7];
	color = [UIColor colorWithRed:0.033 green:0.251 blue:0.673 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.66 green:0.701 blue:0.88 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.222 green:0.308 blue:0.709 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.145 green:0.231 blue:0.683 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.0 green:0.124 blue:0.621 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.011 green:0.181 blue:0.647 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.311 green:0.383 blue:0.748 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.957f,
                                       @0.574f,
                                       @0.541f,
                                       @0.185f,
                                       @0.812f,
                                       nil];
    
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
- (void)useBlackActionSheetStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:4];
	UIColor *color = [UIColor colorWithRed:0.154 green:0.154 blue:0.154 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.307 green:0.307 blue:0.307 alpha:1.0];
	[colors addObject:(id)[color CGColor]];;
	color = [UIColor colorWithRed:0.166 green:0.166 blue:0.166 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.118 green:0.118 blue:0.118 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    @0.548f,
                                    @0.462f,
                                    nil];
    
	NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:7];
	color = [UIColor colorWithRed:0.033 green:0.251 blue:0.673 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.66 green:0.701 blue:0.88 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.222 green:0.308 blue:0.709 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.145 green:0.231 blue:0.683 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.0 green:0.124 blue:0.621 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.011 green:0.181 blue:0.647 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.311 green:0.383 blue:0.748 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.957f,
                                       @0.574f,
                                       @0.541f,
                                       @0.185f,
                                       @0.812f,
                                       nil];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
- (void)useSimpleOrangeStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
	UIColor *color = [UIColor colorWithRed:0.935 green:0.403 blue:0.02 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.97 green:0.582 blue:0.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:3];
	color = [UIColor colorWithRed:0.914 green:0.309 blue:0.0 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.935 green:0.4 blue:0.0 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
	color = [UIColor colorWithRed:0.946 green:0.441 blue:0.01 alpha:1.0];
	[colors2 addObject:(id)[color CGColor]];
    self.highlightGradientColors = colors2;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.498f,
                                       nil];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (void)useGreenConfirmStyle
{
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:5];
    UIColor *color = [UIColor colorWithRed:0.15 green:0.667 blue:0.152 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.566 green:0.841 blue:0.566 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.341 green:0.75 blue:0.345 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.0 green:0.592 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.0 green:0.592 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
    self.normalGradientColors = colors;
    self.normalGradientLocations = [NSMutableArray arrayWithObjects:
                                    @0.0f,
                                    @1.0f,
                                    @0.582f,
                                    @0.418f,
                                    @0.346f,
                                    nil];
    
    NSMutableArray *colors2 = [NSMutableArray arrayWithCapacity:5];
    color = [UIColor colorWithRed:0.009 green:0.467 blue:0.005 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.562 green:0.754 blue:0.562 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.212 green:0.543 blue:0.212 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.153 green:0.5 blue:0.152 alpha:1.0];
    [colors2 addObject:(id)[color CGColor]];
    color = [UIColor colorWithRed:0.004 green:0.388 blue:0.0 alpha:1.0];
    [colors addObject:(id)[color CGColor]];
	
    self.highlightGradientColors = colors;
    self.highlightGradientLocations = [NSMutableArray arrayWithObjects:
                                       @0.0f,
                                       @1.0f,
                                       @0.715f,
                                       @0.513f,
                                       @0.445f,
                                       nil];
    
    self.strokeColor = [UIColor clearColor];
    self.strokeWeight = 0.0f;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}
#pragma mark -
- (void)drawRect:(CGRect)rect 
{
    self.backgroundColor = [UIColor clearColor];
	CGRect imageBounds = CGRectMake(0.0, 0.0, self.bounds.size.width - 0.5, self.bounds.size.height);
    
    
	CGGradientRef gradient;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint point2;
    
	CGFloat resolution = 0.5 * (self.bounds.size.width / imageBounds.size.width + self.bounds.size.height / imageBounds.size.height);
	
	CGFloat stroke = strokeWeight * resolution;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke /= resolution;
	CGFloat alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point = CGPointMake((self.bounds.size.width - [self cornerRadius]), self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(self.bounds.size.width - 0.5f, (self.bounds.size.height - [self cornerRadius]));
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPoint controlPoint1 = CGPointMake((self.bounds.size.width - ([self cornerRadius] / 2.f)), self.bounds.size.height - 0.5f);
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	CGPoint controlPoint2 = CGPointMake(self.bounds.size.width - 0.5f, (self.bounds.size.height - ([self cornerRadius] / 2.f)));
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(self.bounds.size.width - 0.5f, [self cornerRadius]);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake((self.bounds.size.width - [self cornerRadius]), 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(self.bounds.size.width - 0.5f, ([self cornerRadius] / 2.f));
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake((self.bounds.size.width - ([self cornerRadius] / 2.f)), 0.0);
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake([self cornerRadius], 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.0, [self cornerRadius]);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(([self cornerRadius] / 2.f), 0.0);
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake(0.0, ([self cornerRadius] / 2.f));
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(0.0, (self.bounds.size.height - [self cornerRadius]));
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake([self cornerRadius], self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	controlPoint1 = CGPointMake(0.0, (self.bounds.size.height - ([self cornerRadius] / 2.f)));
	controlPoint1.x = (round(resolution * controlPoint1.x + alignStroke) - alignStroke) / resolution;
	controlPoint1.y = (round(resolution * controlPoint1.y + alignStroke) - alignStroke) / resolution;
	controlPoint2 = CGPointMake(([self cornerRadius] / 2.f), self.bounds.size.height - 0.5f);
	controlPoint2.x = (round(resolution * controlPoint2.x + alignStroke) - alignStroke) / resolution;
	controlPoint2.y = (round(resolution * controlPoint2.y + alignStroke) - alignStroke) / resolution;
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake((self.bounds.size.width - [self cornerRadius]), self.bounds.size.height - 0.5f);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
    if (self.state == UIControlStateHighlighted)
        gradient = self.highlightGradient;
    else
        gradient = self.normalGradient;
    
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake((self.bounds.size.width / 2.0), self.bounds.size.height - 0.5f);
	point2 = CGPointMake((self.bounds.size.width / 2.0), 0.0);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	[strokeColor setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
    
}
#pragma mark -
#pragma mark Touch Handling
- (void)hesitateUpdate
{
    [self setNeedsDisplay];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.1];
}
#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[self normalGradientColors] forKey:@"normalGradientColors"];
    [encoder encodeObject:[self normalGradientLocations] forKey:@"normalGradientLocations"];
    [encoder encodeObject:[self highlightGradientColors] forKey:@"highlightGradientColors"];
    [encoder encodeObject:[self highlightGradientLocations] forKey:@"highlightGradientLocations"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if (self = [super initWithCoder:decoder]) 
    {
        [self setNormalGradientColors:[decoder decodeObjectForKey:@"normalGradientColors"]];
        [self setNormalGradientLocations:[decoder decodeObjectForKey:@"normalGradientLocations"]];
        [self setHighlightGradientColors:[decoder decodeObjectForKey:@"highlightGradientColors"]];
        [self setHighlightGradientLocations:[decoder decodeObjectForKey:@"highlightGradientLocations"]];
        self.cornerRadius = 5.f;
        self.strokeWeight = 1.f;
        self.strokeColor = [UIColor colorWithWhite:0.853 alpha:1.000];
    
        if (self.normalGradientColors == nil)
            [self useGithubStyle];
        
        [self setOpaque:NO];
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    }
    return self;
}
#pragma mark -
- (void)dealloc 
{
    if (normalGradient != NULL)
        CGGradientRelease(normalGradient);
    if (highlightGradient != NULL)
        CGGradientRelease(highlightGradient);
}

// overriding setHighlighted +, see: http://stackoverflow.com/a/10762475/183537
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
