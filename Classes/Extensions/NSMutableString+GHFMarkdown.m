//
//  NSMutableString+GHFMarkdown.m
//  iOctocat
//
//  Created by Dennis Reimann on 05/15/13.
//  http://dennisreimann.de
//

#import <CoreText/CoreText.h>
#import "NSMutableString+GHFMarkdown.h"
#import "NSString+GHFMarkdown.h"

@implementation NSMutableString (GHFMarkdown)

- (void)substituteMarkdownLinks {
    NSArray *links = [self linksFromGHFMarkdownLinks];
    if (links.count) {
        NSEnumerator *enumerator = [links reverseObjectEnumerator];
        for (NSDictionary *link in enumerator) {
            NSRange range = [link[@"range"] rangeValue];
            NSString *title = link[@"title"];
            [self replaceCharactersInRange:range withString:title];
        }
    }
}

- (void)substituteMarkdownTasks {
    NSArray *tasks = [self tasksFromGHFMarkdown];
    if (tasks.count) {
        NSEnumerator *enumerator = [tasks reverseObjectEnumerator];
        for (NSDictionary *task in enumerator) {
            NSRange markRange = [task[@"markRange"] rangeValue];
            NSString *mark = task[@"mark"];
            [self replaceCharactersInRange:markRange withString:mark];
        }
    }
}

@end