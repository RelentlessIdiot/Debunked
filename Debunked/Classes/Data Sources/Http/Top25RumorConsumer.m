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

#import "Top25RumorConsumer.h"


@implementation Top25RumorConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<RumorDelegate> *)theDelegate 
		withDataSource:(NSObject<RumorDataSource> *)theDataSource
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

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];
		TFHppleElement *labelEl = [parser at:@"//td[@class=\"contentColumn\"]/h1"];
		NSString *label = nil;
		NSArray *links = nil;
		NSArray *imgs  = nil;
		NSArray *nodeSynopses = nil;
		
		label = [[labelEl content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		links = [parser search:@"//td[@class=\"contentColumn\"]//noindex//ol/div/a"];
		imgs = [parser search:@"//td[@class=\"contentColumn\"]//noindex//ol/div/img"];
		nodeSynopses = [parser search:@"//td[@class=\"contentColumn\"]//noindex//ol/div/li"];
		
		NSMutableArray *rumorNodes = [NSMutableArray array];
		@try {
			for (int i = 0; i < [links count]; i++) {
				TFHppleElement *link = [links objectAtIndex:i];
				TFHppleElement *img = [imgs objectAtIndex:(i)];
				TFHppleElement *syn = [nodeSynopses objectAtIndex:(i)];
				NSString *nodeUrl = [self resolveUrl:[link objectForKey:@"href"]];
				NSString *nodeImageUrl = [self resolveUrl:[img objectForKey:@"src"]];
				NSString *nodeSynopsis = [[syn content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSString *nodeLabel = [[link textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				if (![Blacklist isBlacklisted:nodeUrl]) {
					RumorNode *rumorNode = [[RumorNode alloc] initWithUrl:nodeUrl
																withLabel:nodeLabel
															 withSynopsis:nodeSynopsis 
															 withVeracity:@""
															 withImageUrl:nodeImageUrl];
					[rumorNodes addObject:rumorNode];
					[rumorNode release];
				}
			}
			
			[self.dataSource loadRumorNodes:rumorNodes];
			[self.delegate receiveRumorNodes:rumorNodes withResult:0];
		}
		@catch (NSException *exception) {
			[self.delegate receiveRumorNodes:rumorNodes withResult:1];
		}
	}
	@catch (NSException *exception) {
		[self.delegate receiveRumorNodes:nil withResult:1];
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
