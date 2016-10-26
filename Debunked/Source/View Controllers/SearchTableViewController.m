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

#import "SearchTableViewController.h"
#import "RumorViewController.h"
#import "SearchResultTableViewCell.h"
#import "SearchDataSource.h"


@implementation SearchTableViewController

@synthesize searchBar;
@synthesize hideButton;

- (void)dealloc
{
    [hideButton release];
    [searchBar release];

    [super dealloc];
}

- (void)viewDidLoad
{
    if (self.dataSource == nil) {
        self.dataSource = [[[SearchDataSource alloc] init] autorelease];
    }

    [super viewDidLoad];

	UIView *hackView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIBarButtonItem *hackItem = [[[UIBarButtonItem alloc] initWithCustomView:hackView] autorelease];
	self.navigationItem.backBarButtonItem = hackItem;
	self.navigationItem.hidesBackButton = YES;

	hackView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	hackItem = [[[UIBarButtonItem alloc] initWithCustomView:hackView] autorelease];
	self.navigationItem.leftBarButtonItem = hackItem;

	hackView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	hackItem = [[[UIBarButtonItem alloc] initWithCustomView:hackView] autorelease];
	self.navigationItem.rightBarButtonItem = hackItem;

	self.searchBar = [[[UISearchBar alloc] init] autorelease];
	self.searchBar.delegate = self;
	self.searchBar.showsCancelButton = NO;
	self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.navigationItem.titleView = searchBar;

	self.hideButton = [[[UIButton alloc] initWithFrame:self.view.bounds] autorelease];
	self.hideButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.hideButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.hideButton.hidden = YES;
	[self.hideButton addTarget: self action:@selector(hideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:hideButton];
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [super reloadDataSource];

        lastRequestId = [(SearchDataSource *)self.dataSource requestSearchResults:searchBar.text notifyDelegate:self];
    }
}

- (void)hideButtonClicked
{
	[searchBar resignFirstResponder];
}

- (void)resizeHideButton
{
    CGRect frame = [hideButton frame];
    frame.size.height = MAX(self.tableView.contentSize.height, self.tableView.frame.size.height);
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
    [self reloadDataSource];
}

- (void)searchBar:(UISearchBar *)theSearchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{

}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    @synchronized(self) {
        UITableViewCell *cell = [theTableView cellForRowAtIndexPath:theIndexPath];
        if ([cell isKindOfClass: SearchResultTableViewCell.class]) {
            SearchResultTableViewCell *searchResultCell = (SearchResultTableViewCell *)cell;
            RumorViewController *rumorController = [[[RumorViewController alloc] initWithUrl:searchResultCell.searchResult.url] autorelease];
            rumorController.title = searchResultCell.searchResult.title;
            [self performSelectorOnMainThread:@selector(pushViewControllerAnimated:)
                                   withObject:rumorController
                                waitUntilDone:YES];
        } else {
            [theTableView deselectRowAtIndexPath:theIndexPath animated:YES];
        }
    }
}

@end
