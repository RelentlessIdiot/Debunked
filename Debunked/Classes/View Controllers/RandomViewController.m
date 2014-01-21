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

#import "RandomViewController.h"


@implementation RandomViewController

- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource withRumor:(Rumor *)theRumor
{
	if (self = [super initWithDataSource:theDataSource withRumor:theRumor]) {
		lastRequestId = 0;

		UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] init] autorelease];
		backButton.title = @"Back";
		self.navigationItem.backBarButtonItem = backButton;
		self.navigationItem.hidesBackButton = NO;
		
		UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] init] autorelease];
		nextButton.style = UIBarButtonItemStyleBordered;
		nextButton.title = @"Random";
		nextButton.target = self;
		nextButton.action = @selector(onNextButtonClick);
		
		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);
		
		Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
		BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);
		
		if (canPrint || canEmail) {
			NSArray *segmentContent = [NSArray arrayWithObjects:
									   [UIImage imageNamed:@"share.png"],
									   [UIImage imageNamed:@"browse.png"], 
									   nil];
			UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentContent];
			segmentedControl.momentary = YES;
			segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
			segmentedControl.frame = CGRectMake(0, 0, 72, 32);
			[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
			
			UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
			
			self.toolbar = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 154, 44)];
			self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			
			NSMutableArray* buttons = [[NSMutableArray alloc] init];
			[buttons addObject:shareButtonItem];
			[buttons addObject:nextButton];
			[(TransparentToolbar *)self.toolbar setItems:buttons animated:NO];

			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
		} else {
			UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(handleBrowseButton)];
			
			self.toolbar = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0, 0, 130, 44)];
			self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			
			NSMutableArray* buttons = [[NSMutableArray alloc] init];
			[buttons addObject:shareButtonItem];
			[buttons addObject:nextButton];
			[(TransparentToolbar *)self.toolbar setItems:buttons animated:NO];
			
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
		}
	}
	return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect frame = [self.toolbar frame];
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		frame.size.height = 44;
	} else {
		frame.size.height = 32;
	}
	[self.toolbar setFrame:frame];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.hasRumor) {
		lastRequestId = [dataSource requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)self];
		self.hasRumor = YES;
	}
	
	CGRect frame = [self.toolbar frame];
	if ([self interfaceOrientation] == UIInterfaceOrientationPortrait) {
		frame.size.height = 44;
	} else {
		frame.size.height = 32;
	}
	[self.toolbar setFrame:frame];
	
	@synchronized(self) {
		if (hasRumor && rumor == nil && loadingView == nil) {
			loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
		}
	}
	
	[self performSelectorOnMainThread:@selector(updateWebView) withObject:nil waitUntilDone:NO];
	
	// Don't call super because it resizes the toolbar incorrectly for this view.
	//[super viewWillAppear:animated];
}
- (void)onNextButtonClick
{
	[self performSelectorOnMainThread:@selector(loadRumorView) withObject:nil waitUntilDone:NO];
}

- (void)loadRumorView
{
	RandomViewController *randomViewController = [[RandomViewController alloc] initWithDataSource:dataSource];
	[[self navigationController] pushViewController:randomViewController animated:YES];
	[randomViewController release];
}

@end
