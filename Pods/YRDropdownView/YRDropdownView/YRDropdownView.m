//
//  YRDropdownView.m
//  YRDropdownViewExample
//
//  Created by Eli Perkins on 1/27/12.
//  Copyright (c) 2012 One Mighty Roar. All rights reserved.
//

#import "YRDropdownView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UILabel (YRDropdownView)

- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
}

@end

@interface YRDropdownView ()
@property(nonatomic)float minHeight;
@property(nonatomic)SEL onTouch;
@property(nonatomic)BOOL shouldAnimate;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UIView *accessoryView;
@property(nonatomic,assign)dispatch_queue_t tapQueue;
@property(nonatomic,unsafe_unretained) UIView *parentView;
@property(nonatomic)BOOL isView;
@property(nonatomic)float dropdownHeight;

+ (UIImageView *)imageViewWithImage:(UIImage *)image;
- (void)updateTitleLabel:(NSString *)newText;
- (void)updateDetailLabel:(NSString *)newText;
- (void)hideWithAnimation:(NSNumber *)animated;
- (void)done;
@end


@implementation YRDropdownView

// Using this prevents two alerts to ever appear on the screen at the same time
static YRDropdownView *currentDropdown = nil;
static NSMutableArray *viewQueue = nil; // for queuing - danielgindi@gmail.com
static BOOL isRtl = NO; // keep rtl property here - danielgindi@gmail.com
static BOOL isQueuing = NO; // keep queuing property here - gregwym

+ (void)toggleRtl:(BOOL)rtl;
{
    isRtl = rtl;
}

+ (void)toggleQueuing:(BOOL)queuing
{
	isQueuing = queuing;
}

#pragma mark - Accessors

- (NSString *)titleText
{
    return self.titleLabel.text;
}

