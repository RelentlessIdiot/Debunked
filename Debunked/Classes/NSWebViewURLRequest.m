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

#import "NSWebViewURLRequest.h"


@implementation NSWebViewURLRequest

static NSString *webViewUserAgentInstance;
+ (NSString *)webViewUserAgent {
    if(webViewUserAgentInstance == NULL) {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        webViewUserAgentInstance = [NSString stringWithString:[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
        [webViewUserAgentInstance retain];
        [webView release];
    }
    return webViewUserAgentInstance;
}

+ (id)requestWithURL:(NSURL *)theURL {
    NSWebViewURLRequest *request = [[NSWebViewURLRequest alloc] initWithURL:theURL];
    [request autorelease];
    return request;
}

- (id)initWithURL:(NSURL *)theURL {
	if (self = [super initWithURL:theURL]) {
        [self setValue:[NSWebViewURLRequest webViewUserAgent] forHTTPHeaderField:@"User-Agent"];
	}
	return self;
}

+ (id)requestWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSWebViewURLRequest *request = [[NSWebViewURLRequest alloc] initWithURL:theURL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    [request autorelease];
    return request;
}

- (id)initWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
	if (self = [super initWithURL:theURL cachePolicy:cachePolicy timeoutInterval:timeoutInterval]) {
        [self setValue:[NSWebViewURLRequest webViewUserAgent] forHTTPHeaderField:@"User-Agent"];
	}
	return self;
}

@end
