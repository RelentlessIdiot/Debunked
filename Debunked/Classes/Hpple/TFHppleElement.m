//
//  TFHppleElement.m
//  Hpple
//
//  Created by Geoffrey Grosenbach on 1/31/09.
//
//  Copyright (c) 2009 Topfunky Corporation, http://topfunky.com
//
//  MIT LICENSE
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "TFHppleElement.h"
#import "TFHpple.h"


NSString * const TFHppleNodeContentKey           = @"nodeContent";
NSString * const TFHppleNodeNameKey              = @"nodeName";
NSString * const TFHppleNodeAttributeArrayKey    = @"nodeAttributeArray";
NSString * const TFHppleNodeAttributeNameKey     = @"attributeName";
NSString * const TFHppleNodeChildArrayKey        = @"nodeChildArray";

@implementation TFHppleElement

- (void) dealloc
{
	[node release];
	
	[super dealloc];
}

- (id) initWithNode:(NSDictionary *) theNode
{
	if (!(self = [super init]))
		return nil;
	
	[theNode retain];
	node = theNode;
	
	return self;
}


- (NSString *) content
{
	if (_content == nil) {
		_content = [node objectForKey:TFHppleNodeContentKey];
	}
	return _content;
}

- (NSString *) textContent
{
	if (_textContent == nil) {
		NSString *text = @"";
		if ([[self tagName] isEqualToString:@"text"]) {
			NSString *textContent = [self content];
			text = [text stringByAppendingString:textContent];
		}
		for (TFHppleElement *child in [self children]) {
			NSString *textContent = [child textContent];
			text = [text stringByAppendingString:textContent];
		}
		_textContent = [NSString stringWithString:text];
	}
	return _textContent;
}

- (NSString *) str:(NSString *)value
{
	if (value == nil) {
		return @"";
	} else {
		return value;
	}
	
}

- (NSString *) innerHtml
{
	return [self innerHtmlTransform:nil];
}

- (NSString *) innerHtmlTransform:(NSDictionary *)transforms
{
	if (_innerHtml == nil) {
		NSString *html = @"";
		
		if ([[self tagName] isEqualToString:@"text"]) {
			html = [html stringByAppendingString:[self str:[self content]]];
		} else {
			for (TFHppleElement *child in [self children]) {
				html = [html stringByAppendingString:[self str:[child outerHtmlTransform:transforms]]];
			}
		}
		_innerHtml = [NSString stringWithString:html];
	}
	return _innerHtml;
}

- (NSString *) outerHtml
{
	return [self outerHtmlTransform:nil];
}

- (NSString *) outerHtmlTransform:(NSDictionary *)transforms
{
	if (_outerHtml == nil) {
		NSString *html = @"";
		NSString *tag = [self str:[self tagName]];
		NSDictionary *trans = nil;
		if (transforms == nil) {
			trans = [NSDictionary dictionary];
		} else {
			trans = [transforms objectForKey:tag];
		}
		
		if ([tag isEqualToString:@"text"]) {
			html = [html stringByAppendingString:[self str:[self content]]];
		} else {
			TFHppleElement *element = self;
			id transformer = [trans objectForKey:@"transformer"];
			if (transformer != nil) {
				element = [(NSObject<ElementTransformer> *)transformer transform:self];
				if (element == nil) {
					element = self;
				}
			}
			
			NSString *transformedTag = [trans objectForKey:@"tagName"];
			if (transformedTag == nil) {
				transformedTag = tag;
			}
			
			html = [html stringByAppendingString:@"<"];
			html = [html stringByAppendingString:transformedTag];
			
			
			NSMutableDictionary *transformedAttributes = [NSMutableDictionary dictionaryWithDictionary:[element attributes]];
			NSDictionary *attributes = [trans objectForKey:@"attributes"];
			if (attributes != nil) {
				for (NSString *name in [attributes keyEnumerator]) {
					[transformedAttributes setObject:[self str:[attributes objectForKey:name]] forKey:name];
				}
			}
			
			for (NSString *name in [transformedAttributes keyEnumerator]) {
				NSString *value = [transformedAttributes objectForKey:name];
				html = [html stringByAppendingString:@" "];
				html = [html stringByAppendingString:[self str:name]];
				html = [html stringByAppendingString:@"=\""];
				html = [html stringByAppendingString:[self str:value]];
				html = [html stringByAppendingString:@"\""];
			}
			
			html = [html stringByAppendingString:@">"];
			
			for (TFHppleElement *child in [element children]) {
				html = [html stringByAppendingString:[self str:[child outerHtmlTransform:transforms]]];
			}
			
			html = [html stringByAppendingString:@"</"];
			html = [html stringByAppendingString:transformedTag];
			html = [html stringByAppendingString:@">"];
		}
		_outerHtml = [NSString stringWithString:html];
	}
	
	return _outerHtml;
}

- (NSString *) tagName
{
	return [node objectForKey:TFHppleNodeNameKey];
}

- (NSMutableDictionary *) attributes
{
	if (_attributes == nil) {
		_attributes = [NSMutableDictionary dictionary];
		for (NSDictionary * attributeDict in [node objectForKey:TFHppleNodeAttributeArrayKey]) {
			[_attributes setObject:[self str:[attributeDict objectForKey:TFHppleNodeContentKey]]
									 forKey:[attributeDict objectForKey:TFHppleNodeAttributeNameKey]];
		}
	}
	return _attributes;
}

- (NSString *) objectForKey:(NSString *) theKey
{
	return [[self attributes] objectForKey:theKey];
}

- (void) setValue:(NSString *)value forKey:(NSString *)key
{
	NSMutableDictionary *attributes = [self attributes];
	[attributes setValue:value forKey:key];
	NSMutableArray *attributeArray = [NSMutableArray array];
	for (NSString *name in [attributes keyEnumerator]) {
		NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
		[attributeDict setValue:name forKey:TFHppleNodeAttributeNameKey];
		[attributeDict setValue:[attributes objectForKey:name] forKey:TFHppleNodeContentKey];
		[attributeArray addObject:attributeDict];
	}
	[node setValue:attributeArray forKey:TFHppleNodeAttributeArrayKey];
	_attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
}

- (NSArray *) childArray
{
	return [node objectForKey:TFHppleNodeChildArrayKey];
}

- (NSArray *) children
{
	if (_children == nil) {
		_children = [NSMutableArray array];
		for (NSDictionary *childNode in [node objectForKey:TFHppleNodeChildArrayKey]) {
			TFHppleElement * e = [[TFHppleElement alloc] initWithNode:childNode];
			[_children addObject:e];
			[e release];
		}
	}
	return _children;
}

- (id) description
{
	return [node description];
}

@end