- (void)setTitleText:(NSString *)newText
{
    if ([NSThread isMainThread]) {
		[self updateTitleLabel:newText];
		[self setNeedsLayout];
		[self setNeedsDisplay];
	} else {
		[self performSelectorOnMainThread:@selector(updateTitleLabel:) withObject:newText waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
		[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	}
}

- (NSString *)detailText
{
    return self.detailLabel.text;
}

- (void)setDetailText:(NSString *)newText
{
    if ([NSThread isMainThread]) {
        [self updateDetailLabel:newText];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    } else {
        [self performSelectorOnMainThread:@selector(updateDetailLabel:) withObject:newText waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

- (void)updateTitleLabel:(NSString *)newText {
    if (![self.titleText isEqualToString:newText]) {
        self.titleLabel.text = [newText copy];
    }
}

- (void)updateDetailLabel:(NSString *)newText {
    if (![self.detailText isEqualToString:newText]) {
        self.detailLabel.text = [newText copy];
    }
}

- (dispatch_queue_t)tapQueue {
    if (!_tapQueue) {
        return dispatch_get_main_queue();
    }
    return _tapQueue;
}

#pragma mark - Initializers
- (id)init {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clearsContextBeforeDrawing = NO;
        self.titleText = nil;
        self.detailText = nil;
        self.minHeight = 44.0f;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.detailLabel = [[UILabel alloc] initWithFrame:self.bounds];
        if (isRtl)
        {
            self.titleLabel.textAlignment = self.detailLabel.textAlignment = NSTextAlignmentRight;
        }
        
        self.backgroundColors = @[[UIColor colorWithRed:0.969 green:0.859 blue:0.475 alpha:1.000], [UIColor colorWithRed:0.937 green:0.788 blue:0.275 alpha:1.000]];
        self.backgroundColorPositions = @[@0.0f, @1.0f];
        
        self.titleTextColor = [UIColor colorWithWhite:0.225f alpha:1.0f];
        self.textColor = self.titleTextColor;
        self.titleTextShadowColor = [UIColor colorWithWhite:1.0f alpha:0.25f];
        self.textShadowColor = self.titleTextShadowColor;
        
        // Gentle shadow settings. Path will be set up live, in [layoutSubviews] - danielgindi@gmail.com
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowColor = [UIColor colorWithWhite:0.450f alpha:1.0f].CGColor;
        self.layer.shadowOpacity = 1.0f;
        
        self.accessoryView = nil;
        
        self.opaque = YES;
        self.isView = NO;
        
        self.onTouch = @selector(hide:);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Routine to draw the gradient background - danielgindi@gmail.com
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Clear everything
    CGContextClearRect(context, rect);
    
    float * gradientLocations = malloc(sizeof(float)*self.backgroundColors.count);
    
    NSNumber * n;
    NSMutableArray * gradientColors = [NSMutableArray array];
    for (NSUInteger j=0,len = self.backgroundColors.count; j<len; j++)
    {
        [gradientColors addObject:(id)(((UIColor*)(self.backgroundColors)[j]).CGColor)];
        n = (self.backgroundColorPositions)[j];
        if (n) gradientLocations[j] = [n floatValue];
        else gradientLocations[j] = j==0?0.0f:1.0f;
    }
    
    // RGB color space. Free this later.
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    // create gradient
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawLinearGradient(context,
                                gradient,
                                CGPointMake(0, rect.origin.y),
                                CGPointMake(0, rect.origin.y + rect.size.height),
                                kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgb);
    
    free(gradientLocations);
    
    [super drawRect:rect]; // I do not know if previous iOS versions depend on that for drawing subviews, or they do it on the CALayer level anyways.
}

#pragma mark - Defines

#define HORIZONTAL_PADDING 15.0f
#define VERTICAL_PADDING 15.0f
#define ACCESSORY_PADDING 0.0f
#define TITLE_FONT_SIZE 18.0f
#define DETAIL_FONT_SIZE 13.0f
#define ANIMATION_DURATION 0.3f

#pragma mark - Class methods
#pragma mark View Methods

+ (UIImageView *)imageViewWithImage:(UIImage *)image
{
	UIImageView *imageView = nil;
	if (image) {
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
		imageView.image = image;
	}
	return imageView;
}

+ (YRDropdownView *)dropdownInView:(UIView *)view title:(NSString *)title detail:(NSString *)detail accessoryView:(UIView *)accessoryView animated:(BOOL)animated
{
	YRDropdownView *dropdown = [[YRDropdownView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 44)];
	if (![view isKindOfClass:[UIWindow class]])
	{
		dropdown.isView = YES;
	}
    
	if ((viewQueue && [viewQueue count] > 0) || (isQueuing && currentDropdown)) // add to queue - danielgindi@gmail.com
	{
		if (!viewQueue) viewQueue = [NSMutableArray array];
		[viewQueue addObject:dropdown];
	}
	else
	{
		[currentDropdown hide:currentDropdown.shouldAnimate];
		currentDropdown = dropdown;
	}
	dropdown.titleText = title;
    
	if (detail) {
		dropdown.detailText = detail;
	}
    
	if (accessoryView) {
		dropdown.accessoryView = accessoryView;
	}
    
	dropdown.shouldAnimate = animated;
	dropdown.parentView = view;
    
	return dropdown;
}

+ (YRDropdownView *)dropdownInView:(UIView *)view title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image animated:(BOOL)animated
{
	UIImageView *accessoryView = [self imageViewWithImage:image];
	return [self dropdownInView:view title:title detail:detail accessoryView:accessoryView animated:animated];
}

+ (BOOL)hideDropdownInView:(UIView *)view
{
    return [YRDropdownView hideDropdownInView:view animated:YES];
}

+ (BOOL)hideDropdownInView:(UIView *)view animated:(BOOL)animated
{
    if (currentDropdown) {
        [currentDropdown hide:animated];
        return YES;
    }
    
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[YRDropdownView class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        YRDropdownView *dropdown = (YRDropdownView *)viewToRemove;
        [dropdown hide:animated];
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)presentDropdown:(YRDropdownView *)dropdownView
{
	if (dropdownView == nil) {
		return;
	}
	if (currentDropdown != nil && currentDropdown != dropdownView) {
		return;
	}
	currentDropdown = dropdownView;
	
	[dropdownView.parentView addSubview:dropdownView];
	[dropdownView show:dropdownView.shouldAnimate];
	if (dropdownView.hideAfter != 0.0)
	{
		[dropdownView performSelector:@selector(hideWithAnimation:) withObject:@(dropdownView.shouldAnimate) afterDelay:dropdownView.hideAfter+ANIMATION_DURATION];
	}
	[[NSNotificationCenter defaultCenter] addObserver:dropdownView selector:@selector(flipViewToOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[dropdownView flipViewToOrientation:nil];
}

+ (BOOL)isCurrentlyShowing {
    return currentDropdown != nil;
}

#pragma mark - Methods

- (void)show:(BOOL)animated
{
    if(animated)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        BOOL rotatedY = orientation == UIInterfaceOrientationPortraitUpsideDown && !self.isView;
        int rotated = self.isView?0:(orientation == UIInterfaceOrientationLandscapeLeft ? 1 : (orientation == UIInterfaceOrientationLandscapeRight ? 2 : 0));
        if (orientation != UIInterfaceOrientationPortrait) [self layoutSubviews];
        CGRect originalRc = self.frame;
        self.frame = CGRectMake(
                                originalRc.origin.x+(rotated==1?-originalRc.size.width:(rotated==2?originalRc.size.width:0)),
                                originalRc.origin.y+(rotated?0:(rotatedY?originalRc.size.height:-originalRc.size.height)),
                                originalRc.size.width,
                                originalRc.size.height);
        self.alpha = 0;
        
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 1.0;
                             self.frame = originalRc;
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 
                             }
                         }];
        
    }
}

- (void)hide:(BOOL)animated
{
	[self hideWithAnimation:@(animated)];
}

- (void)hideWithAnimation:(NSNumber *)animated {
    if ([animated boolValue])
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        BOOL rotatedY = orientation == UIInterfaceOrientationPortraitUpsideDown && !self.isView;
        int rotated = self.isView?0:(orientation == UIInterfaceOrientationLandscapeLeft ? 1 : (orientation == UIInterfaceOrientationLandscapeRight ? 2 : 0));
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 0;
                             self.frame = CGRectMake(
                                                     self.frame.origin.x+(rotated==1?-self.frame.size.width:(rotated==2?self.frame.size.width:0)),
                                                     self.frame.origin.y+(rotated?0:(rotatedY?self.frame.size.height:-self.frame.size.height)),
                                                     self.frame.size.width,
                                                     self.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self done];
                             }
                         }];
    }
    else
    {
        self.alpha = 0.0f;
        [self done];
    }
}

