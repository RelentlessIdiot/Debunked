//  Created by David Golightly on 2/16/09.
//  Copyright 2009 David Golightly. All rights reserved.
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

#import "NSWebViewURLRequest.h"


// Some though should be applied here.  For instance the current trimming algorithm removes cached image
// files until the disc cache returns to approximatyely 75% of capacity. So you wouldn't want image sizes
// bigger than 1/4 of the cache size or trims would happen for each image request.
#define kMaxDiskCacheSize 10e6

// Uncomment to enable debugging NSLog statements
//#define DiskCacheDebug

@interface DiskCache : NSObject
{
@private
	NSString *_cacheDir;
	NSUInteger _cacheSize;
}

@property (nonatomic, readonly) NSUInteger sizeOfCache;
@property (nonatomic, readonly) NSString *cacheDir;

+ (DiskCache *)sharedCache;

- (NSData *)dataInCacheForURLString:(NSString *)urlString;
- (NSData *)dataInCacheForURLString:(NSString *)urlString withExpiration:(NSInteger)expiration;
- (NSData *)imageDataInCacheForURLString:(NSString *)urlString;
- (void)cacheData:(NSData *)data   
		  request:(NSWebViewURLRequest *)request
		 response:(NSURLResponse *)response;
- (void)cacheImageData:(NSData *)imageData   
			   request:(NSWebViewURLRequest *)request
			  response:(NSURLResponse *)response;
- (void)clearCachedDataForRequest:(NSWebViewURLRequest *)request;


@end
