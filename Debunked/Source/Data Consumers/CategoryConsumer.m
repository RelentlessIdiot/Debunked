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
#import "Blacklist.h"
#import "Category.h"
#import "CategoryNode.h"
#import "RumorNode.h"
#import "TFHpple.h"


@implementation CategoryConsumer

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];

        TFHppleElement *labelEl = [parser at:@"//h1[@itemprop=\"headline\"]"];
        if (labelEl == nil) {
            labelEl = [parser at:@"//h1[contains(@class, \"page-title\")]"];
        }
        NSString *label = [labelEl.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

        TFHppleElement *descriptionEl = [parser at:@"//div[contains(@class, \"category-description\")]"];
        NSString *description = [descriptionEl.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

        Category *category = [[Category alloc] initWithUrl:[[response URL] absoluteString]
                                                 withLabel:label
                                           withDescription:description];

        category.categoryNodes = [self parseCategoryNodes:data];
        category.rumorNodes = [self parseRumorNodes:data];

        [self.dataSource receiveRequest:self.requestId withItem:category withResult:0];
	}
	@catch (NSException *exception) {
		[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
	}
	@finally {
		[parser release];
	}
}

- (NSArray *)parseCategoryNodes:(NSData *)data
{
    return nil;
}


- (NSArray *)parseRumorNodes:(NSData *)data
{
    NSMutableArray *rumorNodes = [NSMutableArray array];
    TFHpple *parser = nil;
    @try {
        parser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *posts = [parser search: @"//ul[contains(@class, \"post-list\")]/li"];

        for (int i = 0; i < [posts count]; i++) {
            TFHppleElement *post = [posts objectAtIndex:i];
            TFHpple *postParser = nil;
            @try {
                postParser = [[TFHpple alloc] initWithHTMLData: [post.outerHtml dataUsingEncoding: NSUTF8StringEncoding]];
                TFHppleElement *link = [postParser at: @"//h4[contains(@class, \"title\")]/a"];
                TFHppleElement *img = [postParser at: @"//div[contains(@class, \"post-img\")]/img"];
                TFHppleElement *syn = [postParser at: @"//p[contains(@class, \"body\")]/span[contains(@class, \"label\")]"];
                if (syn == nil) {
                    syn = [postParser at: @"//p[contains(@class, \"body\")]"];
                }
                if (link && img && syn) {
                    NSString *nodeUrl = [self resolveUrl:[link objectForKey:@"href"]];
                    NSString *nodeImageUrl = [self resolveUrl:[img objectForKey:@"src"]];
                    NSString *nodeSynopsis = [syn.content stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                    NSString *nodeLabel = [link.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];

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
            }
            @catch (NSException *exception) {
                NSLog(@"ERROR: failed parsing rumor\n%@\n\n%@", exception.description, post.outerHtml);
            }
            @finally {
                [postParser release];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR: failed parsing rumors\n%@", exception.description);
    }
    @finally {
        [parser release];
    }
    
    return rumorNodes;
}

@end
