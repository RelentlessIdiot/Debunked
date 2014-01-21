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

#import "Blacklist.h"


@implementation Blacklist

static NSMutableArray *blacklist = nil;

+ (BOOL)isBlacklisted:(NSString *)url
{
	@synchronized(self) {
		if (blacklist == nil) {
			blacklist = [[NSMutableArray array] retain];
			NSString *blacklistPath = [[NSBundle mainBundle] pathForResource:@"Blacklist" ofType:@"txt"];
			NSArray *lines = [[NSString stringWithContentsOfFile:blacklistPath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
			for (NSString *line in lines) {
				line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				if (![line isEqual:@""] && ![line hasPrefix:@"#"]) {
					[blacklist addObject:[line lowercaseString]];
				}
			}
		}
	}
	
	for (NSString *item in blacklist) {
		NSRange textRange = [[url lowercaseString] rangeOfString:item];
		if(textRange.location != NSNotFound) {
			return YES;
		}
	}
	return NO;
}


@end
