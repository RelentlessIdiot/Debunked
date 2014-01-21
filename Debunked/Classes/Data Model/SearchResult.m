//  Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
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

#import "SearchResult.h"


@implementation SearchResult

@synthesize	title;
@synthesize	url;
@synthesize	synopsis;
@synthesize	rumorHeadline;

- (id)init
{
	return [self initWithTitle:nil withUrl:nil withSynopsis:nil withRumorHeadline:nil];
}

- (id)initWithTitle:(NSString *)theTitle
			withUrl:(NSString *)theUrl
	   withSynopsis:(NSString *)theSynopsis
  withRumorHeadline:(NSString *)theRumorHeadline
{
	if(self == [super init]) {
		self.title = theTitle;
		self.url = theUrl;
		self.synopsis = theSynopsis;
		self.rumorHeadline = theRumorHeadline;
	}
	return self;
}


- (void)dealloc {
	[title release];
	[url release];
	[synopsis release];
	[rumorHeadline release];

	[super dealloc];
}
@end
