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

#import "CachedDataLoader.h"
#import "DiskCache.h"
#import "RefreshConsumer.h"


const NSInteger maxDownloadConnections = 1;

static CachedDataLoader *sharedInstance = nil;


@interface CachedDataLoader (Privates)
- (void)loadDataForClient:(NSArray *)args;
- (BOOL)loadDataRemotelyForClient:(DataConsumer *)request withExpiration:(NSInteger)expiration;
- (void)alertUserOfNetworkFailure;
@end


@implementation CachedDataLoader

- (void)dealloc
{
	[_dataDownloadQueue cancelAllOperations];
	[_dataDownloadQueue release];
	
	[super dealloc];
}


- (id)init
{
	if (self = [super init]) {
		_dataDownloadQueue = [[NSOperationQueue alloc] init];
		[_dataDownloadQueue setMaxConcurrentOperationCount:maxDownloadConnections];
	}
	return self;
}


- (void)addClientToDownloadQueue:(DataConsumer *)client {
	return [self addClientToDownloadQueue:client withExpiration:-1];
}	
	
- (void)addClientToDownloadQueue:(DataConsumer *)client withExpiration:(NSInteger)expiration
{
	if (client == nil || [client request] == nil)
	{
		return;
	}
	
	NSData *cachedData = [self cachedDataForClient:client withExpiration:expiration];
    if (cachedData != nil) {
		NSURLResponse *response = [self cachedResponseForRequest:[client request]];
		if ([self isRefreshResponse:cachedData]) {
			[self resolveRefreshResponse:response withClient:client withData:cachedData withExpiration:expiration];
			return;
		}
        [client receiveData:cachedData withResponse:response];
    } else {
		[_dataDownloadQueue setSuspended:NO];
		NSArray *args = [NSArray arrayWithObjects:client, [NSNumber numberWithInteger:expiration], nil];
		NSOperation *dataDownloadOp = [[[NSInvocationOperation alloc] initWithTarget:self 
																			 selector:@selector(loadDataForClient:) 
																			   object:args] autorelease];
		[_dataDownloadQueue addOperation:dataDownloadOp];
	}
}

- (void)loadDataForClient:(NSArray *)args {
	DataConsumer *client = [args objectAtIndex:0];
	NSInteger expiration = [[args objectAtIndex:1] intValue];
	
	if (![self loadDataRemotelyForClient:client withExpiration:expiration]) {
		[self addClientToDownloadQueue:client withExpiration:expiration];
	}
}


- (void)suspendDataDownloads {
	[_dataDownloadQueue setSuspended:YES];
}


- (void)resumeDataDownloads {
	[_dataDownloadQueue setSuspended:NO];
}


- (void)cancelDataDownloads {
	[_dataDownloadQueue cancelAllOperations];
}

- (NSURLResponse *)cachedResponseForRequest:(NSWebViewURLRequest *) request
{
	NSURLResponse *response = nil;
	NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
	
	if (cachedResponse) {
		response = [cachedResponse response];
	}
	if (response == nil) {
		response = [[[NSURLResponse alloc] initWithURL:[request URL] 
											  MIMEType:@"application/octet-stream"
								 expectedContentLength:0
									  textEncodingName:nil] 
					autorelease];
	}
	return response;
}

- (NSData *)cachedDataForClient:(DataConsumer *)client withExpiration:(NSInteger) expiration
{
	NSWebViewURLRequest *request = [client request];
	return [[DiskCache sharedCache] dataInCacheForURLString:[[request URL] absoluteString] withExpiration: expiration];
}

- (BOOL)isRefreshResponse:(NSData *)data
{
	if([data length] < 1024) {
		NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[stringData autorelease];
		NSString *refreshPrefix = @"<meta http-equiv=\"refresh\" content=\"0; url=";
		if ([[stringData lowercaseString] hasPrefix:refreshPrefix]) {
			return YES;
		}
	}
	return NO;
}

