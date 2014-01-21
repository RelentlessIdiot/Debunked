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

#import "CategoryConsumer.h"
#import "RumorNode.h"


@implementation CategoryConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<CategoryDelegate> *)theDelegate 
		withDataSource:(NSObject<CategoryDataSource> *)theDataSource
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

- (NSArray *)parseRumorNodes:(TFHpple *)parser newStyle:(BOOL)newStyle
{
	TFHppleElement *rumorBlockEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font/div/table[3]//td"];
	if (rumorBlockEl == nil) {
		rumorBlockEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font/div/table[2]//td"];
	}
	if (rumorBlockEl == nil) {
		rumorBlockEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font/div/table[1]//td"];
	}
	if (rumorBlockEl == nil) {
		rumorBlockEl = [parser at:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]//table//tr/td[not(@colspan)]"];
	}
	
	NSMutableArray *rumors = [NSMutableArray array];
	NSString *rumorUrl = nil;
	NSString *rumorSynopsis = nil;
	NSString *rumorLabel = nil;
	NSString *rumorVeracity = nil;
	NSMutableArray *children = [NSMutableArray arrayWithArray:[rumorBlockEl children]];
	if (newStyle) {
		while([children count] > 0) {
			TFHppleElement *el = [children objectAtIndex:0];
			[children removeObjectAtIndex:0];
			if ([@"a" isEqual:[el tagName]] && [el objectForKey:@"href"] != nil) {
				rumorUrl = [self resolveUrl:[el objectForKey:@"href"]];
				rumorLabel = [el textContent];
			} else if ([@"img" isEqual:[el tagName]]) {
				if ([[el objectForKey:@"src"] hasSuffix:@"green.gif"]) {
					rumorVeracity = @"true";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"red.gif"]) {
					rumorVeracity = @"false";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"multi.gif"] || [[el objectForKey:@"src"] hasSuffix:@"mostlytrue.gif"]) {
					rumorVeracity = @"truefalse";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"yellow.gif"]) {
					rumorVeracity = @"undetermined";
				} else {
					rumorVeracity = @"unknown";
				}
			} else if ([@"text" isEqual:[el tagName]]) {
				NSString *textContent = [[[el textContent] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (!([@"TRUE" isEqual:textContent] ||
					  [@"PARTLY TRUE" isEqual:textContent] ||
					  [@"FALSE" isEqual:textContent] ||
					  [@"LEGEND" isEqual:textContent] ||
					  [@"UNDETERMINED" isEqual:textContent] ||
					  [@"" isEqual:textContent]
					  )) {
					if(rumorSynopsis == nil) {
						rumorSynopsis = @"";
					}
					rumorSynopsis = [[rumorSynopsis stringByAppendingString:@" "] stringByAppendingString:[[el textContent] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				}
			} else if ([@"br" isEqual:[el tagName]] || [@"p" isEqual:[el tagName]]) {
				if (rumorUrl != nil && rumorSynopsis != nil && rumorLabel != nil) {
					if ([rumorUrl hasPrefix:@"http://www.snopes.com"] ||
						[rumorUrl hasPrefix:@"https://www.snopes.com"] ||
						[rumorUrl hasPrefix:@"http://snopes.com"] ||
						[rumorUrl hasPrefix:@"https://snopes.com"]) {
						
						if (![Blacklist isBlacklisted:rumorUrl]) {
							rumorSynopsis = [rumorSynopsis stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
							RumorNode *rumor = [[RumorNode alloc] initWithUrl: rumorUrl
																	withLabel: rumorLabel
																 withSynopsis: rumorSynopsis
																 withVeracity: rumorVeracity];
							[rumors addObject:rumor];
							[rumor release];
						}
					}
					
					rumorUrl = nil;
					rumorSynopsis = nil;
					rumorLabel = nil;
					rumorVeracity = nil;
				}
			} else {
				if ([[el children] count] > 0) {
					for (int i = 0; i < [[el children] count]; i++) {
						[children insertObject:[[el children] objectAtIndex:i] atIndex:i];
					}
				}
			}
		}
		if (rumorUrl != nil && rumorSynopsis != nil && rumorLabel != nil) {
			if ([rumorUrl hasPrefix:@"http://www.snopes.com"] ||
				[rumorUrl hasPrefix:@"https://www.snopes.com"] ||
				[rumorUrl hasPrefix:@"http://snopes.com"] ||
				[rumorUrl hasPrefix:@"https://snopes.com"]) {
				
				if (![Blacklist isBlacklisted:rumorUrl]) {
					rumorSynopsis = [rumorSynopsis stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
					RumorNode *rumor = [[RumorNode alloc] initWithUrl: rumorUrl
															withLabel: rumorLabel
														 withSynopsis: rumorSynopsis
														 withVeracity: rumorVeracity];
					[rumors addObject:rumor];
					[rumor release];
				}
			}
			
			rumorUrl = nil;
			rumorSynopsis = nil;
			rumorLabel = nil;
			rumorVeracity = nil;
		}
	} else {
		while([children count] > 0) {
			TFHppleElement *el = [children objectAtIndex:0];
			[children removeObjectAtIndex:0];
			if ([@"a" isEqual:[el tagName]] && [el objectForKey:@"href"] != nil) {
				rumorUrl = [self resolveUrl:[el objectForKey:@"href"]];
				if(rumorSynopsis == nil) {
					rumorSynopsis = @"";
				}
				rumorSynopsis = [[rumorSynopsis stringByAppendingString:@" "] stringByAppendingString:[[el textContent] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			} else if ([@"img" isEqual:[el tagName]]) {
				if ([[el objectForKey:@"src"] hasSuffix:@"green.gif"]) {
					rumorVeracity = @"true";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"red.gif"]) {
					rumorVeracity = @"false";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"multi.gif"] || [[el objectForKey:@"src"] hasSuffix:@"mostlytrue.gif"]) {
					rumorVeracity = @"truefalse";
				} else if ([[el objectForKey:@"src"] hasSuffix:@"yellow.gif"]) {
					rumorVeracity = @"undetermined";
				} else {
					rumorVeracity = @"unknown";
				}
			} else if ([@"text" isEqual:[el tagName]]) {
				if(rumorSynopsis == nil) {
					rumorSynopsis = @"";
				}
				rumorSynopsis = [[rumorSynopsis stringByAppendingString:@" "] stringByAppendingString:[[el textContent] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			} else if ([@"br" isEqual:[el tagName]] || [@"p" isEqual:[el tagName]]) {
				if (rumorUrl != nil && rumorSynopsis != nil) {
					if ([rumorUrl hasPrefix:@"http://www.snopes.com"] ||
						[rumorUrl hasPrefix:@"https://www.snopes.com"] ||
						[rumorUrl hasPrefix:@"http://snopes.com"] ||
						[rumorUrl hasPrefix:@"https://snopes.com"]) {
						
						if (![Blacklist isBlacklisted:rumorUrl]) {
							rumorSynopsis = [rumorSynopsis stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
							RumorNode *rumor = [[RumorNode alloc] initWithUrl: rumorUrl
																 withSynopsis: rumorSynopsis
																 withVeracity: rumorVeracity];
							[rumors addObject:rumor];
							[rumor release];
						}
					}
					
					rumorUrl = nil;
					rumorSynopsis = nil;
					rumorVeracity = nil;
				}
			} else {
				if ([[el children] count] > 0) {
					for (int i = 0; i < [[el children] count]; i++) {
						[children insertObject:[[el children] objectAtIndex:i] atIndex:i];
					}
				} else {
					if(rumorSynopsis == nil) {
						rumorSynopsis = @"";
					}
					rumorSynopsis = [[rumorSynopsis stringByAppendingString:@" "] stringByAppendingString:[[el textContent] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				}
			}
		}
		if (rumorUrl != nil && rumorSynopsis != nil) {
			if ([rumorUrl hasPrefix:@"http://www.snopes.com"] ||
				[rumorUrl hasPrefix:@"https://www.snopes.com"] ||
				[rumorUrl hasPrefix:@"http://snopes.com"] ||
				[rumorUrl hasPrefix:@"https://snopes.com"]) {
				
				if (![Blacklist isBlacklisted:rumorUrl]) {
					rumorSynopsis = [rumorSynopsis stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
					RumorNode *rumor = [[RumorNode alloc] initWithUrl: rumorUrl
														 withSynopsis: rumorSynopsis
														 withVeracity: rumorVeracity];
					[rumors addObject:rumor];
					[rumor release];
				}
			}
			
			rumorUrl = nil;
			rumorSynopsis = nil;
			rumorVeracity = nil;
		}
	}
	
	return rumors;
}

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		NSString* stringData = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"<NOBR>" withString:@""];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"<nobr>" withString:@""];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"</NOBR>" withString:@""];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"</nobr>" withString:@""];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"&NBSP;" withString:@" "];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"&NBSP" withString:@" "];
		stringData = [stringData stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];
		data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
		
		parser = [[TFHpple alloc] initWithHTMLData:data];
		NSString *rumorXPath = @"//img["
		@"\"common/green.gif\"=substring(@src, string-length(@src) - string-length(\"common/green.gif\") + 1)"
		@" or "
		@"\"common/red.gif\"=substring(@src, string-length(@src) - string-length(\"common/red.gif\") + 1)"
		@" or "
		@"\"common/multi.gif\"=substring(@src, string-length(@src) - string-length(\"common/multi.gif\") + 1)"
		@" or "
		@"\"common/yellow.gif\"=substring(@src, string-length(@src) - string-length(\"common/yellow.gif\") + 1)"
		@" or "
		@"\"common/white.gif\"=substring(@src, string-length(@src) - string-length(\"common/white.gif\") + 1)"
		@" or "
		@"\"images/legend.gif\"=substring(@src, string-length(@src) - string-length(\"images/legend.gif\") + 1)"
		@" or "
		@"\"images/green.gif\"=substring(@src, string-length(@src) - string-length(\"images/green.gif\") + 1)"
		@" or "
		@"\"images/mostlytrue.gif\"=substring(@src, string-length(@src) - string-length(\"images/mostlytrue.gif\") + 1)"
		@" or "
		@"\"images/red.gif\"=substring(@src, string-length(@src) - string-length(\"images/red.gif\") + 1)"
		@" or "
		@"\"images/yellow.gif\"=substring(@src, string-length(@src) - string-length(\"images/yellow.gif\") + 1)"
		@"]";
		NSArray *rumorImages = [parser search:rumorXPath];
		BOOL hasRumors = ([rumorImages count] > 0);
		BOOL oldStyle = NO;
		BOOL newStyle = NO;
		TFHppleElement *labelEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/center/font"];
		if (labelEl != nil) {
			oldStyle = YES;
		} else {
			labelEl = [parser at:@"//td[@class=\"contentColumn\"]/h1"];
			if (labelEl != nil) {
				newStyle = YES;
			}
		}
		if (!hasRumors) {
			TFHppleElement *rumorBlock = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table//tr/td//li"];
			if (rumorBlock != nil) {
				hasRumors = YES;
			}
		}
		if (hasRumors) {
			NSString *label = [[labelEl content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			TFHppleElement *descriptionEl = nil;
			NSString *description = nil;
			
			if (oldStyle) {
				descriptionEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font/div//div"];
				description = [[descriptionEl textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			} else if (newStyle) {
				descriptionEl = [parser at:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]/div"];
				description = [[descriptionEl textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			}
			
			Category *category = [[Category alloc] initWithUrl:[[response URL] absoluteString]
													 withLabel:label
											   withDescription:description];
			@try {
				category.rumorNodes = [NSMutableArray arrayWithArray:[self parseRumorNodes:parser newStyle:newStyle]];
				[self.delegate receive:category withResult:0];
			}
			@catch (NSException *exception) {
				[self.delegate receive:category withResult:1];
			}
			@finally {
				[category release];
			}
			
		} else {
			TFHppleElement *descriptionEl = nil;
			NSString *description = nil;
			NSString *label = nil;
			NSArray *links = nil;
			NSArray *imgs  = nil;
			NSArray *nodeSynopses = nil;
			
			if (oldStyle) {
				label = [[labelEl content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				descriptionEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font/div/font/div"];
				description = [[descriptionEl textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				links = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table[2]//tr/td//a"];
				imgs  = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table[2]//tr/td/img[@src != \"/images/search-hdr.gif\"]"];
				nodeSynopses = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table[2]//tr/td/font"];
				if ([links count] == 0 || [imgs count] == 0 || [nodeSynopses count] == 0) {
					links = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table//tr/td//a"];
					imgs  = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table//tr/td/img[@src != \"/images/search-hdr.gif\"]"];
					nodeSynopses = [parser search:@"//div[@id=\"main-content\"]/table//tr/td[2]/center//table//tr/td/font"];					
				}
			} else if (newStyle) {
				label = [[labelEl content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				descriptionEl = [parser at:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]/div"];
				description = [[descriptionEl textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				links = [parser search:@"//td[@class=\"contentColumn\"]/table//tr/td[not(@colspan)]//a[string-length(@href)>0]"];
				if ([links count] > 0) {
					imgs = [parser search:@"//td[@class=\"contentColumn\"]/table//tr/td[not(@colspan)]/img[@src != \"/images/search-hdr.gif\"]"];
					nodeSynopses = [parser search:@"//td[@class=\"contentColumn\"]/table//tr/td[not(@colspan)]/font"];
				} else {
					links = [parser search:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]//table//tr/td[not(@colspan)]//a[string-length(@href)>0]"];
					imgs = [parser search:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]//table//tr/td[not(@colspan)]/img[@src != \"/images/search-hdr.gif\"]"];
					nodeSynopses = [parser search:@"//td[@class=\"contentColumn\"]//div[@class=\"article_text\"]//table//tr/td[not(@colspan)]/text()[normalize-space()]"];
				}
			}
			Category *category = [[Category alloc] initWithUrl:[[response URL] absoluteString]
													 withLabel:label
											   withDescription:description];
			@try {
				NSMutableArray *categoryNodes = [NSMutableArray array];
				for (int i = 0; i < [links count] && i < [imgs count] && i < [nodeSynopses count]; i++) {
					TFHppleElement *link = [links objectAtIndex:i];
					TFHppleElement *img = [imgs objectAtIndex:i];
					TFHppleElement *syn = [nodeSynopses objectAtIndex:i];
					NSString *nodeUrl = [self resolveUrl:[link objectForKey:@"href"]];
					NSString *nodeImageUrl = [self resolveUrl:[img objectForKey:@"src"]];
					NSString *nodeSynopsis = [[syn content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSString *nodeLabel = [[link textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					if (![Blacklist isBlacklisted:nodeUrl]) {
						CategoryNode *categoryNode = [[CategoryNode alloc] initWithUrl:nodeUrl
																			 withLabel:nodeLabel
																		  withSynopsis:nodeSynopsis 
																		  withImageUrl:nodeImageUrl];
						[categoryNodes addObject:categoryNode];
						[categoryNode release];
					}
				}
				if ([categoryNodes count] == 0) {
					category.rumorNodes = [NSMutableArray arrayWithArray:[self parseRumorNodes:parser newStyle:newStyle]];
				} else {
					category.categoryNodes = categoryNodes;
				}
				[self.delegate receive:category withResult:0];
			}
			@catch (NSException *exception) {
				[self.delegate receive:category withResult:1];
			}
		}
	}
	@catch (NSException *exception) {
		[self.delegate receive:nil withResult:1];
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
