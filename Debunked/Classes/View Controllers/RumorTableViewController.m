//  Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import "RumorTableViewController.h"


@implementation RumorTableViewController

@synthesize category;

- (void)loadView {
    if (ENABLE_BROWSE_TAB) {
        UIBarButtonItem *browseButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)];
        self.navigationItem.rightBarButtonItem = browseButtonItem;
    }
	
	[super loadView];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [RumorNodeView preferredHeight];
}

- (void)receive:(id)theItem withResult:(NSInteger)theResult
{
	@synchronized(self)
	{
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		self.loadingCell = nil;
		
		if (theItem == nil) {
			return;
		}
		Rumor *theRumor = (Rumor *)theItem;
		[self performSelectorOnMainThread:@selector(loadRumorView:) withObject:theRumor waitUntilDone:NO];
	}
}

- (void)loadRumorView:(Rumor *)theRumor
{
	RumorViewController *rumorViewController = [[RumorViewController alloc] initWithRumor:theRumor];
	[[self navigationController] pushViewController:rumorViewController animated:YES];
	[rumorViewController release];
}

- (void)receiveRumorNodes:(NSArray *)theRumorNodes withResult:(NSInteger)theResult
{
	@synchronized(self) {
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		if (theRumorNodes != nil && [theRumorNodes count] > 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		} else {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		}
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
}

- (void)handleBrowseButton
{
	if (self.category != nil) {
		DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.tabBarController setSelectedIndex:2];
		UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
		WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
		[webBrowser loadUrl:self.category.url];
	}
}

- (void)dealloc {
    [category release];

    [super dealloc];
}

@end
