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

#import "WebViewController.h"


@implementation WebViewController

@synthesize webView;

- (id)init
{
    if (self = [super init]) {
		self.title = @"";
    }
	return self;
}

- (void)loadRequest:(NSWebViewURLRequest *)request
{
	self.title = @"Loading...";
	[webView loadRequest:request];
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
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	@try {
		self.title = [theWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
	}
	@catch (NSException * e) {
		self.title = @"";
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.title = @"";
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	webView.delegate = nil;
	[webView release];
    [super dealloc];
}


@end
