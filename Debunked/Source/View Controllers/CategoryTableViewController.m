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

#import "CategoryTableViewController.h"
#import "DebunkedAppDelegate.h"
#import "WebBrowserViewController.h"
#import "RumorViewController.h"
#import "CategoryNodeTableViewCell.h"
#import "RumorNodeTableViewCell.h"


@implementation CategoryTableViewController

- (CategoryDataSource *)categoryDataSource
{
    return (CategoryDataSource *)self.dataSource;
}

- (void)viewDidLoad
{
	if (self.dataSource == nil) {
		self.dataSource = [[[CategoryDataSource alloc] init] autorelease];
    }

    [super viewDidLoad];

    if (ENABLE_BROWSE_TAB) {
        UIBarButtonItem *browseButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)];
        self.navigationItem.rightBarButtonItem = browseButtonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	@synchronized(self) {
		if (self.categoryDataSource.nodeCount == 0) {
            [self reloadDataSource];
		}
	}
	
	[super viewWillAppear:animated];
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [super reloadDataSource];

        if (self.url == nil) {
            lastRequestId = [self.categoryDataSource requestTopLevelCategoryNotifyDelegate:self];
        } else {
            lastRequestId = [self.categoryDataSource requestCategory:self.url notifyDelegate:self];
        }
    }
}

- (void)handleBrowseButton
{
	DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:2];
	UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
	WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
    if (self.url == nil) {
        if (self.categoryDataSource.category.url == nil) {
            [webBrowser loadUrl:@"http://www.snopes.com"];
        } else {
            [webBrowser loadUrl:self.categoryDataSource.category.url];
        }
    } else {
        [webBrowser loadUrl:self.url];
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    @synchronized(self) {
        UITableViewCell *cell = [theTableView cellForRowAtIndexPath:theIndexPath];
        if ([cell isKindOfClass: RumorNodeTableViewCell.class]) {
            RumorNodeTableViewCell *rumorCell = (RumorNodeTableViewCell *)cell;
			RumorViewController *rumorController = [[[RumorViewController alloc] initWithUrl:rumorCell.rumorNode.url] autorelease];
			rumorController.title = rumorCell.rumorNode.label;
			[self performSelectorOnMainThread:@selector(pushViewControllerAnimated:)
                                   withObject:rumorController
                                waitUntilDone:YES];
        } else if ([cell isKindOfClass: CategoryNodeTableViewCell.class]) {
            CategoryNodeTableViewCell *categoryCell = (CategoryNodeTableViewCell *)cell;
            CategoryTableViewController *categoryController = [[[CategoryTableViewController alloc] initWithUrl:categoryCell.categoryNode.url] autorelease];
            categoryController.title = categoryCell.categoryNode.label;
            [self performSelectorOnMainThread:@selector(pushViewControllerAnimated:)
                                   withObject:categoryController
                                waitUntilDone:YES];
        } else {
            [theTableView deselectRowAtIndexPath:theIndexPath animated:YES];
        }
    }
}

@end
