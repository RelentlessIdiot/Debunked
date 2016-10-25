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


@implementation DataConsumer

@synthesize url;
@synthesize targetUrl;

- (void)dealloc
{
    [url release];
    [targetUrl release];

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

- (NSArray *)parseRumorNodes:(NSData *)data
{
    NSMutableArray *rumorNodes = [NSMutableArray array];
    TFHpple *parser = nil;
    @try {
        parser = [[TFHpple alloc] initWithHTMLData:data];
        NSArray *posts = [parser search: @"//ul[@class=\"post-list\"]/li"];

        for (int i = 0; i < [posts count]; i++) {
            TFHppleElement *post = [posts objectAtIndex:i];
            TFHpple *postParser = nil;
            @try {
                postParser = [[TFHpple alloc] initWithHTMLData: [post.outerHtml dataUsingEncoding: NSUTF8StringEncoding]];
                TFHppleElement *link = [postParser at: @"//h4[@class=\"title\"]/a"];
                TFHppleElement *img = [postParser at: @"//div[@class=\"post-img\"]/img"];
                TFHppleElement *syn = [postParser at: @"//p[@class=\"body\"]/span[@class=\"label\"]"];
                if (syn == nil) {
                    syn = [postParser at: @"//p[@class=\"body\"]"];
                }
                if (link && img && syn) {
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
