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

#import <Foundation/Foundation.h>


@interface Rumor : NSObject {
	NSString *veracity;
	NSString *url;
	NSString *title;
	NSString *claim;
	NSString *origin;
	NSString *sightings;
	NSString *lastUpdated;
	NSMutableArray *examples;
	NSMutableArray *variations;
	NSMutableArray *sources;
	NSString *rawHtml;
}

@property (nonatomic,retain) NSString *veracity;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *claim;
@property (nonatomic,retain) NSString *origin;
@property (nonatomic,retain) NSString *sightings;
@property (nonatomic,retain) NSString *lastUpdated;
@property (nonatomic,retain) NSMutableArray *examples;
@property (nonatomic,retain) NSMutableArray *variations;
@property (nonatomic,retain) NSMutableArray *sources;
@property (nonatomic,retain) NSString *rawHtml;

@end
