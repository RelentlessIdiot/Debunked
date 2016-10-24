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

        TFHppleElement *labelEl = [parser at:@"//h1[@class=\"page-title\"]"];
        TFHppleElement *descriptionEl = [parser at:@"//div[@class=\"category-description\"]"];

        NSString *description = [descriptionEl textContent];
        NSString *label = [labelEl textContent];
        NSArray *links = nil;
        NSArray *imgs  = nil;
        NSArray *nodeSynopses = nil;

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
                category.rumorNodes = [NSMutableArray arrayWithArray:[self parseRumorNodes:data]];
            } else {
                category.categoryNodes = categoryNodes;
            }
            [self.delegate receive:category withResult:0];
        }
        @catch (NSException *exception) {
            [self.delegate receive:category withResult:1];
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
