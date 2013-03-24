//
//  TFHpple.m
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

#import "TFHpple.h"
#import "XPathQuery.h"

@implementation TFHpple

@synthesize data;

- (void) dealloc
{
  [data release];
  [super dealloc];
}

- (id) initWithData:(NSData *)theData isXML:(BOOL)isDataXML
{
  if (!(self = [super init]))
    return nil;

  self.data = theData;
  isXML = isDataXML;

  return self;
}

- (id) initWithXMLData:(NSData *)theData
{
  return [self initWithData:theData isXML:YES];
}

- (id) initWithHTMLData:(NSData *)theData
{
  return [self initWithData:theData isXML:NO];
}

// Returns all elements at xPath.
- (NSArray *) search:(NSString *)xPathOrCSS
{
	return [self search:xPathOrCSS returnChildren:NO isRecursive:NO];
}

- (NSArray *) search:(NSString *)xPathOrCSS returnChildren:(BOOL)children isRecursive:(BOOL)recursive
{
  NSArray * detailNodes;
  if (isXML) {
    detailNodes = PerformXMLXPathQueryReturnChildren(data, xPathOrCSS, children, recursive);
  } else {
    detailNodes = PerformHTMLXPathQueryReturnChildren(data, xPathOrCSS, children, recursive);
  }

  NSMutableArray * hppleElements = [NSMutableArray array];
  for (id node in detailNodes) {
    TFHppleElement * e = [[TFHppleElement alloc] initWithNode:node];
    [hppleElements addObject:e];
    [e release];
  }
  return hppleElements;
}

// Returns first element at xPath
- (TFHppleElement *) at:(NSString *)xPathOrCSS
{
  NSArray * elements = [self search:xPathOrCSS];
  if ([elements count] >= 1)
    return [elements objectAtIndex:0];

  return nil;
}

@end
