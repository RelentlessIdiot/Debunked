//  Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
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

#import "SearchTableViewController.h"
#import "RumorViewController.h"
#import "SearchResultView.h"
#import "HttpSearchDataSource.h"


@implementation SearchTableViewController

@synthesize searchBar;
@synthesize hideButton;

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SearchResultView preferredHeight];
}

- (void)loadView {
	[super loadView];
	
	[tableView setDelegate:self];
	
	if ([self.dataSource tableView:self.tableView numberOfRowsInSection:0] == 0) {
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	} else {
		tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	}
	
	UIView *hackView = [[UIView alloc] initWithFrame:CGRectZero];
	UIBarButtonItem *hackItem = [[UIBarButtonItem alloc] initWithCustomView:hackView];      
	self.navigationItem.backBarButtonItem = hackItem;
	[hackView release];
	[hackItem release];
	self.navigationItem.hidesBackButton = YES;
	
	hackView = [[UIView alloc] initWithFrame:CGRectZero];
	hackItem = [[UIBarButtonItem alloc] initWithCustomView:hackView];      
	self.navigationItem.leftBarButtonItem = hackItem;
	[hackView release];
	[hackItem release];
	
	hackView = [[UIView alloc] initWithFrame:CGRectZero];
	hackItem = [[UIBarButtonItem alloc] initWithCustomView:hackView];      
	self.navigationItem.rightBarButtonItem = hackItem;
	[hackView release];
	[hackItem release];
	
	CGRect frame = [tableView frame];
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait) {
		frame.size.height = 44.0;
	} else {
		frame.size.height = 32.0;
	}
	searchBar = [[[UISearchBar alloc] initWithFrame:frame] autorelease];
	searchBar.delegate = self;
	searchBar.showsCancelButton = NO;
	searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.navigationItem.titleView = searchBar;
	
	CGRect fullscreenFrame = [[UIScreen mainScreen] applicationFrame];
	fullscreenFrame.origin.x = 0;
	fullscreenFrame.origin.y = 0;
	hideButton = [[[UIButton alloc] initWithFrame:fullscreenFrame] autorelease];
	hideButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	hideButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	hideButton.hidden = YES;
	[hideButton addTarget: self action:@selector(hideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:hideButton];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect frame = [tableView frame];
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		frame.size.height = 44.0;
	} else {
		frame.size.height = 32.0;
	}
	[searchBar setFrame:frame];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillAppear:(BOOL)animated
{
	CGRect frame = [tableView frame];
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait) {
		frame.size.height = 44.0;
	} else {
		frame.size.height = 32.0;
	}
	[searchBar setFrame:frame];
	
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

- (void)hideButtonClicked
{
	[searchBar resignFirstResponder];
}

- (void)resizeHideButton
{
    CGRect frame = [hideButton frame];
    frame.size.height = MAX(tableView.contentSize.height, tableView.frame.size.height);
    [hideButton setFrame:frame];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
	
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar
{
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
	[hideButton setHidden:NO];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)theSearchBar
{
	return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
{
	[hideButton setHidden:YES];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)theSearchBar
{
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
	[searchBar resignFirstResponder];
	
	@synchronized(self) {
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		if (tableView.dragging || tableView.decelerating) {
			needsLoadingView = YES;
		} else {
			if (loadingView == nil) {
				needsLoadingView = NO;
				loadingView = [LoadingView loadingViewInView:[self view] withBorder:NO];
			}
		}
		
		lastRequestId = [(HttpSearchDataSource *)dataSource requestSearchResults:[searchBar text] notifyDelegate:self];
	}
}

- (void)searchBar:(UISearchBar *)theSearchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	
}

- (void)receiveSearchResults:(NSArray *)theSearchResults withResult:(NSInteger)theResult
{
	@synchronized(self) {
		needsLoadingView = NO;
		[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
		if (theSearchResults != nil && [theSearchResults count] > 0) {
			self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		}
		[tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(resizeHideButton) withObject:nil waitUntilDone:YES];
	}
	[self performSelectorOnMainThread:@selector(scrollToTop) withObject:nil waitUntilDone:NO];
	[tableView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
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

- (void)dealloc {
	[searchBar release];
    [super dealloc];
}

@end
