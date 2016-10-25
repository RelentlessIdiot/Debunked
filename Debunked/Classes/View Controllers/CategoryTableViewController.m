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
#import "RumorTableViewController.h"
#import "RumorDataSource.h"
#import "CategoryDataSource.h"
#import "DataSourceFactory.h"
#import "CategoryNodeView.h"


@implementation CategoryTableViewController

@synthesize url;
@synthesize category;

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super init]) {
        self.url = theUrl;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CategoryNodeView preferredHeight];
}

- (void)loadView {
	if (dataSource == nil) {
		isTopLevel = YES;
		CategoryDataSource *localDataSource = [[[DataSourceFactory categoryDataSourceClass] alloc] init];
		self.dataSource = localDataSource;
		[localDataSource release];
	}

    if (ENABLE_BROWSE_TAB) {
        UIBarButtonItem *browseButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)];
        self.navigationItem.rightBarButtonItem = browseButtonItem;
    }
	
	[super loadView];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	@synchronized(self) {
		if (isTopLevel && [[(CategoryDataSource *)dataSource categoryNodes] count] == 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			if (loadingView == nil) {
				loadingView = [LoadingView loadingViewInView:tableView withBorder:NO];
			}
            if (url == nil) {
                lastRequestId = [(CategoryDataSource *)dataSource requestTopLevelCategoryNodesNotifyDelegate:self];
            } else {
                lastRequestId = [(CategoryDataSource *)dataSource requestCategoryNodes:url notifyDelegate:self];
            }
		}
	}
	
	[super viewWillAppear:animated];
}

- (void)handleBrowseButton
{
	DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:2];
	UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
	WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
	if (self.category == nil) {
        if (self.url == nil) {
            [webBrowser loadUrl:@"http://www.snopes.com"];
        } else {
            [webBrowser loadUrl:url];
        }
	} else {
		[webBrowser loadUrl:self.category.url];
	}
}

- (void)receive:(id)theItem withResult:(NSInteger)theResult
{
	@synchronized(self) {
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		self.loadingCell = nil;
		
		if (theItem == nil) {
			return;
		}
		Category *theCategory = (Category *)theItem;
		if ([[theCategory categoryNodes] count] > 0 || [[theCategory rumorNodes] count] <= 0) {
			CategoryDataSource *categoryDataSource = [[[DataSourceFactory categoryDataSourceClass] alloc] initWithCategoryNodes:[theCategory categoryNodes]];
			CategoryTableViewController *categoryTableViewController = [[CategoryTableViewController alloc] initWithDataSource:categoryDataSource];
			[categoryDataSource release];
			
			categoryTableViewController.title = [theCategory label];
			categoryTableViewController.category = theCategory;

			[self performSelectorOnMainThread:@selector(pushViewControllerAnimated:) withObject:categoryTableViewController waitUntilDone:YES];
			[categoryTableViewController release];
		} else {
			Class rumorDataSourceClass = [DataSourceFactory rumorDataSourceClass];
			RumorDataSource *rumorDataSource = [[rumorDataSourceClass alloc] initWithRumorNodes:[theCategory rumorNodes]];
			RumorTableViewController *rumorTableViewController = [[RumorTableViewController alloc] initWithDataSource:rumorDataSource];
			[rumorDataSource release];
			
			rumorTableViewController.title = [theCategory label];
			rumorTableViewController.category = theCategory;
			
			[self performSelectorOnMainThread:@selector(pushViewControllerAnimated:) withObject:rumorTableViewController waitUntilDone:YES];
			[rumorTableViewController release];
		}
	}
}

- (void)receiveCategoryNodes:(NSArray *)theCategoryNodes withResult:(NSInteger)theResult
{
	@synchronized(self) {
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		if (theCategoryNodes != nil && [theCategoryNodes count] > 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		} else {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		}
		[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
}

- (void)dealloc {
    [url release];
    [category release];

    [super dealloc];
}

@end
