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
#import "Blacklist.h"
#import "Category.h"
#import "CategoryNode.h"
#import "TFHpple.h"


@implementation TopLevelCategoryConsumer

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
		parser = [[TFHpple alloc] initWithHTMLData:data];
		NSArray *links  = [parser search:@"//a[starts-with(@href, '/category/')]"];

		NSMutableArray *categoryNodes = [NSMutableArray array];
		
		@try {
			for (int i = 0; i < links.count; i += 1) {
				TFHppleElement *link = [links objectAtIndex:i];
				NSString *href = [self resolveUrl:[link objectForKey:@"href"]];
				NSString *label = [link.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

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

            Category *category = [[[Category alloc] initWithUrl:self.url] autorelease];
            category.categoryNodes = uniqueCategoryNodes;

            [self.dataSource receiveRequest:self.requestId withItem:category withResult:0];
		}
		@catch (NSException *exception) {
			[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
		}
	}
	@catch (NSException *exception) {
		[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
	}
	@finally {
		[parser release];
	}
}

@end
