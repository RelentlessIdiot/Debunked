//  Created by David Golightly on 2/16/09.
//  Copyright 2009 David Golightly. All rights reserved.
//
//
//  Modifications Copyright (c) 2009-2014 Robert Ruana <rob@relentlessidiot.com>
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

#import "CachedImageLoader.h"
#import "DiskCache.h"


const NSInteger kMaxDownloadConnections	= 1;

static CachedImageLoader *sharedInstance;


@interface CachedImageLoader (Privates)
- (void)loadImageForClient:(id<ImageConsumer>)client;
- (BOOL)loadImageRemotelyForClient:(id<ImageConsumer>)request;
@end


@implementation CachedImageLoader

- (void)dealloc {
	[_imageDownloadQueue cancelAllOperations];
	[_imageDownloadQueue release];

	[super dealloc];
}


- (id)init {
	if (self = [super init]) {
		_imageDownloadQueue = [[NSOperationQueue alloc] init];
		[_imageDownloadQueue setMaxConcurrentOperationCount:kMaxDownloadConnections];
	}
	return self;
}


- (void)addClientToDownloadQueue:(id<ImageConsumer>)client {
	if (client == nil || [client request] == nil)
	{
		return;
	}
    UIImage *cachedImage;
    if ((cachedImage = [self cachedImageForClient:client])) {
        [client renderImage:cachedImage];
    } else {
		[_imageDownloadQueue setSuspended:NO];
		NSOperation *imageDownloadOp = [[[NSInvocationOperation alloc] initWithTarget:self 
																			 selector:@selector(loadImageForClient:) 
																			   object:client] autorelease];
		[_imageDownloadQueue addOperation:imageDownloadOp];
	}
}

- (void)loadImageForClient:(id<ImageConsumer>)client {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![self loadImageRemotelyForClient:client]) {
		[self addClientToDownloadQueue:client];
	}
	
	[pool release];
}


- (void)suspendImageDownloads {
	[_imageDownloadQueue setSuspended:YES];
}


- (void)resumeImageDownloads {
	[_imageDownloadQueue setSuspended:NO];
}


- (void)cancelImageDownloads {
	[_imageDownloadQueue cancelAllOperations];
}


- (UIImage *)cachedImageForClient:(id<ImageConsumer>)client {
	NSData *imageData = nil;
	UIImage *image = nil;
	
	NSWebViewURLRequest *request = [client request];
	NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	
	if (cachedResponse) {
		imageData = [cachedResponse data];
		image = [UIImage imageWithData:imageData];
	}
	
	if (image == nil && 
		(imageData = [[DiskCache sharedCache] imageDataInCacheForURLString:[[request URL] absoluteString]])) {
		NSString *mimeType = [[[request URL] path] pathExtension];
		if ( [mimeType isEqualToString:@"jpg"] ) {
			mimeType = @"jpeg";
		}
#ifdef DiskCacheDebug	
		NSLog(@"MIMEtype=%@", mimeType );
#endif
		NSURLResponse *response = [[[NSURLResponse alloc] initWithURL:[request URL] 
															 MIMEType:[NSString stringWithFormat:@"image/%@", mimeType]
												expectedContentLength:[imageData length] 
													 textEncodingName:nil] 
								   autorelease];
		[[DiskCache sharedCache] cacheImageData:imageData 
										 request:request 
										response:response];
		image = [UIImage imageWithData:imageData];
	}
	
#ifdef DiskCacheDebug	
	if (image == nil) {
		NSLog(@"unable to find image data in cache: %@", request);
	}
#endif
	
	return image;
}


- (BOOL)loadImageRemotelyForClient:(id<ImageConsumer>)client {
	
	NSURLResponse *response = nil;
	NSError *error = nil;

	NSWebViewURLRequest *request = [client request];
	NSData *imageData = [NSURLConnection sendSynchronousRequest:request 
											  returningResponse:&response 
														  error:&error];
	
	if (error != nil) {
        NSInteger code = [error code];
        if (code == NSURLErrorNetworkConnectionLost ||
			code == NSURLErrorNotConnectedToInternet ||
			code == NSURLErrorUnsupportedURL ||
            code == NSURLErrorBadURL ||
            code == NSURLErrorBadServerResponse ||
            code == NSURLErrorRedirectToNonExistentLocation ||
            code == NSURLErrorFileDoesNotExist ||
            code == NSURLErrorFileIsDirectory ||
            code == NSURLErrorRedirectToNonExistentLocation) {
            // the above status codes are permanent fatal errors; don't retry
            return YES;
        }
	} else if (imageData != nil && response != nil) {
		[[DiskCache sharedCache] cacheImageData:imageData 
										 request:request
										response:response];
		
		UIImage *image = [UIImage imageWithData:imageData];
		if (image == nil) {
			[[DiskCache sharedCache] clearCachedDataForRequest:[client request]];
		} else {
			[client renderImage:image];
			return YES;
		}

	}
	return NO;
}


#pragma mark
#pragma mark ---- singleton implementation ----

+ (CachedImageLoader *)sharedImageLoader {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


@end
