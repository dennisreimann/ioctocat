//
//  MF_Base64Additions.h
//  Base64 -- RFC 4648 compatible implementation
//  see http://www.ietf.org/rfc/rfc4648.txt for more details
//
//  Designed to be compiled with Automatic Reference Counting
//
//  Created by Dave Poirier on 12-06-14.
//  Public Domain
//

#import <Foundation/Foundation.h>

@interface NSString (Base64Addition)
+(NSString *)stringFromBase64String:(NSString *)base64String;
-(NSString *)base64String;
@end

@interface NSData (Base64Addition)
+(NSData *)dataWithBase64String:(NSString *)base64String;
-(NSString *)base64String;
@end

@interface MF_Base64Codec
+(NSData *)dataFromBase64String:(NSString *)base64String;
+(NSString *)base64StringFromData:(NSData *)data;
@end
