#define IS_IPAD() \
    ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) : \
    false)
