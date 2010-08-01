#import "FilesController.h"
#import "TextCell.h"
#import "DiffController.h"


@implementation FilesController

@synthesize files;

- (id)initWithFiles:(NSArray *)theFiles {
    [super initWithNibName:@"Files" bundle:nil];
	self.files = theFiles;
    return self;
}

- (void)dealloc {
    [files release], files = nil;
    [super dealloc];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return ([files count] == 0) ? 1 : [files count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
	if ([files count] == 0) {
		cell.textLabel.text = @"No files";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		// FIXME: This is a hack for what's in my opinion is an API inconsistancy, see:
		// http://support.github.com/discussions/api/66-commitsshow-added-removed-and-modified-are-inconsistent
		NSString *diff = nil;
		NSString *fileName = nil;
		id fileInfo = [files objectAtIndex:indexPath.row];
		if ([fileInfo isKindOfClass:[NSDictionary class]]) {
			diff = [fileInfo objectForKey:@"diff"];
			fileName = [fileInfo objectForKey:@"filename"];
		} else {
			fileName = fileInfo;
		}
		cell.textLabel.text = fileName;
		cell.selectionStyle = diff ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = diff ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	}
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id fileInfo = [files objectAtIndex:indexPath.row];
	if ([fileInfo isKindOfClass:[NSDictionary class]]) {
		DiffController *diffController = [[DiffController alloc] initWithFiles:files currentIndex:indexPath.row];
		[self.navigationController pushViewController:diffController animated:YES];
		[diffController release];
	}
}

@end

