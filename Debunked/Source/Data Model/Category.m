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

#import "Category.h"


@implementation Category

@synthesize url;
@synthesize label;
@synthesize description;
@synthesize categoryNodes;
@synthesize rumorNodes;

- (NSInteger)nodeCount {
    return (rumorNodes.count > 0) ? rumorNodes.count : categoryNodes.count;
}

- (void)dealloc
{
    [url release];
    [label release];
    [description release];
    [categoryNodes release];
    [rumorNodes release];

    [super dealloc];
}

- (id)init
{
    return [self initWithUrl:@"" withLabel:@"" withDescription:@""];
}

- (id)initWithUrl:(NSString *)theUrl
{
    return [self initWithUrl:theUrl	withLabel:@"" withDescription:@""];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel
{
    return [self initWithUrl:theUrl	withLabel:theLabel withDescription:@""];
}

- (id)initWithUrl:(NSString *)theUrl 
		withLabel:(NSString *)theLabel 
  withDescription:(NSString *)theDescription
{
	if(self = [super init]) {
		self.url = theUrl;
		self.label = theLabel;
		self.description = theDescription;
		self.categoryNodes = [NSArray array];
		self.rumorNodes = [NSArray array];
	}
	return self;
}

@end
