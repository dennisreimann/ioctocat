#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHUser.h"


@interface GHFeed ()
- (void)parseFeed;
@end


@implementation GHFeed

@synthesize url, entries;

- (id)initWithURL:(NSURL *)theURL {
	if (self = [super init]) {
		self.url = theURL;
		self.entries = [NSMutableArray array];
		self.status = GHResourceStatusNotLoaded;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHFeed url:'%@'>", url];
}

#pragma mark -
#pragma mark Feed parsing

- (void)loadFeed {
	if (self.isLoading) return;
	self.status = GHResourceStatusLoading;
	self.entries = [NSMutableArray array];
	[self performSelectorInBackground:@selector(parseFeed) withObject:nil];
}

- (void)parseFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

- (void)finishedParsing {
	self.status = GHResourceStatusLoaded;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"entry"]) {
		currentEntry = [[GHFeedEntry alloc] init];
		currentEntry.feed = self;
	} else if ([elementName isEqualToString:@"link"]) {
		NSString *href = [attributeDict valueForKey:@"href"];
		currentEntry.linkURL = ([href isEqualToString:@""]) ? nil : [NSURL URLWithString:href];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"entry"]) {
		[entries addObject:currentEntry];
		[currentEntry release];
		currentEntry = nil;
	} else if ([elementName isEqualToString:@"id"]) {
		currentEntry.entryID = currentElementValue;
		NSString *event = [currentElementValue substringFromIndex:20];
		if ([event hasPrefix:@"Fork"]) {
			currentEntry.eventType = @"fork";
		} else if ([event hasPrefix:@"Issues"]) {
			currentEntry.eventType = @"issues";
		} else if ([event hasPrefix:@"Follow"]) {
			currentEntry.eventType = @"follow";
		} else if ([event hasPrefix:@"CommitComment"]) {
			currentEntry.eventType = @"comment";
		} else if ([event hasPrefix:@"Commit"]) {
			currentEntry.eventType = @"commit";
		} else if ([event hasPrefix:@"Watch"]) {
			currentEntry.eventType = @"watch";
		} else if ([event hasPrefix:@"Delete"]) {
			currentEntry.eventType = @"delete";
		} else if ([event hasPrefix:@"Create"]) {
			currentEntry.eventType = @"create";
		} else if ([event hasPrefix:@"ForkApply"]) {
			currentEntry.eventType = @"merge";
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
	[dateFormatter release];
	dateFormatter = nil;
	[self performSelectorOnMainThread:@selector(finishedParsing) withObject:nil waitUntilDone:NO];
}

// FIXME It's not quite perfect that the error handling is part
// of the model layer. This should happen in the controller.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DebugLog(@"Parsing error: %@", [parseError localizedDescription]);
	// Let's just assume it's an authentication error
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Please revise the settings and check your username and API token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[url release];
	[entries release];
	[dateFormatter release];
	[currentElementValue release];
	[currentEntry release];
    [super dealloc];
}

@end
