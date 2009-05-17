#import "GHCommitsParserDelegate.h"


@implementation GHCommitsParserDelegate

- (void)dealloc {
	[currentCommit release];
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"commit"]) {
		currentCommit = [[GHCommit alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"commit"]) {
		[resources addObject:currentCommit];
		[currentCommit release];
		currentCommit = nil;
	} else if ([elementName isEqualToString:@"message"] || [elementName isEqualToString:@"tree"]) {
		[currentCommit setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"id"]) {
		currentCommit.commitID = currentElementValue;
	} else if ([elementName isEqualToString:@"url"]) {
		currentCommit.commitURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

@end
