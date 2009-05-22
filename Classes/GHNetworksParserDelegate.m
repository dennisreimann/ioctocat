#import "GHNetworksParserDelegate.h"


@implementation GHNetworksParserDelegate

- (void)dealloc {
	[currentFork release];
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"network"]) {
		currentFork = [[GHNetwork alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"network"]) {
		if (currentFork) {
            currentFork.repository = [[GHRepository alloc] initWithOwner:currentFork.user.login andName:currentFork.name];
            [resources addObject:currentFork];
        }
		[currentFork release];
		currentFork = nil;
	} else if ([elementName isEqualToString:@"description"] || [elementName isEqualToString:@"owner"] || [elementName isEqualToString:@"name"]) {
		[currentFork setValue:currentElementValue forKey:elementName];        
	} else if ([elementName isEqualToString:@"url"]) {
		currentFork.networkURL = [NSURL URLWithString:currentElementValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

@end
