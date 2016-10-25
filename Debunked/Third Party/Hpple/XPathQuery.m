//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//
//  Modifications Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
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

#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult, BOOL children, BOOL recursive)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];
	
	if (currentNode->name)
    {
		NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
		[resultForNode setObject:currentNodeContent forKey:@"nodeName"];
    }
	
	if (currentNode->content && currentNode->content != (xmlChar *)-1)
    {
		NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];
		
		if (currentNodeContent == nil) {
			currentNodeContent = @"";
		}
		
		currentNodeContent =
		[currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
		BOOL hasSpacePrefix = [currentNodeContent hasPrefix:@" "];
		BOOL hasSpaceSuffix = [currentNodeContent hasSuffix:@" "];
		
		currentNodeContent = 
		[currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if (hasSpacePrefix) {
			currentNodeContent = [@" " stringByAppendingString:currentNodeContent];
		}
		if (hasSpaceSuffix) {
			currentNodeContent = [currentNodeContent stringByAppendingString:@" "];
		}
		
		if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
        {
			if (currentNodeContent == nil || [@"" isEqual:currentNodeContent]) {
				return nil;
			}
			
			NSString *parentContent = [parentResult objectForKey:@"nodeContent"];
			if (parentContent == nil) {
				parentContent = @"";
			}
			parentContent = [parentContent stringByAppendingString:currentNodeContent];
			[parentResult setObject: parentContent forKey:@"nodeContent"];
        }
		[resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
    }
	
	xmlAttr *attribute = currentNode->properties;
	if (attribute)
    {
		NSMutableArray *attributeArray = [NSMutableArray array];
		while (attribute)
        {
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
			if (attributeName)
            {
				[attributeDictionary setObject:attributeName forKey:@"attributeName"];
            }
			
			if (attribute->children)
            {
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary, NO, NO);
				if (childDictionary)
                {
					[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
                }
            }
			
			if ([attributeDictionary count] > 0)
            {
				[attributeArray addObject:attributeDictionary];
            }
			attribute = attribute->next;
        }
		
		if ([attributeArray count] > 0)
        {
			[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
        }
    }
	
	xmlNodePtr childNode = currentNode->children;
	if (childNode)
    {
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode)
        {
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode, NO, NO);
			if (childDictionary)
            {
				[childContentArray addObject:childDictionary];
            }
			childNode = childNode->next;
        }
		if ([childContentArray count] > 0)
        {
			[resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
        }
    }
	
	return resultForNode;
}

NSArray *PerformXPathQuery(xmlDocPtr doc, NSString *query, BOOL children, BOOL recursive)
{
	xmlXPathContextPtr xpathCtx;
	xmlXPathObjectPtr xpathObj;
	
	/* Create xpath evaluation context */
	xpathCtx = xmlXPathNewContext(doc);
	if(xpathCtx == NULL)
    {
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
	
	/* Evaluate xpath expression */
	xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
	if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
	}
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
    {
		return nil;
    }
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++)
    {
		NSDictionary *nodeDictionary = DictionaryForNode(nodes->nodeTab[i], nil, children, recursive);
		if (nodeDictionary)
        {
			[resultNodes addObject:nodeDictionary];
        }
    }
	
	/* Cleanup */
	xmlXPathFreeObject(xpathObj);
	xmlXPathFreeContext(xpathCtx);
	
	return resultNodes;
}

NSArray *PerformHTMLXPathQuery(NSData *document, NSString *query)
{
	return PerformHTMLXPathQueryReturnChildren(document, query, NO, NO);
}

NSArray *PerformHTMLXPathQueryReturnChildren(NSData *document, NSString *query, BOOL children, BOOL recursive)
{
	xmlDocPtr doc;
	
	/* Load XML document */
	doc = htmlReadMemory([document bytes], (int)[document length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
	if (doc == NULL)
    {
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query, children, recursive);
	xmlFreeDoc(doc);
	
	return result;
}

NSArray *PerformXMLXPathQuery(NSData *document, NSString *query)
{
	return PerformXMLXPathQueryReturnChildren(document, query, NO, NO);
}

NSArray *PerformXMLXPathQueryReturnChildren(NSData *document, NSString *query, BOOL children, BOOL recursive)
{
	xmlDocPtr doc;
	
	/* Load XML document */
	doc = xmlReadMemory([document bytes], (int)[document length], "", NULL, XML_PARSE_RECOVER);
	
	if (doc == NULL)
    {
		return nil;
    }
	
	NSArray *result = PerformXPathQuery(doc, query, children, recursive);
	xmlFreeDoc(doc);
	
	return result;
}
