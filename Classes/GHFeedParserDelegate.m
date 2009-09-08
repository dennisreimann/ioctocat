#import "GHFeedParserDelegate.h"
#import "GHFeedEntry.h"


@implementation GHFeedParserDelegate

- (void)dealloc {
	[currentEntry release];
	[dateFormatter release];
    [super dealloc];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[super parserDidStartDocument:parser];
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"entry"]) {
		currentEntry = [[GHFeedEntry alloc] init];
	} else if ([elementName isEqualToString:@"link"]) {
		NSString *href = [attributeDict valueForKey:@"href"];
		currentEntry.linkURL = ([href isEqualToString:@""]) ? nil : [NSURL URLWithString:href];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"entry"]) {
		[resources addObject:currentEntry];
		[currentEntry release];
		currentEntry = nil;
	} else if ([elementName isEqualToString:@"id"]) {
		currentEntry.entryID = currentElementValue;
		NSString *event = [currentElementValue substringFromIndex:20];
		if ([event hasPrefix:@"ForkApply"]) {
			currentEntry.eventType = @"merge";
		} else if ([event hasPrefix:@"Fork"]) {
			currentEntry.eventType = @"fork";
		} else if ([event hasPrefix:@"Issues"]) {
			currentEntry.eventType = @"issues";
		} else if ([event hasPrefix:@"Follow"]) {
			currentEntry.eventType = @"follow";
		} else if ([event hasPrefix:@"CommitComment"]) {
			currentEntry.eventType = @"comment";
		} else if ([event hasPrefix:@"Commit"] || [event hasPrefix:@"Grit::Commit"]) {
			currentEntry.eventType = @"commit";
		} else if ([event hasPrefix:@"Watch"]) {
			currentEntry.eventType = @"watch";
		} else if ([event hasPrefix:@"Delete"]) {
			currentEntry.eventType = @"delete";
		} else if ([event hasPrefix:@"Create"]) {
			currentEntry.eventType = @"create";
		} else if ([event hasPrefix:@"Member"]) {
			currentEntry.eventType = @"member";
		} else if ([event hasPrefix:@"Push"]) {
			currentEntry.eventType = @"push";
		} else if ([event hasPrefix:@"Gist"]) {
			currentEntry.eventType = @"gist";
		} else if ([event hasPrefix:@"Wiki"]) {
			currentEntry.eventType = @"wiki";
		} else {
			currentEntry.eventType = nil;
		}
	} else if ([elementName isEqualToString:@"updated"]) {
		currentEntry.date = [dateFormatter dateFromString:currentElementValue];
	} else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"content"]) {
		[currentEntry setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"name"]) {
		currentEntry.authorName = currentElementValue;
	} 
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[super parserDidEndDocument:parser];
	[dateFormatter release];
	dateFormatter = nil;
}

@end
