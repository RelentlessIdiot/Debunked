//  Created by David Golightly on 2/16/09.
//  Copyright 2009 David Golightly. All rights reserved.
//
//
//  Modifications Copyright (c) 2009-2013 Robert Ruana <rob@relentlessidiot.com>
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


@protocol ImageConsumer <NSObject>
- (NSWebViewURLRequest *)request;
- (void)renderImage:(UIImage *)image;
@end


@interface CachedImageLoader : NSObject {
@private
	NSOperationQueue *_imageDownloadQueue;
}


+ (CachedImageLoader *)sharedImageLoader;


- (void)addClientToDownloadQueue:(id<ImageConsumer>)client;
- (UIImage *)cachedImageForClient:(id<ImageConsumer>)client;

- (void)suspendImageDownloads;
- (void)resumeImageDownloads;
- (void)cancelImageDownloads;


@end
