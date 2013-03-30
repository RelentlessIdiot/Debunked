//  Copyright (c) 2009-2013 Robert Ruana <rob@relentlessidiot.com>
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


// UITabBarController+Rotation.h
@interface UITabBarController (rotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

// UITabBarController+Rotation.m
// #import "UITabBarController+Rotation.h"

@implementation UITabBarController (rotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
						 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
						 interfaceOrientation == UIInterfaceOrientationPortrait);
	return shouldRotate;
}
@end


// UINavigationController+Rotation.h
@interface UINavigationController (rotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

// UINavigationController+Rotation.m
// #import "UINavigationController+Rotation.h"

@implementation UINavigationController (rotation)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
						 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
						 interfaceOrientation == UIInterfaceOrientationPortrait);
	return shouldRotate;
}
@end


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
	[self setupPortraitUserInterface];

	splashView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if([UIScreen mainScreen].bounds.size.height == 568.0f) {
		splashView.image = [UIImage imageNamed:@"Default-568h.png"];
	} else {
		splashView.image = [UIImage imageNamed:@"Default.png"];
	}
	[mainWindow addSubview:splashView];
	[mainWindow bringSubviewToFront:splashView];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:mainWindow cache:YES];
	[UIView setAnimationDelegate:self]; 
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
	splashView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[splashView removeFromSuperview];
	[splashView release];
}

- (void)setupPortraitUserInterface {
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
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	//======== Browse =========
	localViewController = [[WebBrowserViewController alloc] initWithUrl:@"http://www.snopes.com"];
	localViewController.title = @"Browse";
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"browse_tabitem.png"];
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
	localViewController.title = @"Random";
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:localViewController];
	[localViewController release];
	
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"random_tabitem.png"];
	[localViewControllers addObject:localNavigationController];
	[localNavigationController release];
	
	
	tabBarController.viewControllers = localViewControllers;
	[localViewControllers release];
	
    mainWindow.rootViewController = tabBarController;
	[mainWindow makeKeyAndVisible];
}

- (void)dealloc {
    [tabBarController release];
    [mainWindow release];
	
    [super dealloc];
}

@end

