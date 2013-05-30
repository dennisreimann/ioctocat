#import "IOCUtil.h"


@implementation IOCUtil

static NSDictionary *_extensions;
static NSDictionary *_filenames;

+ (NSDictionary *)extensions {
    if (!_extensions) _extensions = @{
                                      @"markdown": @[@"md", @"markdown"],
                                      @"objective-c": @[@"h", @"m"],
                                      @"ruby": @[@"rb", @"ru", @"rake", @"gemspec", @"podspec"],
                                      @"yaml": @[@"yml"],
                                      @"no-highlight": @[@"lock", @"txt"]};
    return _extensions;
}

+ (NSDictionary *)filenames {
    if (!_filenames) _filenames = @{
                                    @"ruby": @[@"Rakefile", @"Gemfile", @"Guardfile", @"Podfile"]};
    return _filenames;
}

+ (NSString *)highlightLanguageForFilename:(NSString *)filename {
    __block NSString *lang = @"";
    NSString *ext = [[NSURL URLWithString:filename] pathExtension];
    if (!ext || [ext isEqualToString:@""]) {
        // no extension, check filenames
        [self.filenames enumerateKeysAndObjectsUsingBlock:^(NSString *language, NSArray *filenames, BOOL *stop){
            if ([filenames containsObject:filename]) {
                lang = language;
                *stop = YES;
            }
        }];
        // no match, do not highlight
        if ([lang isEqualToString:@""]) lang = @"no-highlight";
    } else {
        // try to lookup by extension, if there is no match, fall back to highlight.js' detection
        [self.extensions enumerateKeysAndObjectsUsingBlock:^(NSString *language, NSArray *extensions, BOOL *stop){
            if ([extensions containsObject:ext]) {
                lang = language;
                *stop = YES;
            }
        }];
    }
    return lang;
}

@end