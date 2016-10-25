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

#import "Top25RumorConsumer.h"


@implementation Top25RumorConsumer

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

- (void)receiveData:(NSData *)data withResponse:(NSURLResponse *)response
{
	if (data == nil) {
		[self.delegate receive:nil withResult:0];
		return;
	}

    NSArray *rumorNodes = [self parseRumorNodes:data];
    [self.dataSource loadRumorNodes:rumorNodes];
    [self.delegate receiveRumorNodes:rumorNodes withResult:0];
}

- (void)dealloc {
	[delegate release];
	[dataSource release];
	
	[super dealloc];
}

@end
