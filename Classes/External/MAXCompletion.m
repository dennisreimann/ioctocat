/*
 Copyright (c) 2013 Max Bäumle. All rights reserved.
 */

#import "MAXCompletion.h"
#import "GradientButton.h"
#import "GHUser.h"

@interface MAXCompletion ()
@property(nonatomic,strong)NSCharacterSet *charSet;
@property(nonatomic,strong)NSArray *keyArray;
@property(nonatomic,strong)NSMutableArray *buttonArray;
@property(nonatomic,strong)UIView *accessoryView;
@property(nonatomic,strong)UIScrollView *scrollView;
@end

@implementation MAXCompletion

@synthesize enabled = _enabled;

- (id)init {
    self = [super init];
    if (self) {
        _enabled = YES;
        _prefix = @"@";
        _charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        CGRect frame = CGRectMake(0.0f, 0.0f, 1.0f, 40.0f);
        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        UIView *accessoryView = [[UIView alloc] initWithFrame:frame];
        accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MessageEntryBG.png"]];
        accessoryView.autoresizingMask = autoresizingMask;
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageEntryBG.png"]];
        //imageView.frame = frame;
        //imageView.autoresizingMask = autoresizingMask;
        //[accessoryView addSubview:imageView];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.autoresizingMask = autoresizingMask;
        scrollView.showsHorizontalScrollIndicator = NO;
        [accessoryView addSubview:scrollView];
        _accessoryView = accessoryView;
        _scrollView = scrollView;
    }
    return self;
}

- (void)dealloc {
    if (_textView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_textView];
        [_textView removeObserver:self forKeyPath:@"selectedTextRange"];
    }
}

- (BOOL)enabled {
    return _textView && _prefix && _dataSource ? _enabled : NO;
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled != _enabled) {
        _enabled = enabled;
        if (_textView) {
            [self textViewDidChange:_textView];
        }
    }
}

- (void)setTextView:(UITextView *)textView {
    if (textView != _textView) {
        if (_textView) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_textView];
            [_textView removeObserver:self forKeyPath:@"selectedTextRange"];
        }
        _textView = textView;
        if (_textView) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:_textView];
            [_textView addObserver:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionNew context:NULL];
            [self textViewDidChange:_textView];
        }
    }
}

- (void)setPrefix:(NSString *)prefix {
    if (prefix != _prefix) {
        _prefix = prefix;
        if (_textView) {
            [self textViewDidChange:_textView];
        }
    }
}

- (void)setDataSource:(NSDictionary *)dataSource {
    if (dataSource != _dataSource) {
        if (_buttonArray) {
            for (UIView *button in _buttonArray) {
                [button removeFromSuperview];
            }
        }
        _dataSource = dataSource;
        NSArray *allKeys = nil;
        NSMutableArray *buttonArray = nil;
        if (_dataSource) {
            allKeys = [_dataSource allKeys];
            if ([allKeys count] > 1) {
                allKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            }
            buttonArray = [NSMutableArray arrayWithCapacity:[allKeys count]];
        }
        _keyArray = allKeys;
        _buttonArray = buttonArray;
        if (_textView) {
            [self textViewDidChange:_textView];
        }
    }
}

#pragma mark Helpers



#pragma mark Actions

