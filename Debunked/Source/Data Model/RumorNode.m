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

#import "RumorNode.h"


@implementation RumorNode

+ (UIImage *)imageForVeracity:(NSString *)theVeracity
{
    NSString *veracity = [theVeracity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    veracity = [veracity lowercaseString];

    if ([veracity isEqual:@"true"]) {
        return [UIImage imageNamed:@"true.png"];
    } else if ([veracity isEqual:@"false"]) {
        return [UIImage imageNamed:@"false.png"];
    } else if ([veracity isEqual:@"truefalse"]) {
        return [UIImage imageNamed:@"truefalse.png"];
    } else if ([veracity isEqual:@"undetermined"]) {
        return [UIImage imageNamed:@"maybe.png"];
    } else if ([veracity isEqual:@"unknown"]) {
        return [UIImage imageNamed:@"unknown.png"];
    } else {
        return nil;
    }
}

@synthesize	veracity;
@synthesize	url;
@synthesize	synopsis;
@synthesize	label;
@synthesize	imageUrl;

- (UIImage *) veracityImage
{
	return [RumorNode imageForVeracity:self.veracity];
}

- (void)dealloc {
    [veracity release];
    [url release];
    [synopsis release];
    [label release];
    [imageUrl release];

    [super dealloc];
}

- (id)init
{
    return [self initWithUrl:@"" 
				   withLabel:@"" 
				withSynopsis:@"" 
				withVeracity:@"" 
				   withImageUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl 
	 withSynopsis:(NSString *)theSynopsis 
	 withVeracity:(NSString *)theVeracity
{
    return [self initWithUrl:theUrl 
				   withLabel:@""
				withSynopsis:theSynopsis
				withVeracity:theVeracity
				   withImageUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel
	 withSynopsis:(NSString *)theSynopsis 
	 withVeracity:(NSString *)theVeracity 
{
    return [self initWithUrl:theUrl 
				   withLabel:theLabel
				withSynopsis:theSynopsis
				withVeracity:theVeracity
				   withImageUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel
	 withSynopsis:(NSString *)theSynopsis 
	 withVeracity:(NSString *)theVeracity 
	 withImageUrl:(NSString *)theImageUrl
{
	if(self = [super init]) {
		self.url = theUrl;
		self.synopsis = theSynopsis;
		self.veracity = theVeracity;
		self.label = theLabel;
		self.imageUrl = theImageUrl;
	}
	return self;
}

@end