- (void)resolveRefreshResponse:(NSURLResponse *)response withClient:(DataConsumer *)client withData:(NSData *)data withExpiration:(NSInteger)expiration
{
	NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[stringData autorelease];
	NSString *refreshPrefix = @"<meta http-equiv=\"refresh\" content=\"0; url=";
	
	NSURL *responseUrl = [response URL];
	NSString *responseUrlString = [responseUrl absoluteString];
	NSString *newFile = [stringData substringFromIndex:[refreshPrefix length]];
	newFile = [[newFile componentsSeparatedByString:@"\""] objectAtIndex:0];
	NSString *newUrl = nil;
	if ([newFile hasPrefix:@"/"]) {
		NSString *oldPath = [responseUrl path];
		NSString *baseUrl = [responseUrlString substringToIndex:[responseUrlString length] - [oldPath length]];
		newUrl = [baseUrl stringByAppendingString:newFile];
	} else {
		NSString *oldPath = [[responseUrlString componentsSeparatedByString:@"/"] lastObject];
		NSString *baseUrl = [responseUrlString substringToIndex:[responseUrlString length] - [oldPath length]];
		newUrl = [baseUrl stringByAppendingString:newFile];
	}
	client.targetUrl = newUrl;
	RefreshConsumer *refreshConsumer = [[RefreshConsumer alloc] initWithClient:client withUrl:newUrl];
	[self addClientToDownloadQueue:refreshConsumer withExpiration:expiration];
	[refreshConsumer release];
}

- (void)alertUserOfNetworkFailure {
	NSString *title = @"Cannot Load Data";
	NSString *message = @"Cannot load data because the device is not connected to the Internet.";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (BOOL)loadDataRemotelyForClient:(DataConsumer *)client withExpiration:(NSInteger)expiration {
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	
	NSWebViewURLRequest *request = [client request];
	NSData *data = [NSURLConnection sendSynchronousRequest:request 
										 returningResponse:&response 
													 error:&error];
	if ([self isRefreshResponse:data]) {
		[[DiskCache sharedCache] cacheData:data 
								   request:request
								  response:response];
		[self resolveRefreshResponse:response withClient:client withData:data withExpiration:expiration];
		return YES;
	}
	
	if (error != nil) {
        NSInteger code = [error code];
		
		if (code == NSURLErrorNetworkConnectionLost ||
			code == NSURLErrorNotConnectedToInternet) {
			
			[self performSelectorOnMainThread:@selector(alertUserOfNetworkFailure) withObject:nil waitUntilDone:YES];
			[client receiveData:nil withResponse:response];
			return YES;
		}
		
        if (code == NSURLErrorUnsupportedURL ||
            code == NSURLErrorBadURL ||
            code == NSURLErrorBadServerResponse ||
            code == NSURLErrorRedirectToNonExistentLocation ||
            code == NSURLErrorFileDoesNotExist ||
            code == NSURLErrorFileIsDirectory ||
            code == NSURLErrorRedirectToNonExistentLocation) {
            // the above status codes are permanent fatal errors; don't retry
			[client receiveData:nil withResponse:response];
            return YES;
        }
	} else if (data != nil && response != nil) {
		[[DiskCache sharedCache] cacheData:data 
								   request:request
								  response:response];
		
		if (data == nil) {
			[[DiskCache sharedCache] clearCachedDataForRequest:[client request]];
		} else {
			[client receiveData:data withResponse:response];
			return YES;
		}
		
	}
	return NO;
}


#pragma mark
#pragma mark ---- singleton implementation ----

+ (CachedDataLoader *)sharedDataLoader {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[super allocWithZone: nil] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone { return sharedInstance; }
- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (NSUInteger)retainCount { return UINT_MAX; } //denotes an object that cannot be released
- (oneway void)release {} // never release
- (id)autorelease { return self; }

@end
