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
#import "RumorDataSource.h"


@implementation MostViewedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.delegate = self;

	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:@[@"What's New", @"Top 25"]] autorelease];
	segmentedControl.selectedSegmentIndex = selectedSegmentIndex;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.titleView = segmentedControl;
}

- (void)viewWillAppear:(BOOL)animated
{
	@synchronized(self) {
		if ([[(RumorDataSource *)self.dataSource rumorNodes] count] == 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			if (self.tableView.dragging || self.tableView.decelerating) {
				needsLoadingView = YES;
			} else {
				if (self.loadingView == nil) {
					needsLoadingView = NO;
					self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
				}
			}
			if ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex] == 0) {
				lastRequestId = [(RumorDataSource *)self.dataSource requestWhatsNewRumorNodesNotifyDelegate:self];
			} else {
				lastRequestId = [(RumorDataSource *)self.dataSource requestTop25RumorNodesNotifyDelegate:self];
			}
		}
	}

	[super viewWillAppear:animated];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (needsLoadingView == YES) {
		needsLoadingView = NO;
		if (self.loadingView == nil) {
			self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
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
		[self.dataSource cancelRequest:lastRequestId];
		self.loadingCell = nil;

		if (self.tableView.dragging || self.tableView.decelerating) {
			needsLoadingView = YES;
		} else {
			if (self.loadingView == nil) {
				needsLoadingView = NO;
				self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
			}
		}

		UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
		selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
		if (segmentedControl.selectedSegmentIndex == 0) {
			lastRequestId = [(RumorDataSource *)self.dataSource requestWhatsNewRumorNodesNotifyDelegate:self];
		} else {
			lastRequestId = [(RumorDataSource *)self.dataSource requestTop25RumorNodesNotifyDelegate:self];
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
		[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	}
	[self performSelectorOnMainThread:@selector(scrollToTop) withObject:nil waitUntilDone:NO];
	[self.tableView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

@end
