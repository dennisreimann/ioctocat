/*
 Copyright (c) 2013 Max Bäumle. All rights reserved.
 */

@interface MAXCompletion : NSObject
@property(nonatomic,assign)BOOL enabled;
@property(nonatomic,weak)UITextView *textView;
@property(nonatomic,strong)NSString *prefix;
@property(nonatomic,copy)NSComparator comparator;
@property(nonatomic,weak)NSDictionary *dataSource;
- (void)reloadData;
@end