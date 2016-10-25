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

#import "RumorViewController.h"


#define SECTION_VERACITY 0
#define SECTION_CLAIM 1
#define SECTION_ORIGIN 2
#define SECTION_SIGHTINGS 3
#define SECTION_EXAMPLES 4
#define SECTION_VARIATIONS 5
#define SECTION_LASTUPDATED 6
#define SECTION_SOURCES 7

@implementation RumorViewController

@synthesize dataSource;
@synthesize webView;
@synthesize loadingView;
@synthesize hasRumor;
@synthesize isRendered;
@synthesize receivedMemoryWarning;

-(void) setRumor:(Rumor *)theRumor
{
	if (rumor != theRumor) {
		[rumor release];
		rumor = [theRumor retain];

		if (self.rumor != nil && ![self.rumor isEqual:@""]) {
			[self.navigationItem performSelectorOnMainThread:@selector(setTitle:) withObject:self.rumor.title waitUntilDone:NO];
			[self performSelectorOnMainThread:@selector(updateWebView) withObject:nil waitUntilDone:NO];
		}
	}
	self.hasRumor = (rumor != nil);
	[self performSelectorOnMainThread:@selector(removeLoadingView) withObject:nil waitUntilDone:YES];
}

- (Rumor *) rumor
{
	return rumor;
}

- (id)init
{
	return [self initWithRumor:nil];
}

- (id)initWithRumor:(Rumor *)theRumor
{
	return [self initWithDataSource:nil withRumor:theRumor];
}

- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource
{
	return [self initWithDataSource:theDataSource withRumor:nil];
}

- (id)initWithDataSource:(NSObject<RumorDataSource> *)theDataSource withRumor:(Rumor *)theRumor
{
    if (self = [super init]) {
        self.dataSource = theDataSource;
		self.rumor = theRumor;

		if (self.rumor != nil && ![self.rumor isEqual:@""]) {
			self.title = self.rumor.title;
		}

        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);

        Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
        BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);

        NSMutableArray* buttons = [NSMutableArray array];

        if (ENABLE_BROWSE_TAB && (canPrint || canEmail)) {
            NSArray *segmentContent = @[[UIImage imageNamed:@"share.png"], [UIImage imageNamed:@"browse.png"]];
            UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentContent] autorelease];
            segmentedControl.momentary = YES;
            [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            [buttons addObject:[[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease]];
        } else if (ENABLE_BROWSE_TAB) {
            [buttons addObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)] autorelease]];
        } else if (canPrint || canEmail) {
            [buttons addObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButton)] autorelease]];
        }

        [self.navigationItem setRightBarButtonItems:buttons];
	}
	return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSInteger printIndex = 1;
	NSInteger emailIndex = 0;

	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);

	Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
	BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);

	if (canEmail) {
		if (canPrint) {
			printIndex = 1;
			emailIndex = 0;
		} else {
			printIndex = -1;
			emailIndex = 0;
		}
	} else if (canPrint) {
		printIndex = 0;
		emailIndex = -1;
	}

	if (buttonIndex == printIndex) {
		UIPrintInteractionController *printer = [printClass sharedPrintController];
		Class printInfoClass = (NSClassFromString(@"UIPrintInfo"));
		UIPrintInfo *printInfo = [printInfoClass printInfo];
		printInfo.jobName = self.rumor.title;
		printer.printInfo = printInfo;
		printer.delegate = self;

		printer.printFormatter = [self.webView viewPrintFormatter];

		[printer presentAnimated:YES completionHandler:nil];

	} else if (buttonIndex == emailIndex) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;

		[picker setSubject:self.rumor.title];

		NSString *emailBody = @"Check out this story I found on \"Debunked: Urban Legends Revealed\":\n\n";
		emailBody = [emailBody stringByAppendingString:self.rumor.url];
		[picker setMessageBody:emailBody isHTML:NO];

		[self presentViewController:picker animated:YES completion:nil];
		[picker release];
	}
}

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController
{
	NSURL *baseUrl = [NSURL URLWithString:self.rumor.url];
	[self.webView loadHTMLString:self.rumor.rawHtml baseURL:baseUrl];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView
{
	// Create a custom view hierarchy.
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	appFrame.origin.x = 0;
	appFrame.origin.y = 0;
	UIView *view = [[UIView alloc] initWithFrame:appFrame];
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.view = view;
	[view release];


	CGRect webFrame = [self.view frame];
	webFrame.origin.x = 0;
	webFrame.origin.y = 0;
	webView = [[UIWebView alloc] initWithFrame:webFrame];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	webView.dataDetectorTypes = UIDataDetectorTypeNone;
	webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	webView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:webView];
}

