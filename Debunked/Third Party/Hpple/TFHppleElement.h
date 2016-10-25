//
//  TFHppleElement.h
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

#import <Foundation/Foundation.h>


@interface TFHppleElement : NSObject {
	NSDictionary *node;
	NSString *_content;
	NSString *_textContent;
	NSString *_innerHtml;
	NSString *_outerHtml;
	NSMutableDictionary *_attributes;
	NSMutableArray *_children;
}

- (id) initWithNode:(NSDictionary *) theNode;

- (NSString *) str:(NSString *)value;

// Returns this tag's text content.
- (NSString *) content;

// Returns all the text node content from this tag and any children.
- (NSString *) textContent;

// Returns the innerHtml of this element.
- (NSString *) innerHtml;

// Returns the outerHtml of this element.
- (NSString *) outerHtml;

// Returns the innerHtml of this element.
- (NSString *) innerHtmlTransform:(NSDictionary *)transforms;

// Returns the outerHtml of this element.
- (NSString *) outerHtmlTransform:(NSDictionary *)transforms;

// Returns the name of the current tag, such as "h3".
- (NSString *) tagName;

// Returns tag attributes with name as key and content as value.
//   href  = 'http://peepcode.com'
//   class = 'highlight'
- (NSMutableDictionary *) attributes;

// Provides easy access to the content of a specific attribute, 
// such as 'href' or 'class'.
- (NSString *) objectForKey:(NSString *) theKey;
- (void) setValue:(NSString *)value forKey:(NSString *)key;

// Returns an NSArray of child nodes as NSDictionarys.
- (NSArray *) childArray;

// Returns an NSArray of child nodes as TFHppleElements.
- (NSArray *) children;

@end