- (void)done
{
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (viewQueue.count && currentDropdown == self) // no need for nil check
    {
        currentDropdown = viewQueue[0];
        [viewQueue removeObjectAtIndex:0];
		[YRDropdownView presentDropdown:currentDropdown];
    }
    else
    {
        currentDropdown = nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.tapBlock) {
        dispatch_async(self.tapQueue, self.tapBlock);
    }
    [self hide:self.shouldAnimate];
}

#pragma mark - Layout

- (void)layoutSubviews
{
	CGRect bounds = self.bounds;
    
	// Set label properties
	if ([self.titleText length] > 0) {
		self.titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
		self.titleLabel.adjustsFontSizeToFitWidth = NO;
		self.titleLabel.opaque = NO;
		self.titleLabel.backgroundColor = [UIColor clearColor];
		self.titleLabel.textColor = _titleTextColor;
		self.titleLabel.shadowOffset = CGSizeMake(0, 1); // CALayer already translates pixel size
		self.titleLabel.shadowColor = _titleTextShadowColor;
		[self.titleLabel sizeToFitFixedWidth:bounds.size.width - (2 * HORIZONTAL_PADDING)];
        
		self.titleLabel.frame = CGRectMake(bounds.origin.x + HORIZONTAL_PADDING,
                                           bounds.origin.y + VERTICAL_PADDING - 3,
                                           bounds.size.width - (2 * HORIZONTAL_PADDING),
                                           self.titleLabel.frame.size.height);
		[self addSubview:self.titleLabel];
	}
    
	if ([self.detailText length] > 0) {
		self.detailLabel.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
		self.detailLabel.numberOfLines = 0;
		self.detailLabel.adjustsFontSizeToFitWidth = NO;
		self.detailLabel.opaque = NO;
		self.detailLabel.backgroundColor = [UIColor clearColor];
		self.detailLabel.textColor = _textColor;
		self.detailLabel.shadowOffset = CGSizeMake(0, 1);
		self.detailLabel.shadowColor = _textShadowColor;
		[self.detailLabel sizeToFitFixedWidth:bounds.size.width - (2 * HORIZONTAL_PADDING)];
		
		self.detailLabel.frame = CGRectMake(bounds.origin.x + HORIZONTAL_PADDING,
                                            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 2,
                                            bounds.size.width - (2 * HORIZONTAL_PADDING),
                                            self.detailLabel.frame.size.height);
        
		[self addSubview:self.detailLabel];
	} else {
		CGRect rc = CGRectMake(self.titleLabel.frame.origin.x,
                               9,
                               self.titleLabel.frame.size.width,
                               self.titleLabel.frame.size.height);
		if (isRtl)
		{
			rc.origin.x = bounds.size.width - rc.origin.x - rc.size.width;
		}
		self.titleLabel.frame = rc;
	}
    
	if (self.accessoryView) {
		CGRect rc;
		
		rc = self.accessoryView.frame;
		rc.origin.x = bounds.origin.x + HORIZONTAL_PADDING;
		rc.origin.y = bounds.origin.y + VERTICAL_PADDING;
		if (isRtl)
		{
			rc.origin.x = bounds.origin.x + bounds.size.width - HORIZONTAL_PADDING - rc.size.width;
		}
		self.accessoryView.frame = rc;
		
		CGFloat padding = self.accessoryView.frame.origin.x + self.accessoryView.frame.size.width + ACCESSORY_PADDING;
		
		if ([self.titleLabel.text length] > 0) {
			[self.titleLabel sizeToFitFixedWidth:bounds.size.width - padding - (HORIZONTAL_PADDING * 2)];
			rc = self.titleLabel.frame;
			rc.origin.x = rc.origin.x + padding;
			if (isRtl)
			{
				rc.origin.x =  bounds.size.width - rc.origin.x - rc.size.width;
			}
			self.titleLabel.frame = rc;
		}
		
		if ([self.detailLabel.text length] > 0) {
			[self.detailLabel sizeToFitFixedWidth:bounds.size.width - padding - (HORIZONTAL_PADDING * 2)];
			rc = self.detailLabel.frame;
			rc.origin.x = rc.origin.x + padding;
			if (isRtl)
			{
				rc.origin.x =  bounds.size.width - rc.origin.x - rc.size.width;
			}
			self.detailLabel.frame = rc;
		}
		
		[self addSubview:self.accessoryView];
	}
    
	CGFloat dropdownHeight = 29.0f;
	if ([self.detailText length] > 0) {
		dropdownHeight = CGRectGetMaxY(self.detailLabel.frame);
	}
	if (self.accessoryView) {
		dropdownHeight = MAX(dropdownHeight, CGRectGetMaxY(self.accessoryView.frame));
	}
	dropdownHeight += VERTICAL_PADDING;
	self.dropdownHeight = dropdownHeight;
    
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	BOOL rotated = UIInterfaceOrientationIsLandscape(orientation) && !self.isView;
    
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, rotated?dropdownHeight:self.frame.size.width, rotated?self.frame.size.height:dropdownHeight)];
    
	[self flipViewToOrientation:nil];
}

