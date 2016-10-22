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

#import "DataSourceFactory.h"
#import "HttpCategoryDataSource.h"
#import "HttpRumorDataSource.h"
#import "CategoryTableViewController.h"
#import "RumorTableViewController.h"
#import "MostViewedTableViewController.h"
#import "SearchTableViewController.h"
#import "RandomViewController.h"
#import "WebBrowserViewController.h"
#import "DebunkedAppDelegate.h"


//// UITabBarController+Rotation.h
//@interface UITabBarController (rotation)
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
//@end
//
//// UITabBarController+Rotation.m
//// #import "UITabBarController+Rotation.h"
//
//@implementation UITabBarController (rotation)
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
//						 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//						 interfaceOrientation == UIInterfaceOrientationPortrait);
//	return shouldRotate;
//}
//@end
//
//
//// UINavigationController+Rotation.h
//@interface UINavigationController (rotation)
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
//@end
//
//// UINavigationController+Rotation.m
//// #import "UINavigationController+Rotation.h"
//
//@implementation UINavigationController (rotation)
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
//                         interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//                         interfaceOrientation == UIInterfaceOrientationPortrait);
//    return shouldRotate;
//}
//@end


@implementation DebunkedAppDelegate

@synthesize tabBarController;
@synthesize mainWindow;


- init {
	if (self = [super init]) {
		mainWindow = nil;
		tabBarController = nil;
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [self setupUserInterface];
	[mainWindow makeKeyAndVisible];
}

- (void)setupUserInterface {
	mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tabBarController = [[UITabBarController alloc] init];
	
	[DataSourceFactory setRumorDataSourceClass:[HttpRumorDataSource class]];
	[DataSourceFactory setCategoryDataSourceClass:[HttpCategoryDataSource class]];
	
	NSMutableArray *localViewControllers = [[NSMutableArray alloc] initWithCapacity:4];
	
	UINavigationController *localNavigationController;
	UIViewController *localViewController;
	NSObject<AsynchronousDataSource> *localDataSource;
	
	//======== Most Viewed =========
	localDataSource = [[[DataSourceFactory rumorDataSourceClass] alloc] init];
	localViewController = [[MostViewedTableViewController alloc] initWithDataSource:localDataSource];
	[localDataSource release];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostViewed tag:0] autorelease];
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	//======== Categories =========
	localViewController = [[CategoryTableViewController alloc] init];
	localViewController.title = @"Categories";
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"categories_tabitem.png"];
	localNavigationController.tabBarItem.title = @"Categories";
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	//======== Browse =========
	localViewController = [[WebBrowserViewController alloc] initWithUrl:@"http://www.snopes.com"];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"browse_tabitem.png"];
	localNavigationController.tabBarItem.title = @"Browse";
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	//======== Search =========
	localDataSource = [[[DataSourceFactory searchDataSourceClass] alloc] init];
	localViewController = [[SearchTableViewController alloc] initWithDataSource:localDataSource];
	[localDataSource release];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	//======== Random =========
	localDataSource = [[[DataSourceFactory rumorDataSourceClass] alloc] init];
	localViewController = [[RandomViewController alloc] initWithDataSource:(NSObject<RumorDataSource> *)localDataSource];
	[localDataSource release];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"random_tabitem.png"];
	localNavigationController.tabBarItem.title = @"Random";
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	tabBarController.viewControllers = localViewControllers;
	[localViewControllers release];
	
	mainWindow.rootViewController = tabBarController;
}

- (void)dealloc {
    [tabBarController release];
    [mainWindow release];

    [super dealloc];
}

@end

