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
#import "DebunkedAppDelegate.h"
#import "WebBrowserViewController.h"
#import "RumorDataSource.h"


@implementation MostViewedTableViewController

@synthesize segmentedControl;

- (NSString *)url
{
    if (segmentedControl.selectedSegmentIndex == 0) {
        return @"http://www.snopes.com/info/whatsnew.asp";
    } else {
        return @"http://www.snopes.com/info/top25uls.asp";
    }
}

- (void)dealloc
{
    [segmentedControl release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"What's New", @"Top 25"]];
	self.segmentedControl.selectedSegmentIndex = 0;
	self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.titleView = segmentedControl;
}

- (void)handleBrowseButton
{
	DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.tabBarController setSelectedIndex:2];
	UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
	WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
    [webBrowser loadUrl:self.url];
}

- (void)segmentAction:(id)sender
{
    [self reloadDataSource];
}

@end
