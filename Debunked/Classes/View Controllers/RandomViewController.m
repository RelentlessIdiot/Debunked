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

#import "RandomViewController.h"


@implementation RandomViewController

- (id)initWithDataSource:(RumorDataSource *)theDataSource withRumor:(Rumor *)theRumor
{
	if (self = [super initWithDataSource:theDataSource withRumor:theRumor]) {
		lastRequestId = 0;

		UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] init] autorelease];
		nextButton.style = UIBarButtonItemStylePlain;
		nextButton.title = @"Random";
		nextButton.target = self;
		nextButton.action = @selector(onNextButtonClick);

        NSMutableArray* buttons = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
        [buttons insertObject: nextButton atIndex:0];
        [self.navigationItem setRightBarButtonItems:buttons];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.hasRumor) {
		lastRequestId = [self.dataSource requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)self];
		self.hasRumor = YES;
	}

	@synchronized(self) {
		if (self.hasRumor && self.rumor == nil && self.loadingView == nil) {
			self.loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
		}
	}

	[self performSelectorOnMainThread:@selector(updateWebView) withObject:nil waitUntilDone:NO];

	[super viewWillAppear:animated];
}

- (void)onNextButtonClick
{
	[self performSelectorOnMainThread:@selector(loadRumorView) withObject:nil waitUntilDone:NO];
}

- (void)loadRumorView
{
	RandomViewController *randomViewController = [[RandomViewController alloc] initWithDataSource:self.dataSource];
	[[self navigationController] pushViewController:randomViewController animated:YES];
	[randomViewController release];
}

@end
