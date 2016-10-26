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

@synthesize dataSource;
@synthesize loadingView;
@synthesize tableView;
@synthesize url;

- (void)dealloc
{
    tableView.delegate = nil;
    tableView.dataSource = nil;
    [tableView release];
    [dataSource release];
    [url release];

    [super dealloc];
}

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super init]) {
        lastRequestId = 0;
        self.url = theUrl;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = dataSource;

    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.dataSource != nil && [self.dataSource tableView:self.tableView numberOfRowsInSection:0]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{	
	[self.tableView reloadData];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)removeLoadingView
{
    needsLoadingView = NO;
    [loadingView removeView];
    loadingView = nil;
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [self.dataSource cancelRequest:lastRequestId];

        if (self.tableView.dragging || self.tableView.decelerating) {
            needsLoadingView = YES;
        } else if (self.loadingView == nil) {
            needsLoadingView = NO;
            self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
        }
    }
}

- (void)receive:(id)theItem
{
    @synchronized(self) {
        [self removeLoadingView];
        if (self.dataSource != nil && [self.dataSource tableView:self.tableView numberOfRowsInSection:0]) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        } else {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        [self.tableView reloadData];
        [self scrollToTop];
        [self.tableView setNeedsDisplay];
    }
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

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    return [self.dataSource tableView:theTableView heightForRowAtIndexPath:theIndexPath];
}

- (void)tableView:(UITableView *)theTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)theIndexPath
{
	[self tableView:theTableView didSelectRowAtIndexPath:theIndexPath];
	[theTableView selectRowAtIndexPath:theIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    @synchronized(self) {
        NSIndexPath *oldIndexPath = [theTableView indexPathForSelectedRow];
        if (oldIndexPath != nil && ![theIndexPath isEqual:oldIndexPath]) {
            [dataSource cancelRequest:lastRequestId];
        }
    }
    return theIndexPath;
}

- (void)scrollToTop
{
	[tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

@end
