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

#import "CategoryNode.h"


@implementation CategoryNode

@synthesize url;
@synthesize label;
@synthesize synopsis;
@synthesize imageUrl;

- (void)dealloc
{
    [url release];
    [label release];
    [synopsis release];
    [imageUrl release];

    [super dealloc];
}

- (id)init
{
    return [self initWithUrl:@"" withLabel:@"" withSynopsis:@""];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel
{
    return [self initWithUrl:theUrl	withLabel:theLabel withSynopsis:@""];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel 
	 withSynopsis:(NSString *)theSynopsis
{
    return [self initWithUrl:theUrl	withLabel:theLabel withSynopsis:@"" withImageUrl:nil];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel 
	 withSynopsis:(NSString *)theSynopsis
	 withImageUrl:(NSString *)theImageUrl
{
	if(self = [super init]) {
		self.url = theUrl;
		self.label = theLabel;
		self.synopsis = theSynopsis;
		self.imageUrl = theImageUrl;
	}
	return self;
}

@end