- (void)segmentAction:(id)sender
{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	if (segmentedControl.selectedSegmentIndex == 0) {
		[self handleShareButton];
	} else {
		[self handleBrowseButton];
	}
}

- (void)handleBrowseButton
{	if (self.rumor != nil) {
		DebunkedAppDelegate *appDelegate = (DebunkedAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.tabBarController setSelectedIndex:2];
		UINavigationController *navController = (UINavigationController *)[[appDelegate.tabBarController viewControllers] objectAtIndex:2];
		WebBrowserViewController *webBrowser = (WebBrowserViewController *)[navController topViewController];
		[webBrowser loadUrl:self.rumor.url];
	}
}

- (void)handleShareButton
{
	UIActionSheet *actionSheet;

	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);

	Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
	BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);

	if (canEmail) {
		if (canPrint) {
			actionSheet = [[UIActionSheet alloc] initWithTitle: nil
													  delegate: self
											 cancelButtonTitle: @"Cancel"
										destructiveButtonTitle: nil
											 otherButtonTitles: @"Email Article", @"Print", nil];
		} else {
			actionSheet = [[UIActionSheet alloc] initWithTitle: nil
													  delegate: self
											 cancelButtonTitle: @"Cancel"
										destructiveButtonTitle: nil
											 otherButtonTitles: @"Email Article", nil];
		}
	} else if (canPrint) {
		actionSheet = [[UIActionSheet alloc] initWithTitle: nil
												  delegate: self
										 cancelButtonTitle: @"Cancel"
									destructiveButtonTitle: nil
										 otherButtonTitles: @"Print Article", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle: nil
												  delegate: self
										 cancelButtonTitle: @"Cancel"
									destructiveButtonTitle: nil
										 otherButtonTitles: nil];
    }

	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.parentViewController.tabBarController.view];
	[actionSheet release];
}

- (void)removeLoadingView
{
	[loadingView removeView];
	loadingView = nil;
}

- (void)updateWebView {
	if (self.webView && !self.isRendered && self.rumor != nil && ![self.rumor isEqual:@""]) {
		if (self.rumor.rawHtml != nil && ![self.rumor.rawHtml isEqual:@""]) {
			self.isRendered = YES;
			NSURL *baseUrl = [NSURL URLWithString:self.rumor.url];
			[self.webView loadHTMLString:self.rumor.rawHtml baseURL:baseUrl];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
	@synchronized(self) {
		if (hasRumor && rumor == nil && loadingView == nil) {
			loadingView = [LoadingView loadingViewInView:self.view withBorder:NO];
		}
	}

	[self performSelectorOnMainThread:@selector(updateWebView) withObject:nil waitUntilDone:NO];

	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
	self.receivedMemoryWarning = YES;
	self.isRendered = NO;
	[super didReceiveMemoryWarning];
}

- (void)receive:(id)theItem withResult:(NSInteger)theResult
{
	Rumor *theRumor = (Rumor *)theItem;
	self.rumor = theRumor;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSWebViewURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		BOOL isRumor = NO;
		NSString *absoluteString = [[request URL] absoluteString];
		if ([absoluteString hasPrefix:@"http://"] ||
			[absoluteString hasPrefix:@"https://"]) {

			if ([absoluteString hasPrefix:@"http://www.snopes.com"] ||
				[absoluteString hasPrefix:@"https://www.snopes.com"] ||
				[absoluteString hasPrefix:@"http://snopes.com"] ||
				[absoluteString hasPrefix:@"https://snopes.com"]) {

				NSString *path = [[request URL] path];
				if (![path hasPrefix:@"/sources/"] && ![path hasPrefix:@"sources/"] &&
					([path hasSuffix:@"asp"] || [path hasSuffix:@"htm"] || [path hasSuffix:@"html"])) {

					isRumor = YES;
				}
			}

		}
		if (isRumor) {
			Class rumorDataSourceClass = [DataSourceFactory rumorDataSourceClass];
			NSObject<RumorDataSource> *rumorDataSource = [[[rumorDataSourceClass alloc] init] autorelease];

			RumorViewController *rumorViewController = [[[self class] alloc] initWithDataSource:rumorDataSource];
			rumorViewController.hasRumor = YES;
			[[self navigationController] pushViewController:rumorViewController animated:YES];
			[rumorDataSource requestRumor:absoluteString notifyDelegate:(NSObject<RumorDelegate> *)rumorViewController];

			[rumorViewController release];
		} else {
			WebViewController *webViewController = [[WebViewController alloc] init];
			[[self navigationController] pushViewController:webViewController animated:YES];
			[webViewController loadRequest:request];
			[webViewController release];
		}
		return NO;
    }
    return YES;
}

- (void)dealloc {
	[rumor release];
	webView.delegate = nil;
	[webView release];
    [dataSource release];

    [super dealloc];
}


@end

