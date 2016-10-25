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

- (void)dealloc
{
    [addressBar release];
    [hideButton release];
    [navBar release];
    [url release];
    webView.delegate = nil;
    [webView release];

    [super dealloc];
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.webView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.webView];

	UIView *hackView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIBarButtonItem *hackItem = [[[UIBarButtonItem alloc] initWithCustomView:hackView] autorelease];
	self.navigationItem.backBarButtonItem = hackItem;
	self.navigationItem.hidesBackButton = YES;

	hackView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	hackItem = [[[UIBarButtonItem alloc] initWithCustomView:hackView] autorelease];
	self.navigationItem.rightBarButtonItem = hackItem;

	self.addressBar = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 480, 32)] autorelease];
	self.addressBar.delegate = self;
	self.addressBar.textAlignment = NSTextAlignmentLeft;
	self.addressBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	self.addressBar.borderStyle = UITextBorderStyleRoundedRect;
	self.addressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
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

	self.navBar = [[[UISegmentedControl alloc] initWithItems:@[[UIImage imageNamed:@"back.png"], [UIImage imageNamed:@"forward.png"]]] autorelease];
	self.navBar.momentary = YES;
	self.navBar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.navBar.frame = CGRectMake(0, 0, 58, 32);
	[self.navBar addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

	[self.navBar setEnabled:webView.canGoBack forSegmentAtIndex:0];
	[self.navBar setEnabled:webView.canGoForward forSegmentAtIndex:1];

	UIBarButtonItem *buttons = [[[UIBarButtonItem alloc] initWithCustomView:self.navBar] autorelease];
	self.navigationItem.leftBarButtonItem = buttons;

	self.hideButton = [[[UIButton alloc] initWithFrame:self.view.bounds] autorelease];
	self.hideButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	self.hideButton.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	self.hideButton.hidden = YES;
	[self.hideButton addTarget: self action:@selector(hideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.hideButton];
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

@end
