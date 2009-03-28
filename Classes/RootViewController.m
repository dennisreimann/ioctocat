#import "AppConstants.h"
#import "RootViewController.h"
#import "iOctocatAppDelegate.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"


@interface RootViewController (PrivateMethods)

- (void)parseFeed;
- (void)addEntryToFeed:(GHFeedEntry *)anEntry;
- (void)finishedParsingFeed;

@end


@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"My GitHub News Feed";
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *url = [NSString stringWithFormat:@"https://github.com/%@.private.atom?token=%@", username, token];
	NSURL *feedURL = [NSURL URLWithString:url];
	feed = [[GHFeed alloc] initWithURL:feedURL];
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss"; // ISO8601
	[self performSelectorInBackground:@selector(parseFeed) withObject:nil];
}

- (void)parseFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:feed.url];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
	[pool release];
}

- (void)addEntryToFeed:(GHFeedEntry *)anEntry {
	[feed.entries addObject:anEntry];
}

- (void)finishedParsingFeed {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStandardCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kStandardCellIdentifier] autorelease];
    }
	GHFeedEntry *entry = [feed.entries objectAtIndex:indexPath.row];
	cell.text = entry.title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"entry"]) {
		currentEntry = [[GHFeedEntry alloc] init];
	} else if ([elementName isEqualToString:@"link"]) {
		NSString *url = [attributeDict valueForKey:@"href"];
		currentEntry.linkURL = ([url isEqualToString:@""]) ? nil : [NSURL URLWithString:url];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	if (!currentElementValue) {
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"entry"]) {
		[self performSelectorOnMainThread:@selector(addEntryToFeed:) withObject:currentEntry waitUntilDone:NO];
		[currentEntry release];
		currentEntry = nil;
	} else if ([elementName isEqualToString:@"id"]) {
		currentEntry.entryID = currentElementValue;
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
	[self finishedParsingFeed];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	#ifdef DEBUG
	NSLog(@"Parsing error: %@", [parseError localizedDescription]);
	#endif
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[activityView release];
	[dateFormatter release];
	[currentElementValue release];
	[currentEntry release];
	[feed release];
    [super dealloc];
}


@end