- (void)flipViewToOrientation:(NSNotification *)notification
{
    if (!currentDropdown.isView)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (!self.dropdownHeight) return;
        CGFloat angle = 0.0;
        CGRect newFrame = self.window.bounds;
        CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
        
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                angle = M_PI;
                newFrame.origin.y = newFrame.size.height - statusBarSize.height - self.dropdownHeight;
                newFrame.size.height = self.dropdownHeight;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                angle = - M_PI / 2.0f;
                newFrame.origin.x += statusBarSize.width;
                newFrame.size.width = self.dropdownHeight;
                break;
            case UIInterfaceOrientationLandscapeRight:
                angle = M_PI / 2.0f;
                newFrame.origin.x = newFrame.size.width - statusBarSize.width - self.dropdownHeight;
                newFrame.size.width = self.dropdownHeight;
                break;
            default: // as UIInterfaceOrientationPortrait
                angle = 0.0;
                newFrame.origin.y += statusBarSize.height;
                newFrame.size.height = self.dropdownHeight;
                newFrame.size.width = statusBarSize.width;
                break;
        } 
        self.transform = CGAffineTransformMakeRotation(angle);
        self.frame = newFrame;
    }
    else
    {
        CGRect newFrame = currentDropdown.frame;
        newFrame.size.width = currentDropdown.superview.frame.size.width;
        currentDropdown.frame = newFrame;
    }
}

@end


