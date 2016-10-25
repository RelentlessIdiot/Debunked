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
#import "RumorNode.h"


@implementation RumorConsumer

@synthesize delegate;
@synthesize dataSource;

- (id)initWithDelegate:(NSObject<RumorDelegate> *)theDelegate 
		withDataSource:(RumorDataSource *)theDataSource
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

- (TFHppleElement *)transform:(TFHppleElement *)element
{
	return element;
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

		TFHppleElement *labelEl = [parser at:@"//article/div[@class=\"top-meta\"]/h1[@class=\"page-title\"]"];
        NSString *label = labelEl.textContent;

        TFHppleElement *rumorBodyEl = [parser at:@"//article"];
        NSString *rumorBody = [rumorBodyEl outerHtml];

        TFHppleElement *headEl = [parser at:@"//head"];

		NSString *html = @"<!DOCTYPE html><html>";
		html = [html stringByAppendingString:headEl.outerHtml];
        html = [html stringByAppendingString:@"<body class=\"Safari page-article mobile iPhone retina\">"
                @"<div class=​\"main-container\">​"
                @"<div class=​\"content-wrapper-main\">​"
                @"<div class=​\"container-wrapper container-wrapper-main\" style=​\"overflow:​ visible;​\">​"
                @"<div id=​\"main-content-well\" class=​\"wordpress\">​"
                @"<div class=​\"content-wrapper\">​"];
        html = [html stringByAppendingString:rumorBody];
        html = [html stringByAppendingString:@"</div>"
                @"</div>"
                @"</div>"
                @"</div>"
                @"</div>"
                @"</body>"];
		html = [html stringByAppendingString:@"</html>"];

		Rumor *rumor = [[[Rumor alloc] init] autorelease];
		rumor.rawHtml = html;
		rumor.url = [[response URL] absoluteString];
		rumor.title = label;
		
		[self.delegate receive:rumor withResult:0];
	}
	@catch (NSException *exception) {
		[self.delegate receive:nil withResult:0];
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
