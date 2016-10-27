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

#import "RumorConsumer.h"
#import "Rumor.h"


@implementation RumorConsumer

- (TFHppleElement *)transform:(TFHppleElement *)element
{
	return element;
}

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
		return;
	}
	
	TFHpple *parser = nil;
	@try {
        parser = [[TFHpple alloc] initWithHTMLData:data];

        TFHppleElement *titleEl = [parser at:@"//article//h1[@itemprop=\"headline\"]"];
        if (titleEl == nil) {
            titleEl = [parser at:@"//article//h1[contains(@class, \"page-title\")]"];
        }
        NSString *title = [titleEl.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

        TFHppleElement *veracityEl = [parser at:@"//article//span[@itemprop=\"reviewRating\"]"];
        if (veracityEl == nil) {
            veracityEl = [parser at:@"//article//div[contains(@class, \"claim-old\")]"];
            if (veracityEl == nil) {
                veracityEl = [parser at:@"//article//div[contains(@class, \"claim-new\")]"];
                if (veracityEl == nil) {
                    veracityEl = [parser at:@"//article//div[contains(@class, \"claim\")]"];
                }
            }
        }
        NSString *veracity = [veracityEl.textContent stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

		Rumor *rumor = [[[Rumor alloc] init] autorelease];
        rumor.rawHtml = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		rumor.url = [[response URL] absoluteString];
		rumor.title = title;
        rumor.veracity = veracity;

        [self.dataSource receiveRequest:self.requestId withItem:rumor withResult:0];
	}
	@catch (NSException *exception) {
        [self.dataSource receiveRequest:self.requestId withItem:nil withResult:1];
	}
	@finally {
		[parser release];
	}
}

@end