- (void)buttonTapped:(UIButton *)sender {
    NSString *text = self.textView.text;
    NSUInteger textLength = [text length];
    NSRange selectedRange = self.textView.selectedRange;
    NSUInteger location = selectedRange.location;
    NSUInteger length = selectedRange.length;
    NSRange backwardsRange = [text rangeOfCharacterFromSet:self.charSet options:NSBackwardsSearch range:NSMakeRange(0, location)];
    NSRange range = backwardsRange.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(backwardsRange.location + backwardsRange.length, location + length - (backwardsRange.location + backwardsRange.length));
    NSRange charFromSetRange = [text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
    range = NSMakeRange(range.location, charFromSetRange.location == NSNotFound ? textLength - range.location : charFromSetRange.location - range.location);
    NSString *string = [NSString stringWithFormat:@"@%@ ", sender.currentTitle];
    self.textView.text = [text stringByReplacingCharactersInRange:range withString:string];
    self.textView.selectedRange = NSMakeRange(range.location + [string length], 0);
    self.textView.inputAccessoryView = nil;
    [self.textView reloadInputViews];
}

#pragma mark TextView

- (void)textViewDidChange:(UITextView *)textView {
    if (self.enabled) {
        NSRange selectedRange = textView.selectedRange;
        NSUInteger location = selectedRange.location;
        NSUInteger length = selectedRange.length;
        NSString *text = textView.text;
        NSUInteger textLength = [text length];
        if (location + length > textLength) {
            location = 0;
            length = 0;
            selectedRange = NSMakeRange(location, length);
        }
        NSArray *components = nil;
        if (length > 0) {
            NSString *substring = [text substringWithRange:selectedRange];
            components = [substring componentsSeparatedByCharactersInSet:self.charSet];
        }
        NSRange range;
        NSString *substring = nil;
        if (length == 0 || [components count] == 1) {
            NSRange backwardsRange = [text rangeOfCharacterFromSet:self.charSet options:NSBackwardsSearch range:NSMakeRange(0, location)];
            range = backwardsRange.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(backwardsRange.location + backwardsRange.length, location + length - (backwardsRange.location + backwardsRange.length));
            substring = [text substringWithRange:range];
        }
        if ([substring hasPrefix:self.prefix]) {
            NSRange charFromSetRange = [text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
            range = NSMakeRange(range.location, charFromSetRange.location == NSNotFound ? textLength - range.location : charFromSetRange.location - range.location);
            if (range.length > 1) {
                NSString *key = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
                NSArray *filteredKeyArray = [self.keyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", key]];
                if ([filteredKeyArray count] > 0) {
                    [self.scrollView setContentOffset:CGPointZero animated:NO];
                    NSUInteger index = 0;
                    NSUInteger count = [self.buttonArray count];
                    CGFloat m = 5.0f;
                    CGFloat h = self.scrollView.frame.size.height - m * 2;
                    CGFloat x = self.scrollView.bounds.origin.x + m;
                    for (NSString *key in filteredKeyArray) {
                        GradientButton *button = nil;
                        while (index < count) {
                            button = self.buttonArray[index];
                            index++;
                            break;
                        }
                        UIImageView *imageView = nil;
                        if (!button) {
                            button = [GradientButton buttonWithType:UIButtonTypeCustom];
                            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(m, m, h - m * 2, h - m * 2)];
                            imageView.layer.masksToBounds = YES;
                            imageView.layer.cornerRadius = 3.0f;
                            [button insertSubview:imageView atIndex:0];
                            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                            button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                            button.contentEdgeInsets = UIEdgeInsetsMake(m, h, m, m);
                            [button useDarkGithubStyle];
                            [self.buttonArray addObject:button];
                        }
                        if (!imageView) {
                            imageView = [button subviews][0];
                        }
                        [button setTitle:key forState:UIControlStateNormal];
                        [button sizeToFit];
                        button.frame = CGRectMake(x, m, button.frame.size.width, h);
                        id user = self.dataSource[key];
                        UIImage *image = nil;
                        if ([user respondsToSelector:@selector(gravatar)]) {
                            id gravatar = [(GHUser *)user gravatar];
                            if ([gravatar isKindOfClass:[UIImage class]]) {
                                image = gravatar;
                            }
                        }
                        imageView.image = image ? image : [UIImage imageNamed:@"AvatarBackground32.png"];
                        if (!button.superview) {
                            [self.scrollView addSubview:button];
                        }
                        x += button.frame.size.width + m;
                    }
                    while (index < count) {
                        [self.buttonArray[index] removeFromSuperview];
                        index++;
                    }
                    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
                    if (!textView.inputAccessoryView) {
                        textView.inputAccessoryView = self.accessoryView;
                        [textView reloadInputViews];
                    }
                    return;
                }
            }
        }
    }
    if (textView.inputAccessoryView) {
        textView.inputAccessoryView = nil;
        [textView reloadInputViews];
    }
}

- (void)textViewTextDidChange:(NSNotification *)notification {
    [self textViewDidChange:[notification object]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedTextRange"]) {
        [self textViewDidChange:object];
    }
}

@end