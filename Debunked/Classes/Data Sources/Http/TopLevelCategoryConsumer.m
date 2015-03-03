//  Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
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

#import "TopLevelCategoryConsumer.h"


@implementation TopLevelCategoryConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<CategoryDelegate> *)theDelegate 
		withDataSource:(NSObject<CategoryDataSource> *)theDataSource
{
	if(self = [super init]) {
		self.url = @"http://www.snopes.com/info/whatsnew.asp";
		self.targetUrl = @"http://www.snopes.com/info/whatsnew.asp";
		self.delegate = theDelegate;
		self.dataSource = theDataSource;
	}
	return self;
}

- (NSWebViewURLRequest *)request
{
	NSString *urlString = self.url;
	NSURL *urlObject = [NSURL URLWithString:urlString];
	return [NSWebViewURLRequest requestWithURL:urlObject cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
}

- (NSWebViewURLRequest *)targetRequest
{
	return [self request];
}

- (NSString *)resolveUrl:(NSString *)urlString
{
	if([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
		return urlString;
	} else if([urlString hasPrefix:@"/"]) {
		return [@"http://www.snopes.com" stringByAppendingString:urlString];
	} else {
		return [@"http://www.snopes.com/" stringByAppendingString:urlString];
	}	
}

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];
		NSArray *links  = [parser search:@"//td[@class=\"navColumn\"]//div[@class=\"navHeader\"]/following-sibling::ul//a"];

		NSMutableArray *categoryNodes = [NSMutableArray array];
		
		@try {
			for (int i = 0; i < [links count]; i+=1) {
				TFHppleElement *link = [links objectAtIndex:i];
				NSString *href = [self resolveUrl:[link objectForKey:@"href"]];
				NSString *label = [link content];

				if (![Blacklist isBlacklisted:href]) {
					CategoryNode *categoryNode = [[CategoryNode alloc] initWithUrl:href
																		 withLabel:label
																	  withSynopsis:@""];

					[categoryNodes addObject:categoryNode];
					[categoryNode release];
				}
			}
			[self.dataSource loadCategoryNodes:categoryNodes];
			[self.delegate receiveCategoryNodes:categoryNodes withResult:0];
		}
		@catch (NSException *exception) {
			[self.delegate receiveCategoryNodes:categoryNodes withResult:1];
		}
	}
	@catch (NSException *exception) {
		[self.delegate receiveCategoryNodes:nil withResult:1];
	}
	@finally {
		[parser release];
	}
		

}

- (void)dealloc {
	[delegate release];
	[dataSource release];
	
	[super dealloc];
}

@end
