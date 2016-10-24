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

- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource withRumor:(Rumor *)theRumor
{
	if (self = [super initWithDataSource:theDataSource withRumor:theRumor]) {
		lastRequestId = 0;

		UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] init] autorelease];
		backButton.title = @"Back";
		self.navigationItem.backBarButtonItem = backButton;
		self.navigationItem.hidesBackButton = NO;

		UIBarButtonItem *nextButton = [[[UIBarButtonItem alloc] init] autorelease];
		nextButton.style = UIBarButtonItemStylePlain;
		nextButton.title = @"Random";
		nextButton.target = self;
		nextButton.action = @selector(onNextButtonClick);

		Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
		BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);

		Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
		BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);

		if (canPrint || canEmail) {
            UIBarButtonItem *shareButtonItem;
            CGRect toolbarRect;
            if (ENABLE_BROWSE_TAB) {
                toolbarRect = CGRectMake(0, 0, 154, 44);
                NSArray *segmentContent = [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"share.png"],
                                           [UIImage imageNamed:@"browse.png"],
                                           nil];
                UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentContent];
                segmentedControl.momentary = YES;
                segmentedControl.frame = CGRectMake(0, 0, 72, 32);
                [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

                shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
            } else {
                toolbarRect = CGRectMake(0, 0, 106, 44);
                shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButton)];
            }

            self.toolbar = [[TransparentToolbar alloc] initWithFrame:toolbarRect];
            self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;

            NSMutableArray* buttons = [[NSMutableArray alloc] init];
            [buttons addObject:shareButtonItem];
            [buttons addObject:nextButton];
            [(TransparentToolbar *)self.toolbar setItems:buttons animated:NO];

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
		} else {
            CGRect toolbarRect;
            NSMutableArray* buttons = [NSMutableArray array];
            if (ENABLE_BROWSE_TAB) {
                toolbarRect = CGRectMake(0, 0, 130, 44);
                UIBarButtonItem *browseButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)] autorelease];
                [buttons addObject:browseButtonItem];
            } else {
                toolbarRect = CGRectMake(0, 0, 106, 44);
            }
            [buttons addObject:nextButton];
            self.toolbar = [[TransparentToolbar alloc] initWithFrame:toolbarRect];
            self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			[(TransparentToolbar *)self.toolbar setItems:buttons animated:NO];

			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.toolbar];
		}
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!self.hasRumor) {
		lastRequestId = [dataSource requestRandomRumorNotifyDelegate:(NSObject<RumorDelegate> *)self];
		self.hasRumor = YES;
	}

	@synchronized(self) {
		if (hasRumor && rumor == nil && loadingView == nil) {
			loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
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
	RandomViewController *randomViewController = [[RandomViewController alloc] initWithDataSource:dataSource];
	[[self navigationController] pushViewController:randomViewController animated:YES];
	[randomViewController release];
}

@end
