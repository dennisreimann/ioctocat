#import <Foundation/Foundation.h>


@interface NSString (Extensions)
- (NSString *)lowercaseFirstCharacter;
- (BOOL)isEmpty;
- (NSString *)escapeHTML;
- (NSString *)stripHTML;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)stringByEscapingForURLArgument;
@end
