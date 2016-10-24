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

#import "AsynchronousTableViewController.h"


@implementation AsynchronousTableViewController

@synthesize loadingView;
@synthesize tableView;
@synthesize dataSource;

- (UITableViewCell *)loadingCell {return loadingCell;}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)removeLoadingView
{
	[loadingView removeView];
	loadingView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
						 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
						 interfaceOrientation == UIInterfaceOrientationPortrait);
	return shouldRotate;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	[tableView reloadData];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)updateLoadingCell:(UITableViewCell *)theLoadingCell
{
	if (loadingCell != nil && ![loadingCell isEqual:theLoadingCell]) {
		NSIndexPath *indexPath = [self.tableView indexPathForCell:loadingCell];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[loadingCell setAccessoryView:nil];
		loadingCell = nil;
	}
	if (theLoadingCell != nil) {
		loadingCell = theLoadingCell;
	}
}

- (void)setLoadingCell:(UITableViewCell *)theLoadingCell
{
	[self performSelectorOnMainThread:@selector(updateLoadingCell:) withObject:theLoadingCell waitUntilDone:YES];
}

- (void)pushViewControllerAnimated:(UIViewController *)viewController
{
	[[self navigationController] pushViewController:viewController animated:YES];
}

- (id)initWithDataSource:(NSObject<AsynchronousDataSource> *)theDataSource
{
	if (self = [self init]) {
		tableView = nil;
		lastRequestId = 0;
		
		// retain the data source
		self.dataSource = theDataSource;
	}
	return self;
}

- (void)receive:(id)theItem withResult:(NSInteger)theResult
{
	
}

- (void)loadView {
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *newTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// set the autoresizing mask so that the table will always fill the view
	newTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the cell separator to a single straight line.
	if (self.dataSource != nil && [self.dataSource tableView:newTableView numberOfRowsInSection:0]) {
		newTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	} else {
		newTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
    newTableView.separatorInset = UIEdgeInsetsZero;
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	newTableView.delegate = self;
	newTableView.dataSource = dataSource;
	
	// set the tableview as the controller view
    self.tableView = newTableView;
	self.view = newTableView;
	[newTableView release];
}

- (void)tableView:(UITableView *)theTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)theIndexPath {	
	[self tableView:theTableView didSelectRowAtIndexPath:theIndexPath];
	[theTableView selectRowAtIndexPath:theIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)theIndexPath {
	@synchronized(self) {
		UITableViewCell *aCell = [theTableView cellForRowAtIndexPath:theIndexPath];
		if (![aCell isEqual:self.loadingCell]) {
			[dataSource cancelRequest:lastRequestId];
			self.loadingCell = aCell;
			lastRequestId = [dataSource requestItemForIndexPath:theIndexPath notifyDelegate:self];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [super viewWillAppear:animated];
}

- (void)scrollToTop {
	[tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)dealloc {
	tableView.delegate = nil;
	tableView.dataSource = nil;
	[tableView release];
	[dataSource release];
	
	[super dealloc];
}

@end
