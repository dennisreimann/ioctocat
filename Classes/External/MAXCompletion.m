/*
 Copyright (c) 2013 Max Bäumle. All rights reserved.
 */

#import "MAXCompletion.h"
#import "GradientButton.h"
#import "GHUser.h"
#import "GHIssue.h"

@interface MAXCompletion ()
@property(nonatomic,strong)NSCharacterSet *whitespaceAndNewline;
@property(nonatomic,strong)NSArray *sortedKeyArray;
@property(nonatomic,strong)NSArray *filteredKeyArray;
@property(nonatomic,strong)NSMutableArray *buttonArray;
@property(nonatomic,strong)NSCharacterSet *whitespace;
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
        _whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        CGRect frame = CGRectMake(0.0f, 0.0f, 8.0f, 40.0f);
        UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        UIView *accessoryView = [[UIView alloc] initWithFrame:frame];
        accessoryView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"MessageEntryBG.png"]];
        accessoryView.autoresizingMask = autoresizingMask;
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
    [self removeObservers:_textView];
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
        [self removeObservers:_textView];
        _textView = textView;
        [self addObservers:_textView];
        if (_textView) {
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

- (void)setComparator:(NSComparator)comparator {
    if (comparator != _comparator) {
        _comparator = comparator;
        NSArray *sortedKeyArray = nil;
        if (_dataSource) {
            if (_comparator) {
                sortedKeyArray = [_dataSource keysSortedByValueUsingComparator:_comparator];
            } else {
                NSArray *allKeys = [_dataSource allKeys];
                sortedKeyArray = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            }
        }
        _sortedKeyArray = sortedKeyArray;
    }
}

- (void)setDataSource:(NSDictionary *)dataSource {
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

- (NSCharacterSet *)whitespace {
    if (!_whitespace) {
        _whitespace = [NSCharacterSet whitespaceCharacterSet];
    }
    return _whitespace;
}

#pragma mark Helpers

- (void)addObservers:(id)object {
    if (object) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:object];
        [object addObserver:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeObservers:(id)object {
    if (object) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:object];
        [object removeObserver:self forKeyPath:@"selectedTextRange"];
    }
}

- (void)reloadData {
    for (UIView *button in _buttonArray) {
        [button removeFromSuperview];
    }
    NSArray *sortedKeyArray = nil;
    NSMutableArray *buttonArray = nil;
    if (_dataSource) {
        if (_comparator) {
            sortedKeyArray = [_dataSource keysSortedByValueUsingComparator:_comparator];
        } else {
            NSArray *allKeys = [_dataSource allKeys];
            sortedKeyArray = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        }
        buttonArray = [NSMutableArray arrayWithCapacity:[sortedKeyArray count]];
    }
    _sortedKeyArray = sortedKeyArray;
    _buttonArray = buttonArray;
    if (_textView) {
        [self textViewDidChange:_textView];
    }
}

#pragma mark Actions

- (void)buttonTapped:(UIButton *)sender {
    NSString *text = self.textView.text;
    NSUInteger textLength = [text length];
    NSRange selectedRange = self.textView.selectedRange;
    NSUInteger location = selectedRange.location;
    NSUInteger length = selectedRange.length;
    NSRange backwardsRange = [text rangeOfCharacterFromSet:self.whitespaceAndNewline options:NSBackwardsSearch range:NSMakeRange(0, location)];
    NSRange range = backwardsRange.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(backwardsRange.location + backwardsRange.length, location + length - (backwardsRange.location + backwardsRange.length));
    NSRange charFromSetRange = [text rangeOfCharacterFromSet:self.whitespaceAndNewline options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
    range = NSMakeRange(range.location, charFromSetRange.location == NSNotFound ? textLength - range.location : charFromSetRange.location - range.location);
    NSString *key = self.filteredKeyArray[sender.tag];
    NSString *pre = [key hasPrefix:self.prefix] ? @"" : self.prefix;
    NSString *string = [NSString stringWithFormat:@"%@%@ ", pre, key];
    self.textView.text = [text stringByReplacingCharactersInRange:range withString:string];
    self.textView.selectedRange = NSMakeRange(range.location + [string length], 0);
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
            components = [substring componentsSeparatedByCharactersInSet:self.whitespaceAndNewline];
        }
        NSRange range;
        NSString *substring = nil;
        if (length == 0 || [components count] == 1) {
            NSRange backwardsRange = [text rangeOfCharacterFromSet:self.whitespaceAndNewline options:NSBackwardsSearch range:NSMakeRange(0, location)];
            range = backwardsRange.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(backwardsRange.location + backwardsRange.length, location + length - (backwardsRange.location + backwardsRange.length));
            substring = [text substringWithRange:range];
        }
        if ([substring hasPrefix:self.prefix]) {
            NSRange charFromSetRange = [text rangeOfCharacterFromSet:self.whitespaceAndNewline options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
            range = NSMakeRange(range.location, charFromSetRange.location == NSNotFound ? textLength - range.location : charFromSetRange.location - range.location);
            if (range.length > 1) {
                NSString *key = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
                self.filteredKeyArray = [self.sortedKeyArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", key]];
                if ([self.filteredKeyArray count] > 0) {
                    [self.scrollView setContentOffset:CGPointZero animated:NO];
                    NSUInteger index = 0;
                    NSUInteger count = [self.buttonArray count];
                    CGFloat m = 5.0f;
                    CGFloat h = self.scrollView.frame.size.height - m * 2;
                    CGFloat x = self.scrollView.bounds.origin.x + m;
                    for (NSString *key in self.filteredKeyArray) {
                        GradientButton *button = nil;
                        while (index < count) {
                            button = self.buttonArray[index];
                            index++;
                            break;
                        }
                        id object = self.dataSource[key];
                        UIImageView *imageView = nil;
                        UIImage *image = nil;
                        if ([object respondsToSelector:@selector(gravatar)]) {
                            UIImage *gravatar = [object gravatar];
                            image = gravatar ? gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
                        } else if ([object respondsToSelector:@selector(state)]) {
                            image = [UIImage imageNamed:[NSString stringWithFormat:@"issue_%@.png", [(GHIssue *)object state]]];
                        }
                        if (!button) {
                            button = [GradientButton buttonWithType:UIButtonTypeCustom];
                            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                            button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                            [button useDarkGithubStyle];
                            button.cornerRadius = 3.0f;
                            button.strokeColor = [UIColor colorWithWhite:0.65 alpha:1.000];
                            [self.buttonArray addObject:button];
                            index++;
                        }
                        button.tag = index - 1;
                        // image
                        if (image) {
                            if (!imageView) {
                                id firstSubview = [button subviews][0];
                                if ([firstSubview isKindOfClass:UIImageView.class]) {
                                    imageView = firstSubview;
                                } else {
                                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(m, m, h - m * 2, h - m * 2)];
                                    imageView.layer.masksToBounds = YES;
                                    imageView.layer.cornerRadius = 3.0f;
                                    [button insertSubview:imageView atIndex:0];
                                }
                            }
                            imageView.image = image;
                        }
                        button.contentEdgeInsets = UIEdgeInsetsMake(m, imageView.image ? h : m, m, m);
                        // title
                        NSString *pre = [key hasPrefix:self.prefix] ? @"" : self.prefix;
                        NSString *label = [object isKindOfClass:NSString.class] ? [NSString stringWithFormat:@"%@ ", object] : @"";
                        NSString *title = [NSString stringWithFormat:@"%@%@%@", pre, label, key];
                        if ([object respondsToSelector:@selector(title)]) {
                            title = [NSString stringWithFormat:@"%@: %@", title, [object title]];
                            NSArray *components = [title componentsSeparatedByCharactersInSet:self.whitespace];
                            if ([components count] > 4) {
                                components = [components subarrayWithRange:NSMakeRange(0, 4)];
                                title = [NSString stringWithFormat:@"%@ […]", [components componentsJoinedByString:@" "]];
                            }
                        }
                        [button setTitle:title forState:UIControlStateNormal];
                        [button sizeToFit];
                        button.frame = CGRectMake(x, m, button.frame.size.width, h);
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
                    if (textView.inputAccessoryView != self.accessoryView) {
                        textView.inputAccessoryView = self.accessoryView;
                        [textView reloadInputViews];
                    }
                    return;
                }
            }
        }
    }
    if (textView.inputAccessoryView == self.accessoryView) {
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