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
#import "DebunkedAppDelegate.h"
#import "Rumor.h"
#import "CategoryTableViewController.h"
#import "NSWebViewURLRequest.h"


@implementation RumorViewController

- (RumorDataSource *)rumorDataSource
{
    return (RumorDataSource *)self.dataSource;
}

- (UIScrollView *)scrollView
{
    return webView.scrollView;
}

- (void)dealloc
{
    webView.delegate = nil;
    [webView release];

    [super dealloc];
}

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super initWithUrl:theUrl]) {
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        BOOL canEmail = (mailClass != nil && [mailClass canSendMail]);

        Class printClass = (NSClassFromString(@"UIPrintInteractionController"));
        BOOL canPrint = (printClass != nil && [printClass isPrintingAvailable]);

        NSMutableArray* buttons = [NSMutableArray array];

        if (ENABLE_BROWSE_BUTTON && (canPrint || canEmail)) {
            NSArray *segmentContent = @[[UIImage imageNamed:@"share.png"], [UIImage imageNamed:@"browse.png"]];
            UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentContent] autorelease];
            segmentedControl.momentary = YES;
            [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
            [buttons addObject:[[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease]];
        } else if (ENABLE_BROWSE_BUTTON) {
            [buttons addObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browse.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleBrowseButton)] autorelease]];
        } else if (canPrint || canEmail) {
            [buttons addObject:[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButton)] autorelease]];
        }

        [self.navigationItem setRightBarButtonItems:buttons];
    }
    return self;
}

- (void)viewDidLoad
{
    if (self.dataSource == nil) {
        self.dataSource = [[[RumorDataSource alloc] init] autorelease];
    }

    [super viewDidLoad];

    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    @synchronized(self) {
        if (!isWebViewLoaded && !webView.isLoading) {
            [self reloadDataSource];
        }
    }

    [super viewWillAppear:animated];
}

- (void)reloadDataSource
{
    @synchronized(self) {
        [super reloadDataSource];
        lastRequestId = [self.rumorDataSource requestRumor:self.url notifyDelegate:self];
    }
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
		printInfo.jobName = self.rumorDataSource.rumor.title;
		printer.printInfo = printInfo;
		printer.delegate = self;

		printer.printFormatter = [webView viewPrintFormatter];

		[printer presentAnimated:YES completionHandler:nil];

	} else if (buttonIndex == emailIndex) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;

		[picker setSubject:self.rumorDataSource.rumor.title];

		NSString *emailBody = @"Check out this story I found on \"Debunked: Urban Legends Revealed\":\n\n";
		emailBody = [emailBody stringByAppendingString:self.rumorDataSource.rumor.url];
		[picker setMessageBody:emailBody isHTML:NO];

		[self presentViewController:picker animated:YES completion:nil];
		[picker release];
	}
}

- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController
{
	NSURL *baseUrl = [NSURL URLWithString:self.rumorDataSource.rumor.url];
	[webView loadHTMLString:self.rumorDataSource.rumor.rawHtml baseURL:baseUrl];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (void)receive:(id)theItem
{
	Rumor *theRumor = (Rumor *)theItem;
    if (theRumor == nil) {
        [webView loadHTMLString:@"" baseURL:[NSURL URLWithString:@""]];
    } else {
        [webView loadHTMLString:theRumor.rawHtml baseURL:[NSURL URLWithString:theRumor.url]];
    }
    [super receive:theItem];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    isWebViewLoaded = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    isWebViewLoaded = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSWebViewURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		BOOL isRumor = NO;
        BOOL isCategory = NO;
		NSString *absoluteString = [[request URL] absoluteString];
		if ([absoluteString hasPrefix:@"http://"] || [absoluteString hasPrefix:@"https://"]) {

			if ([absoluteString hasPrefix:@"http://www.snopes.com"] ||
				[absoluteString hasPrefix:@"https://www.snopes.com"] ||
				[absoluteString hasPrefix:@"http://snopes.com"] ||
				[absoluteString hasPrefix:@"https://snopes.com"])
            {
				NSString *path = [[request URL] path];
				if (![path hasPrefix:@"/sources/"] &&
                    ![path hasPrefix:@"sources/"] &&
					([path hasSuffix:@"asp"] || [path hasSuffix:@"htm"] || [path hasSuffix:@"html"]))
                {
					isRumor = YES;
                } else if ([path hasPrefix:@"/category/"] ||
                           [path hasPrefix:@"category/"] ||
                           [path hasPrefix:@"/tag/"] ||
                           [path hasPrefix:@"tag/"])
                {
                    isCategory = YES;
                }
			}

		}
		if (isRumor) {
            RumorViewController *rumorController = [[[[self class] alloc] initWithUrl:absoluteString] autorelease];
			[[self navigationController] pushViewController:rumorController animated:YES];
        } else if (isCategory) {
            CategoryTableViewController *categoryController = [[[CategoryTableViewController alloc] initWithUrl:absoluteString] autorelease];
            [[self navigationController] pushViewController:categoryController animated:YES];
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];
		}
		return NO;
    }
    return YES;
}

@end
