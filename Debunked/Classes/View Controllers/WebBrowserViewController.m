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

#import "WebBrowserViewController.h"


@implementation WebBrowserViewController

@synthesize webView;
@synthesize addressBar;
@synthesize navBar;
@synthesize url;
@synthesize hideButton;
@synthesize receivedMemoryWarning;

- (id)init
{
	return [self initWithUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl
{
    if (self = [super init]) {
		self.url = theUrl;
    }
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	BOOL shouldRotate = (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
						 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
						 interfaceOrientation == UIInterfaceOrientationPortrait);
	return shouldRotate;
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

	UIView *hackView = [[UIView alloc] initWithFrame:CGRectZero];
	UIBarButtonItem *hackItem = [[UIBarButtonItem alloc] initWithCustomView:hackView];
	self.navigationItem.backBarButtonItem = hackItem;
	[hackView release];
	[hackItem release];
	self.navigationItem.hidesBackButton = YES;

	hackView = [[UIView alloc] initWithFrame:CGRectZero];
	hackItem = [[UIBarButtonItem alloc] initWithCustomView:hackView];
	self.navigationItem.rightBarButtonItem = hackItem;
	[hackView release];
	[hackItem release];

	self.addressBar = [[UITextField alloc] init];
	self.addressBar.frame = CGRectMake(0, 0, 480, 32);
	self.addressBar.delegate = self;
	self.addressBar.textAlignment = NSTextAlignmentLeft;
	self.addressBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.addressBar.borderStyle = UITextBorderStyleRoundedRect;
	self.addressBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
	self.addressBar.returnKeyType = UIReturnKeyGo;
	self.addressBar.keyboardType = UIKeyboardTypeURL;
	self.addressBar.clearButtonMode = UITextFieldViewModeWhileEditing;
	self.addressBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.addressBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.navigationItem.titleView = self.addressBar;

	if (self.url != nil) {
		[webView loadRequest:[NSWebViewURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
		self.addressBar.text = self.url;
	}

	NSArray *segmentContent = [NSArray arrayWithObjects:
							   [UIImage imageNamed:@"back.png"],
							   [UIImage imageNamed:@"forward.png"],
							   nil];
	self.navBar = [[UISegmentedControl alloc] initWithItems:segmentContent];
	self.navBar.momentary = YES;
	self.navBar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.navBar.frame = CGRectMake(0, 0, 58, 32);
	[self.navBar addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

	[self.navBar setEnabled:webView.canGoBack forSegmentAtIndex:0];
	[self.navBar setEnabled:webView.canGoForward forSegmentAtIndex:1];

	UIBarButtonItem *buttons = [[[UIBarButtonItem alloc] initWithCustomView:self.navBar] autorelease];
	self.navigationItem.leftBarButtonItem = buttons;

	CGRect fullscreenFrame = [view frame];
	hideButton = [[[UIButton alloc] initWithFrame:fullscreenFrame] autorelease];
	hideButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	hideButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	hideButton.hidden = YES;
	[hideButton addTarget: self action:@selector(hideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[[self view] addSubview:hideButton];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (self.receivedMemoryWarning) {
		self.receivedMemoryWarning = NO;
	}

	[super viewWillAppear:animated];
}

- (void)loadUrl:(NSString *)theUrl
{
	self.url = theUrl;
	[webView loadRequest:[NSWebViewURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
	self.addressBar.text = self.url;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSWebViewURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	self.url = [[[theWebView request] URL] absoluteString];
	if (![self.addressBar isEditing]) {
		self.addressBar.text = self.url;
	}
	[self.navBar setEnabled:theWebView.canGoBack forSegmentAtIndex:0];
	[self.navBar setEnabled:theWebView.canGoForward forSegmentAtIndex:1];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
	[self.navBar setEnabled:theWebView.canGoBack forSegmentAtIndex:0];
	[self.navBar setEnabled:theWebView.canGoForward forSegmentAtIndex:1];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)segmentAction:(id)sender
{
	if (self.navBar.selectedSegmentIndex == 0) {
		[self.webView goBack];
	} else if (self.navBar.selectedSegmentIndex == 1) {
		[self.webView goForward];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	NSString *newUrl = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([@"" isEqualToString:newUrl]) {
		textField.text = self.url;
	} else {
		if (![newUrl hasPrefix:@"http://"] && ![newUrl hasPrefix:@"https://"]) {
			newUrl = [@"http://" stringByAppendingString:newUrl];
		}
		[self.webView loadRequest:[NSWebViewURLRequest requestWithURL:[NSURL URLWithString:newUrl]]];
	}
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[hideButton setHidden:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[hideButton setHidden:YES];
	if ([@"" isEqualToString:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ]) {
		textField.text = self.url;
	}
}

- (void)hideButtonClicked
{
	[self.addressBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
	self.receivedMemoryWarning = YES;
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	webView.delegate = nil;
	[webView release];

    [super dealloc];
}


@end
