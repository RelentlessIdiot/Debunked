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

#import "DataConsumer.h"
#import "Blacklist.h"
#import "RumorNode.h"
#import "TFHpple.h"


@implementation DataConsumer

@synthesize requestId;
@synthesize url;
@synthesize targetUrl;
@synthesize dataSource;

- (id)initWithRequestId:(NSInteger)theRequestId
         withDataSource:(AsynchronousDataSource *)theDataSource
                withUrl:(NSString *)theUrl
{
    if(self = [super init]) {
        self.requestId = theRequestId;
        self.url = theUrl;
        self.targetUrl = theUrl;
        self.dataSource = theDataSource;
    }
    return self;
}

- (void)dealloc
{
    [url release];
    [targetUrl release];
    [dataSource release];

    [super dealloc];
}

- (NSWebViewURLRequest *)request
{
	NSURL *urlObject = [NSURL URLWithString:[self url]];
	return [NSWebViewURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
}

- (NSWebViewURLRequest *)targetRequest
{
	if ([self targetUrl] == nil) {
		return [self request];
	}
	NSURL *urlObject = [NSURL URLWithString:[self targetUrl]];
	return [NSWebViewURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
}

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	[self doesNotRecognizeSelector:_cmd];
}

- (NSString *)resolveUrl:(NSString *)urlString
{
    if([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        return urlString;
    } else if([urlString hasPrefix:@"/"]) {
        return [@"http://www.snopes.com" stringByAppendingString:urlString];
    } else {
        NSURL *urlObject = [NSURL URLWithString:[self targetUrl]];
        NSString *absoluteUrl = [urlObject absoluteString];
        NSString *pathComponent = [[absoluteUrl componentsSeparatedByString:@"/"] lastObject];
        absoluteUrl = [absoluteUrl substringToIndex:[absoluteUrl length] - [pathComponent length]];
        absoluteUrl = [absoluteUrl stringByAppendingString:urlString];
        return absoluteUrl;
    }
}

@end
