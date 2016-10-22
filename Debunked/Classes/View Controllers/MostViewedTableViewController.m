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

#import "MostViewedTableViewController.h"
#import "LoadingView.h"
#import "HttpRumorDataSource.h"


@implementation MostViewedTableViewController

- (void)loadView {
	[super loadView];
	[tableView setDelegate:self];

	NSArray *segmentTextContent = [NSArray arrayWithObjects:@"What's New", @"Top 25", nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = selectedSegmentIndex;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;

	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
}

- (void)viewWillAppear:(BOOL)animated
{
	@synchronized(self) {
		if ([[(HttpRumorDataSource *)dataSource rumorNodes] count] == 0) {
			tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			if (tableView.dragging || tableView.decelerating) {
				needsLoadingView = YES;
			} else {
				if (loadingView == nil) {
					needsLoadingView = NO;
					loadingView = [LoadingView loadingViewInView:[self view] withBorder:NO];
				}
			}
			if ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex] == 0) {
				lastRequestId = [(HttpRumorDataSource *)dataSource requestWhatsNewRumorNodesNotifyDelegate:self];
			} else {
				lastRequestId = [(HttpRumorDataSource *)dataSource requestTop25RumorNodesNotifyDelegate:self];
			}
		}
	}

	[super viewWillAppear:animated];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (needsLoadingView == YES) {
		needsLoadingView = NO;
		if (loadingView == nil) {
			loadingView = [LoadingView loadingViewInView:[self view] withBorder:NO];
		}
	}
}

- (void)handleBrowseButton
{
	DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:2];
	UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
	WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
	if (selectedSegmentIndex == 0) {
		[webBrowser loadUrl:@"http://www.snopes.com/info/whatsnew.asp"];
	} else {
		[webBrowser loadUrl:@"http://www.snopes.com/info/top25uls.asp"];
	}
}

- (void)segmentAction:(id)sender
{
	@synchronized(self) {
		[dataSource cancelRequest:lastRequestId];
		self.loadingCell = nil;

		if (tableView.dragging || tableView.decelerating) {
			needsLoadingView = YES;
		} else {
			if (loadingView == nil) {
				needsLoadingView = NO;
				loadingView = [LoadingView loadingViewInView:tableView withBorder:NO];
			}
		}

		UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
		selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
		if (segmentedControl.selectedSegmentIndex == 0) {
			lastRequestId = [(HttpRumorDataSource *)dataSource requestWhatsNewRumorNodesNotifyDelegate:self];
		} else {
			lastRequestId = [(HttpRumorDataSource *)dataSource requestTop25RumorNodesNotifyDelegate:self];
		}
	}
}

- (void)receiveRumorNodes:(NSArray *)theRumorNodes withResult:(NSInteger)theResult
{
	@synchronized(self) {
		needsLoadingView = NO;
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		if (theRumorNodes != nil && [theRumorNodes count] > 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		} else {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		}
		[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
	[self performSelectorOnMainThread:@selector(scrollToTop) withObject:nil waitUntilDone:NO];
	[tableView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

@end
