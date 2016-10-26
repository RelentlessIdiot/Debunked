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

- (void)dealloc
{
    webView.delegate = nil;
    [webView release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.webView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.webView];
}

- (void)loadRequest:(NSWebViewURLRequest *)request
{
    self.title = @"Loading...";
    [webView loadRequest:request];
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

@end
