#import "GHFeedParserDelegate.h"
#import "GHFeedEntry.h"
#import "iOctocat.h"


@implementation GHFeedParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super init];
	target = theTarget;
	selector = theSelector;
	return self;
}

- (void)dealloc {
	[error release];
	[resources release];
	[currentEntry release];
	[currentElementValue release];
    [super dealloc];
}

#pragma mark XML Parser

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    resources = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
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
		[currentEntry release], currentEntry = nil;
	} else if ([elementName isEqualToString:@"id"]) {
		currentEntry.entryID = currentElementValue;
		NSString *event = [currentElementValue substringFromIndex:20];
		if ([event hasPrefix:@"ForkApply"]) {
			currentEntry.eventType = @"merge";
		} else if ([event hasPrefix:@"Fork"]) {
			currentEntry.eventType = @"fork";
		} else if ([event hasPrefix:@"Issues"]) {
			currentEntry.eventType = @"issue";
		} else if ([event hasPrefix:@"PullRequest"]) {
			currentEntry.eventType = @"pull_request";
		} else if ([event hasPrefix:@"Follow"]) {
			currentEntry.eventType = @"follow";
		} else if ([event hasPrefix:@"CommitComment"]) {
			currentEntry.eventType = @"comment";
		} else if ([event hasPrefix:@"Push"]) {
			currentEntry.eventType = @"push";
		} else if ([event hasPrefix:@"Commit"] || [event hasPrefix:@"Grit::Commit"]) {
			currentEntry.eventType = @"commit";
		} else if ([event hasPrefix:@"Watch"]) {
			currentEntry.eventType = @"watch";
		} else if ([event hasPrefix:@"Delete"]) {
			currentEntry.eventType = @"delete";
		} else if ([event hasPrefix:@"Create"]) {
			currentEntry.eventType = @"create";
		} else if ([event hasPrefix:@"TeamAdd"]) {
			currentEntry.eventType = @"team_add";
		} else if ([event hasPrefix:@"Member"]) {
			currentEntry.eventType = @"member";
		} else if ([event hasPrefix:@"Gist"]) {
			currentEntry.eventType = @"gist";
		} else if ([event hasPrefix:@"Wiki"] || [event hasPrefix:@"Gollum"]) {
			currentEntry.eventType = @"wiki";
		} else if ([event hasPrefix:@"Download"]) {
			currentEntry.eventType = @"download";
		} else {
			currentEntry.eventType = nil;
		}
	} else if ([elementName isEqualToString:@"updated"]) {
		currentEntry.date = [iOctocat parseDate:currentElementValue withFormat:kISO8601TimeFormat];
	} else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"content"]) {
		[currentEntry setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"name"]) {
		currentEntry.authorName = currentElementValue;
	}
	// Old method of retrieving the username: Using the name attribute does not always work,
	// because GitHub sometimes uses the users real name, and not the login. To get the login
	// we just parse the author URI which contains the users login.
	// 
	// else if ([elementName isEqualToString:@"name"]) {
	//	   currentEntry.authorName = currentElementValue;
	// } 
	else if ([elementName isEqualToString:@"uri"]) {
		currentEntry.authorName = [currentElementValue lastPathComponent];
	}
	[currentElementValue release], currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DJLog(@"Parsing error: %@", parseError);
	error = [parseError retain];
	[self parserDidEndDocument:parser];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	id result = error ? (id)error : (id)resources;
	[target performSelectorOnMainThread:selector withObject:result waitUntilDone:YES];
	[resources release];
	resources = nil;
}

@end
