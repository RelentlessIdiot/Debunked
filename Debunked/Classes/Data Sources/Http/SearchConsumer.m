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

#import "SearchConsumer.h"


@implementation SearchConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<SearchDelegate> *)theDelegate 
		withDataSource:(NSObject<SearchDataSource> *)theDataSource
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

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];
//		NSArray *resultEls = [parser search:@"/html/body/table//tr[2]/td[2]/table[2]//tr/td/font/p"];
		NSArray *resultEls = [parser search:@"/html/body/font"];
		
		NSMutableArray *results = [NSMutableArray array];
		for (TFHppleElement *resultEl in resultEls) {
			NSString *rumorUrl = nil;
			NSString *rumorSynopsis = nil;
			NSString *rumorLabel = nil;
			NSString *rumorHeadline = nil;
			NSMutableArray *children = [NSMutableArray arrayWithArray:[resultEl children]];
			while([children count] > 0) {
				TFHppleElement *el = [children objectAtIndex:0];
				[children removeObjectAtIndex:0];
				NSUInteger childCount = [[el children] count];
				if ([@"a" isEqual:[el tagName]] && [el objectForKey:@"href"] != nil) {
					rumorUrl = [el objectForKey:@"href"];
					rumorLabel = [el content];
					if ([rumorLabel hasPrefix:@"snopes.com"]) {
						rumorLabel = [rumorLabel substringFromIndex:[@"snopes.com" length]];
					}
					rumorLabel = [rumorLabel stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
				} else if ([@"text" isEqual:[el tagName]]) {
					// Dump the first text node
					if(rumorSynopsis == nil) {
						rumorSynopsis = @"";
					} else {
						rumorSynopsis = [rumorSynopsis stringByAppendingString:[el textContent]];
					}
				} else if ([@"i" isEqual:[el tagName]]) {
					// Do nothing
				} else if ([@"b" isEqual:[el tagName]] && childCount == 1 && [@"font" isEqual:[[[el children] objectAtIndex:0] tagName]]) {
					rumorHeadline = [[[el children] objectAtIndex:0] content];
				} else {
					if (childCount > 0) {
						for (int i = 0; i < childCount; i++) {
							[children insertObject:[[el children] objectAtIndex:i] atIndex:i];
						}
					} else {
						if(rumorSynopsis == nil) {
							rumorSynopsis = @"";
						}
						rumorSynopsis = [rumorSynopsis stringByAppendingString:[el textContent]];
					}
				}
			}
			if (rumorUrl != nil && rumorSynopsis != nil && rumorLabel != nil) {
				if (![Blacklist isBlacklisted:rumorUrl]) {
					NSMutableArray *components = [NSMutableArray array];
					for (NSString *component in [rumorSynopsis componentsSeparatedByString:@" "]) {
						component = [component stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]];
						if (![@"" isEqual:component]) {
							[components addObject:component];
						}
					}
					rumorSynopsis = [components componentsJoinedByString:@" "];
					components = [NSMutableArray array];
					for (NSString *component in [rumorSynopsis componentsSeparatedByString:@"\n"]) {
						component = [component stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]];
						if (![@"" isEqual:component]) {
							[components addObject:component];
						}
					}
					rumorSynopsis = [components componentsJoinedByString:@" "];
					components = [NSMutableArray array];
					for (NSString *component in [rumorSynopsis componentsSeparatedByString:@"\r"]) {
						component = [component stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]];
						if (![@"" isEqual:component]) {
							[components addObject:component];
						}
					}
					rumorSynopsis = [components componentsJoinedByString:@" "];
					SearchResult * result = [[SearchResult alloc] initWithTitle:rumorLabel
																		withUrl:rumorUrl
																   withSynopsis:rumorSynopsis
															  withRumorHeadline:rumorHeadline];
					
					[results addObject:result];
					[result release];
				}
				
				rumorUrl = nil;
				rumorSynopsis = nil;
				rumorLabel = nil;
				rumorHeadline = nil;
			}
		}
		
		[self.dataSource loadSearchResults:results];
		[self.delegate receiveSearchResults:results withResult:0];
	}
	@catch (NSException *exception) {
		[self.delegate receiveSearchResults:nil withResult:1];
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
