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

#import "TopLevelCategoryConsumer.h"


@implementation TopLevelCategoryConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<CategoryDelegate> *)theDelegate 
        withDataSource:(CategoryDataSource *)theDataSource
               withUrl:(NSString *)theUrl
{
	if(self = [super init]) {
		self.url = theUrl;
		self.targetUrl = theUrl;
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

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];
		NSArray *links  = [parser search:@"//a[starts-with(@href, '/category/')]"];

		NSMutableArray *categoryNodes = [NSMutableArray array];
		
		@try {
			for (int i = 0; i < [links count]; i+=1) {
				TFHppleElement *link = [links objectAtIndex:i];
				NSString *href = [self resolveUrl:[link objectForKey:@"href"]];
				NSString *label = [link textContent];

				if (![Blacklist isBlacklisted:href]) {
					CategoryNode *categoryNode = [[CategoryNode alloc] initWithUrl:href
																		 withLabel:label
																	  withSynopsis:@""];

					[categoryNodes addObject:categoryNode];
					[categoryNode release];
				}
			}

            NSMutableArray *uniqueCategoryNodes = [NSMutableArray array];
            NSMutableSet *processed = [NSMutableSet set];
            for (CategoryNode *categoryNode in categoryNodes) {
                if ([processed containsObject:categoryNode.label] == NO) {
                    [uniqueCategoryNodes addObject:categoryNode];
                    [processed addObject:categoryNode.label];
                }
            }

            NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES] autorelease];
            [uniqueCategoryNodes sortUsingDescriptors: @[sortDescriptor]];

			[self.dataSource loadCategoryNodes:uniqueCategoryNodes];
			[self.delegate receiveCategoryNodes:uniqueCategoryNodes withResult:0];
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
