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

- (TFHppleElement *)transform:(TFHppleElement *)element
{
	if ([@"img" isEqual:[element tagName]]) {
		if ([[[element attributes] objectForKey:@"src"] hasSuffix:@"content-divider.gif"]) {
			[element setValue:@"" forKey:@"width"];
			[element setValue:@"width:100%;" forKey:@"style"];
		} else {
			NSString *widthString = [element objectForKey:@"width"];
			if (widthString != nil) {
				NSInteger width = [widthString intValue];
				if (width > 290) {
					NSString *heightString = [element objectForKey:@"height"];
					if (heightString != nil) {
						NSInteger height = [heightString intValue];
						NSInteger newHeight = ((height * (290.0/width)) + 0.5);
						NSString *newHeightString = [NSString stringWithFormat:@"%ld", (long)newHeight];
						[element setValue:newHeightString forKey:@"height"];
					}
					[element setValue:@"290" forKey:@"width"];
				}
			}
		}
	}else if ([@"table" isEqual:[element tagName]]) {
		NSString *widthString = [element objectForKey:@"width"];
		if (widthString != nil) {
			NSInteger width = [widthString intValue];
			if (width > 290) {
				[element setValue:@"290" forKey:@"width"];
			}
		}
	}
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
		NSString *label = @"";
		NSString *rumorBody = @"";
		NSString *css = @"";
		
		NSDictionary *imgTransform = [NSDictionary 
									  dictionaryWithObjects:[NSArray arrayWithObjects:self, [NSDictionary 
																							 dictionaryWithObjects:[NSArray arrayWithObjects:@"0", @"0", nil]
																							 forKeys:[NSArray arrayWithObjects:@"hspace", @"vspace", nil]], nil]
									  forKeys:[NSArray arrayWithObjects:@"transformer", @"attributes", nil]];
		NSDictionary *brTransform = [NSDictionary 
									 dictionaryWithObjects:[NSArray arrayWithObjects:@"p", [NSDictionary 
																							dictionaryWithObjects:[NSArray arrayWithObjects:@"br", nil]
																							forKeys:[NSArray arrayWithObjects:@"class", nil]], nil]
									  forKeys:[NSArray arrayWithObjects:@"tagName", @"attributes", nil]];
		NSDictionary *fontTransform = [NSDictionary 
										 dictionaryWithObjects:[NSArray arrayWithObjects:[NSDictionary 
																						  dictionaryWithObjects:[NSArray arrayWithObjects:@"1", nil]
																						  forKeys:[NSArray arrayWithObjects:@"size", nil]], nil]
										 forKeys:[NSArray arrayWithObjects:@"attributes", nil]];
		
		if (oldStyle) {
			label = labelEl.content;
			TFHppleElement *rumorBodyEl = [parser at:@"//div[@id=\"main-content\"]/table//tr/td[2]/center/font[2]/div"];
			if (rumorBodyEl) {
				NSDictionary *tableTransform = [NSDictionary 
												dictionaryWithObjects:[NSArray arrayWithObjects:self, [NSDictionary 
																									   dictionaryWithObjects:[NSArray arrayWithObjects:@"CENTER", @"", @"0", nil]
																									   forKeys:[NSArray arrayWithObjects:@"align", @"width", @"cellpadding", nil]], nil]
												forKeys:[NSArray arrayWithObjects:@"transformer", @"attributes", nil]];
				
				NSDictionary *transforms = [NSDictionary 
											dictionaryWithObjects:[NSArray arrayWithObjects:tableTransform, imgTransform, brTransform, fontTransform, nil]
											forKeys:[NSArray arrayWithObjects:@"table", @"img", @"br", @"font", nil]];
				rumorBody = [rumorBodyEl innerHtmlTransform:transforms];
			}
			css = 
			@"<style type=\"text/css\" media=\"all\">"
			@"html, body {\n"
			@"width:100%\n"
			@"margin:0px;\n"
			@"padding:0px;\n"
			@"}\n"
			@"* {\n"
			@"font-family:helvetica !important;\n"
			@"font-size:14px !important;\n"
			@"white-space:normal !important;\n"
			@"}\n"
			@"p.br {\n"
			@"height:0px !important;\n"
			@"}\n"
			@"table div {\n"
			@"margin:3px !important;\n"
			@"}\n"
			@"table div iframe {\n"
			@"margin-left:-5px;\n"
			@"margin-right:-5px;\n"
			@"}\n"
			@"h1.title {\n"
			@"display: none;\n"
			@"}\n"
			@"</style>"
			@"<style type=\"text/css\" media=\"print\">"
			@"h1.title {\n"
			@"color: #2D8F26;\n"
			@"font-size: 18px !important;\n"
			@"display: block !important;\n"
			@"}\n"
			@"iframe {\n"
			@"display: none !important;\n"
			@"}\n"
			@"</style>";
		} else if (newStyle) {
			label = labelEl.content;
			NSArray *rumorBodyEls = [parser search:@"//td[@class=\"contentColumn\"]/style/following-sibling::*"];
            if (!rumorBodyEls || [rumorBodyEls count] == 0) {
                rumorBodyEls = [parser search:@"//td[@class=\"contentColumn\"]/h1/following-sibling::*"];
            }
			
			NSDictionary *tableTransform = [NSDictionary 
											dictionaryWithObjects:[NSArray arrayWithObjects:self, [NSDictionary 
																								   dictionaryWithObjects:[NSArray arrayWithObjects:@"0", nil]
																								   forKeys:[NSArray arrayWithObjects:@"cellpadding", nil]], nil]
											forKeys:[NSArray arrayWithObjects:@"transformer", @"attributes", nil]];

			NSDictionary *transforms = [NSDictionary 
										dictionaryWithObjects:[NSArray arrayWithObjects:tableTransform, imgTransform, brTransform, fontTransform, nil]
										forKeys:[NSArray arrayWithObjects:@"table", @"img", @"br", @"font", nil]];
			
			for (TFHppleElement *rumorBodyEl in rumorBodyEls) {
				rumorBody = [rumorBody stringByAppendingString:[rumorBodyEl outerHtmlTransform:transforms]];
			}
			css = 
			@"<style type=\"text/css\" media=\"all\">"
			@"html, body {\n"
			@"width:100%\n"
			@"margin:0px;\n"
			@"padding:0px;\n"
			@"}\n"
			@"* {\n"
			@"font-family:helvetica !important;\n"
			@"font-size:14px !important;\n"
			@"white-space:normal !important;\n"
			@"}\n"
			@"p.br {\n"
			@"height:0px !important;\n"
			@"}\n"
			@"table div {\n"
			@"margin:3px !important;\n"
			@"}\n"
			@"div.quoteBlock {\n"
			@"background: none no-repeat scroll 0 0 #EAF2E5;\n"
			@"border: 2px solid black;\n"
			@"padding: 3px;\n"
			@"}\n"
			@"iframe {\n"
			@"margin-left: 3px;\n"
			@"}\n"
			@"div.quoteBlock iframe {\n"
			@"margin-left: -3px;\n"
			@"}\n"
			@"h1.title {\n"
			@"display: none;\n"
			@"}\n"
			@"</style>"
			@"<style type=\"text/css\" media=\"print\">"
			@"h1.title {\n"
			@"color: #2D8F26;\n"
			@"font-size: 18px !important;\n"
			@"display: block !important;\n"
			@"}\n"
			@"iframe {\n"
			@"display: none !important;\n"
			@"}\n"
			@"</style>";
		}
		
		NSString *html = @""
		@"<html><head>"
		@"<meta name=\"viewport\" content=\"width = device-width,initial-scale = 1.0, user-scalable = yes\">";
		html = [html stringByAppendingString:css];
		html = [html stringByAppendingString:@"</head><body>"];
		html = [html stringByAppendingString:@"<center><h1 class=\"title\">"];
		html = [html stringByAppendingString:label];
		html = [html stringByAppendingString:@"</h1></center>"];
		html = [html stringByAppendingString:rumorBody];
		html = [html stringByAppendingString:@"</body></html>"];

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
