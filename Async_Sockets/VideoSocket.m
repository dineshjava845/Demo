//
//  VideoSocket.m
//

#import "VideoSocket.h"
#import "PatientData.h"
#import "SNGCCUSharedManager.h"
#import "RequestManager.h"
#import "UserGeneralSetting.h"
#import "CustomAlert.h"
#import "Logs.h"

#define kBufferSize 147456
#define kUploadSize 393216
#define kStackSize 1048576
@interface VideoSocket()
{
    NSString *folderPathToSaveFile;
    u32 expectedFileSize;
    u32 downloadedFileSize;
    msg_media_t mediaMetadata;
    NSTimeInterval downloadTimeInterval;
    NSFileHandle *downloadFileHandle;
    NSString *downloadingFilePath;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    
    RequestManager *requestManager;
    BOOL usbQueryResponseExpected;
    NSString *uploadFileSourcePath;
    NSString *uploadFileName;
    NSString *destinationFolderName;
    NSFileHandle *uploadFileHandle;
    NSTimeInterval uploadTimeInterval;
    unsigned long long uploadFileOffset;
    BOOL isUploadingFile;
    unsigned long long uploadFileSize;
    
    bool writeStreamOpen;
    NSMutableData *writeStreamDataBuffer;
    
}
@property(nonatomic,readwrite)	NSString	*urlString;
@property(nonatomic,readwrite)	NSInteger	portNumber;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) unsigned long long totalBytesReadBySocket;

- (void)socketDidReadData:(NSData *)data;

@end

@implementation VideoSocket

@synthesize delegate;

@synthesize urlString, portNumber;

- (id)initWithURLString:(NSString*)url port:(NSInteger)port
{
    self = [super init];
	
	if (self != nil)
    {
        [self setStackSize:kStackSize];
        [self setThreadPriority:0.95];
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 8.0) [self setQualityOfService:NSQualityOfServiceUserInitiated];//NSQualityOfServiceUserInteractive
        [self setName:@"Video_Socket_Thread"];
		self.urlString = url;
		self.portNumber = port;
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"telnet://%@:%i", self.urlString, (int)self.portNumber]];
        requestManager = [[RequestManager alloc] init];
	}
	return self;
}

/*- (void)start
 {
 
 
 NSThread *backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadCurrentStatus:) object:url];
 [backgroundThread setThreadPriority:1.0];
 [backgroundThread start];
 }*/

- (void)main{
    @autoreleasepool {
        // keep a reference to self to use for controller callbacks
        CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        // get callbacks for stream data, stream end, and any errors
        CFOptionFlags registeredEvents =  (kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred);
        
        //create a read-only socket
        
        //CFWriteStreamRef writeStream;
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[self.url host], (UInt32)[[self.url port] integerValue], &readStream, &writeStream); // see CFStreamCreatePairWithSocketToHost declaration, fix bug 711
        
        // Indicate that we want socket to be closed whenever streams are closed
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        // schedule the stream on the run loop to enable callbacks
        if (CFReadStreamSetClient(readStream, registeredEvents, videoSocketReadStreamCallback, &ctx)) {
            CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
        } else {
            //NSLog(@"Failed to assign callback method : Read Stream");
            return;
        }
        if (CFWriteStreamSetClient(writeStream, registeredEvents, videoSocketWriteStreamCallback, &ctx)) {
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
        } else {
            //NSLog(@"Failed to assign callback method : Write Stream");
            return;
        }
        
        
        
        // open the stream for reading
        if (CFReadStreamOpen(readStream) == NO) {
            //NSLog(@"Failed to open read stream");
            return;
        }
        
        CFErrorRef error = CFReadStreamCopyError(readStream);
        
        if (error != NULL) {
            if (CFErrorGetCode(error) != 0) {
                //NSLog(@"Failed to connect read stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
            }
            
            CFRelease(error);
            return;
        }
        
        // open the stream for reading
        writeStreamDataBuffer = [[NSMutableData alloc] init];
        if (CFWriteStreamOpen(writeStream) == NO) {
            //NSLog(@"Failed to open write stream");
            return;
        }
        
        CFErrorRef writeError = CFWriteStreamCopyError(writeStream);
        
        if (writeError != NULL) {
            if (CFErrorGetCode(error) != 0) {
                //NSLog(@"Failed to connect write stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
            }
            
            CFRelease(writeError);
            return;
        }
        
        //NSLog(@"Successfully connected to %@", self.url);
        //start processing
        //CFRunLoopRun();
        // We can't run the run loop unless it has an associated input source or a timer.
        // So we'll just create a timer that will never fire - unless the server runs for decades.
        [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow] target:self selector:@selector(ignore:) userInfo:nil repeats:YES];
        
        NSThread *currentThread = [NSThread currentThread];
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        
        BOOL isCancelled = [currentThread isCancelled];
        
        while (!isCancelled && [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
        {
            isCancelled = [currentThread isCancelled];
        }
    }
}
+ (void)ignore:(id)_
{}

void videoSocketReadStreamCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr) {
    VideoSocket *currentSocket = (__bridge VideoSocket*)myPtr;
	
	switch(event) {
        case kCFStreamEventOpenCompleted:
            [currentSocket.delegate advancedVideoSocketConnected];
            break;
            
            
        case kCFStreamEventHasBytesAvailable:
        {
            //read bytes until there are no more
            while (CFReadStreamHasBytesAvailable(stream))
            {
                UInt8 buffer[kBufferSize];
                CFIndex numBytesRead = CFReadStreamRead(stream, buffer, kBufferSize);
                currentSocket.totalBytesReadBySocket += numBytesRead;
                //NSLog(@"Bytes Read:%ld",numBytesRead);
                if (numBytesRead>0)
                    [currentSocket socketDidReadData:[NSData dataWithBytes:buffer length:numBytesRead]];
            }
            /*NSData *theData = NULL;
            CFIndex theBufferLength = 0;
            const UInt8 *theBufferPtr = CFReadStreamGetBuffer(stream, theBufferLength, &theBufferLength);
            if (theBufferPtr != NULL)
            {
                //NSLog(@"Bytes Read:%ld",theBufferLength);
                theData = [NSData dataWithBytesNoCopy:(void *)theBufferPtr length:theBufferLength freeWhenDone:NO];
                [currentSocket socketDidReadData:theData];
            }*/
            break;
        }
			
			
        case kCFStreamEventErrorOccurred: {
			CFErrorRef error = CFReadStreamCopyError(stream);
			
			if (error != NULL) {
				if (CFErrorGetCode(error) != 0) {
					//NSLog(@"Failed while reading stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
				}
				
				CFRelease(error);
			}
			
			// clean up the stream
			CFReadStreamClose(stream);
			
			// stop processing callback methods
			CFReadStreamUnscheduleFromRunLoop(stream,
											  CFRunLoopGetCurrent(),
											  kCFRunLoopCommonModes);
			
			// end the thread's run loop
			CFRunLoopStop(CFRunLoopGetCurrent());
            [currentSocket.delegate advancedVideoSocketDisConnected];
            break;
			
		}
			
        case kCFStreamEventEndEncountered:
            //NSLog(@"Read Stream:kCFStreamEventEndEncountered");
			//[controller didFinishReceivingData];
			
			// clean up the stream
			CFReadStreamClose(stream);
			
			// stop processing callback methods
			CFReadStreamUnscheduleFromRunLoop(stream,
											  CFRunLoopGetCurrent(),
											  kCFRunLoopCommonModes);
			
			// end the thread's run loop
			CFRunLoopStop(CFRunLoopGetCurrent());
            [currentSocket.delegate advancedVideoSocketDisConnected];
            stream = NULL;
            break;
			
        default:
            break;
    }
}

- (void)socketDidReadData:(NSData *)data
{
    NSUInteger dataLength = [data length];
   
    if(expectedFileSize != 0)
    {
        [self updateDownloadingFile:data];
        return;
    }
    
    Byte *bytedata  = (Byte *)malloc(dataLength);
    [data  getBytes:bytedata length:dataLength];
    if (bytedata[0] == PROTOCOL_USB_TO_TABLET)
    {
        
        switch (bytedata[1])
        {
                
            case USB_TABLET_FILE_COMPLETION_EVENT:
            {
                file_complete_response_t resp;
                resp.mediaType = MEDIA_VIDEO;
                
                PatientData *patientData = [PatientData sharedManager];
                UserGeneralSetting *settings = [UserGeneralSetting sharedUserSettings];
                //float deviceValue = [settings storageLevelSet];
                BOOL isLowStorage = NO;
                isLowStorage = settings.lowStorageAlert;
                //if ([patientData.patientMrnId length]!=0 && [patientData.lockStatus isEqualToString:@"unlocked"] && ([[SNGCCUSharedManager sharedCCManager]encodingFolderStateOnCCU] == VALID)) resp.response = FILE_COMPLETION_ACK
                if ([patientData.patientMrnId length]!=0 && [patientData.lockStatus isEqualToString:@"unlocked"] && !isLowStorage && [[SNGCCUSharedManager sharedCCManager] encodingFolderStateOnCCU] != SET_ENCODING_FOLDER_RESPONSE_INVALID_STATE && [[SNGCCUSharedManager sharedCCManager] encodingFolderStateOnCCU] != SET_ENCODING_FOLDER_RESPONSE_INVALID_FOLDER_NAME) resp.response = FILE_COMPLETION_ACK;
                else
                {
                    
                    resp.response = FILE_COMPLETION_NACK;
                    if (isLowStorage)
                    {
                        [self.delegate NACKResponseToFileCompletionEventVideoChannel];
                        
                        /*dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"Device storage is lower than %d%% of total device storage. Cannot receive files.",nil),(int)deviceValue];
                            Input_AlertDialog(NSLocalizedString(@"Low Storage!",nil), messageString, 1, nil, NSLocalizedString(@"OK",nil), nil, NO);
                        });*/
                    }
                    NSString *description = @"NACK Response Sent To Video File Completion Event";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [Logs writeAccessDataToFileWithDescription:description andTitle:@"NACK Event"];
                    });
                }
                [self.delegate advancedSendVideoFileCompletionResponseAck:resp];
                
                //NSLog(@"Did Read : USB_TABLET_FILE_COMPLETION_EVENT");
            }
                break;
            case USB_TABLET_STOP_VIDEO_RECORD_RESPONSE:{
                [data getBytes:&mediaMetadata length:sizeof(mediaMetadata)];
                //mediaMetadata.fileSize = ntohl(mediaMetadata.fileSize);
                expectedFileSize = ntohl(mediaMetadata.fileSize);
                downloadedFileSize = 0;
                NSString *filename = [NSString stringWithFormat:@"%s",mediaMetadata.fileName];
                NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
                if(folderPathToSaveFile != nil && folderPathToSaveFile.length > 0){
                    downloadingFilePath = [folderPathToSaveFile stringByAppendingPathComponent:filename];
                    
                }else{
                    downloadingFilePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:filename];
                }
                
                NSFileManager *filemgr;
                filemgr =[NSFileManager defaultManager];
                [filemgr createFileAtPath:downloadingFilePath contents:nil attributes:nil];
                downloadFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:downloadingFilePath];
                downloadTimeInterval = [NSDate timeIntervalSinceReferenceDate];
                //NSLog(@"Did Read : USB_TABLET_STOP_VIDEO_RECORD_RESPONSE - File name:%s Size:%d Length:%d",mediaMetadata.fileName,ntohl(mediaMetadata.fileSize),[data length]);
                if ([data length]>50)
                {
                    //filter this data & reiterate the method
                    NSData *additionalData = [data subdataWithRange:NSMakeRange(50, ([data length]-50))];
                    [self updateDownloadingFile:additionalData];
                }
                
            }
                break;
            default:
                break;
        }
    }
    
    free(bytedata);
}

-(void)updateDownloadingFile:(NSData *)data
{
    NSUInteger dataLength = [data length];
    //NSLog(@"Did Read : A Data Chunk of File:%d",dataLength);
    downloadedFileSize += dataLength;
    
    NSString *filename = [NSString stringWithFormat:@"%s",mediaMetadata.fileName];
    NSInteger totalSize = expectedFileSize;
    
    [downloadFileHandle seekToEndOfFile];
    [downloadFileHandle writeData:data];
    [downloadFileHandle synchronizeFile];
    
    [self.delegate advancedVideoDownloadingProgress:totalSize completed:downloadedFileSize filename:filename mediaType:MEDIA_VIDEO];
    
    if(downloadedFileSize >= expectedFileSize)
    {
        //NSLog(@"Did Read : Last Packet of File:%d",dataLength);
        expectedFileSize = 0;
        file_complete_response_t resp;
        resp.mediaType = MEDIA_VIDEO;
        resp.response = FILE_RECEIVED_ACK;
        [self.delegate advancedSendVideoFileReceivedResponse:resp];
        [self.delegate advancedVideoDownloaded:downloadingFilePath fileSize:totalSize downloadTime:[NSDate timeIntervalSinceReferenceDate] - downloadTimeInterval mediaType:MEDIA_VIDEO];
    }
}

- (float)getPercentageOfStorageAvailableOnDevice
{
    //NSLog(@"Start Time:%@",[NSDate date]);
    float freeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary){
        NSNumber *fileSystemFreeSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
        freeSpace = [fileSystemFreeSizeInBytes floatValue];
    } else
    {
        //Handle error
    }
    
    float totalDeviceSpace = 0.0f;
    if (dictionary){
        NSNumber *fileSystemTotalSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalDeviceSpace = [fileSystemTotalSizeInBytes floatValue];
    } else
    {
        //Handle error
    }
    //NSLog(@"End Time:%@",[NSDate date]);
    return freeSpace/totalDeviceSpace;
}

-(void)setFolderPath:(NSString*)path{
    folderPathToSaveFile = [NSString stringWithFormat:@"%@",path];
}
//Dispatch writeStream event handling
void videoSocketWriteStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    VideoSocket* currentSocket = (__bridge VideoSocket *)info;
    switch(eventType)
    {
        case kCFStreamEventOpenCompleted:
            //NSLog(@"Write Stream:kCFStreamEventOpenCompleted");
            break;
            
            
        case kCFStreamEventCanAcceptBytes:
            //NSLog(@"Write Stream:kCFStreamEventCanAcceptBytes");
            [currentSocket writeDataBufferToWriteStream];
            break;
            
        case kCFStreamEventErrorOccurred:
        {
            CFErrorRef error = CFWriteStreamCopyError(stream);
            
            if (error != NULL)
            {
                if (CFErrorGetCode(error) != 0)
                {
                    //NSLog(@"Failed while writing stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
                }
                CFRelease(error);
            }
            
            // clean up the stream
            CFWriteStreamClose(stream);
            
            // stop processing callback methods
            CFWriteStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(),  kCFRunLoopCommonModes);
            
            // end the thread's run loop
            CFRunLoopStop(CFRunLoopGetCurrent());
            stream = NULL;
            [currentSocket.delegate advancedVideoSocketDisConnected];
        }
            break;
        case kCFStreamEventEndEncountered:
            //NSLog(@"Write Stream:kCFStreamEventEndEncountered");
            // clean up the stream
            CFWriteStreamClose(stream);
            
            // stop processing callback methods
            CFWriteStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            // end the thread's run loop
            CFRunLoopStop(CFRunLoopGetCurrent());
            stream = NULL;
            [currentSocket.delegate advancedVideoSocketDisConnected];
            break;
            
        default:
            break;
    }
}
-(void)queryUSBToSendFileOnVideoChannel:(NSArray *)dataArray
{
    NSLog(@"Query USB Video Channel");
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });*/
    
    
    NSData *queryUSBData = [requestManager GetQueryUSBReady:MEDIA_VIDEO folderName:dataArray[0] withFileSize:(unsigned int)[dataArray[1] unsignedLongLongValue]];  // fix bug 711
    // Can stream take any data in?
    [writeStreamDataBuffer appendData:queryUSBData];
    [self writeDataBufferToWriteStream];
    
    // Write as much as we can
    //CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [queryUSBData bytes], [queryUSBData length]);
    usbQueryResponseExpected =  YES;
    //NSLog(@"Written Bytes:%ld Expected:%d",writtenBytes,[queryUSBData length]);
    
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(usbQueeryResponsereceived:) withObject:[NSArray arrayWithArray:dataArray] afterDelay:1.0];
    });*/
}
- (void)writeDataBufferToWriteStream {
    @synchronized(self)
    {
        //Do we have anything to write?
        
        
        if ([writeStreamDataBuffer length] == 0 && isUploadingFile)
        {
            if (uploadFileOffset >= uploadFileSize)
            {
                //NSLog(@"Final Data uploaded");
                [uploadFileHandle closeFile];
                uploadFileHandle = nil;
                isUploadingFile = NO;
                [self.delegate advancedVideoFileUploaded:uploadFileSourcePath fileSize:uploadFileSize uploadTime:uploadTimeInterval];
            }
            else
            {
                //NSLog(@"upload next chenunk of file");
                [self uploadFile];
            }
            
            return;
        }
        
        if ([writeStreamDataBuffer length] == 0) return;
    
        //Can stream take any data in?
        if (!CFWriteStreamCanAcceptBytes(writeStream)) return;

        // Write as much as we can
        CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [writeStreamDataBuffer bytes], [writeStreamDataBuffer length]);
        //NSLog(@"WRITTEN BYTES:%ld",writtenBytes);
        if (writtenBytes == -1) return;
    
        NSRange range = {0, writtenBytes};
        [writeStreamDataBuffer replaceBytesInRange:range withBytes:NULL length:0];
        
        
    }
}
- (void)usbQueeryResponsereceived:(NSArray*)dataArray
{
    //NSLog(@"Check if query response is recived");
    if (usbQueryResponseExpected)
        [self queryUSBToSendFileOnVideoChannel:dataArray];
}

-(void)sendFile:(NSString*)sourceFilePath fileName:(NSString*)sourceFileName folderName:(NSString*)desstinationFolderPath
{
    usbQueryResponseExpected = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });
    
    uploadFileSourcePath = sourceFilePath;
    uploadFileName = sourceFileName;
    destinationFolderName = desstinationFolderPath;
    isUploadingFile =  YES;

    [self startUpload];
}
-(void)sendFileToUSB:(NSArray *)filePaths
{
    usbQueryResponseExpected = NO;
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });*/
    
    uploadFileSourcePath = [filePaths objectAtIndex:0];
    uploadFileName = [filePaths objectAtIndex:1];
    destinationFolderName = [filePaths objectAtIndex:2];
    isUploadingFile =  YES;
    
    [self startUpload];
}

- (void)startUpload{
    usbQueryResponseExpected =  NO;
    uploadFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:uploadFileSourcePath error:nil][NSFileSize] unsignedLongLongValue];
    
    NSData *data = [requestManager GetSendFile:(u32)uploadFileSize fileName:uploadFileName folderName:destinationFolderName mediaType:MEDIA_VIDEO]; // see GetSendFile, fix bug 711
    /*if ( !CFWriteStreamCanAcceptBytes(writeStream) )
    {
        //NSLog(@"Cannot write data!!!");
        return;
    }
    
    // Write as much as we can
    CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [data bytes], [data length]);
    //NSLog(@"Written Bytes:%ld ,Expected:%d",writtenBytes,[data length]);*/
    [writeStreamDataBuffer appendData:data];
    [self writeDataBufferToWriteStream];
    isUploadingFile =  YES;
    [self uploadFile];
}
- (void) uploadFile{
    if(uploadFileHandle == nil){
        uploadFileOffset = 0;
        isUploadingFile =  YES;
        uploadTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        uploadFileHandle = [NSFileHandle fileHandleForReadingAtPath:uploadFileSourcePath];
    }
    [self sendChunk];
}
- (void) sendChunk{
    if(uploadFileHandle == nil) return;
    
    NSData *uploadData = [uploadFileHandle readDataOfLength:kUploadSize];
    if(uploadData != nil && [uploadData length] > 0 )
    {
        uploadFileOffset += [uploadData length];
        [uploadFileHandle seekToFileOffset:uploadFileOffset];
        int current = (int)[uploadData length];
        [writeStreamDataBuffer appendData:uploadData];
        [self writeDataBufferToWriteStream];
        [self.delegate advancedVideoFileUploadingProgress:uploadFileSize completed:current filename:uploadFileName mediaType:MEDIA_VIDEO];
        return;
    }
    else{
        //
    }
}
- (BOOL)fileReceptionInProgress
{
    if (expectedFileSize != 0)
    {
        return YES;
    }
    else return NO;
}
- (BOOL)fileTransmissionInProgress
{
    if (isUploadingFile)
    {
        return YES;
    }
    else return NO;
}
-(void)bytesReadOnVidChannel
{
    //NSLog(@"Bytes Read On Video Socket:%lld",self.totalBytesReadBySocket);
}
-(void)resetData
{
    self.delegate = nil;
    folderPathToSaveFile = nil;
    expectedFileSize = 0;
    downloadedFileSize = 0;
    downloadTimeInterval = 0.0f;
    downloadFileHandle = nil;
    downloadingFilePath = nil;
    
    
    requestManager = nil;
    usbQueryResponseExpected = NO;
    uploadFileSourcePath = nil;
    uploadFileName = nil;
    destinationFolderName = nil;
    uploadFileHandle = nil;
    uploadTimeInterval = 0.0f;
    uploadFileOffset = 0;
    isUploadingFile = NO;
    uploadFileSize = 0;
    
    writeStreamOpen=NO;
    writeStreamDataBuffer = nil;
    // clean up the stream
    CFWriteStreamClose(writeStream);
    
    // stop processing callback methods
    CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // end the thread's run loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    writeStream = NULL;
    
    // clean up the stream
    CFReadStreamClose(readStream);
    
    // stop processing callback methods
    CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // end the thread's run loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    readStream = NULL;
    
    [[NSThread currentThread] cancel]; // set isCancelled flag
}

-(void)dealloc
{
    //NSLog(@"Video Socket Deallocated");
    self.delegate = nil;
    folderPathToSaveFile = nil;
    expectedFileSize = 0;
    downloadedFileSize = 0;
    downloadTimeInterval = 0.0f;
    downloadFileHandle = nil;
    downloadingFilePath = nil;
    
    
    requestManager = nil;
    usbQueryResponseExpected = NO;
    uploadFileSourcePath = nil;
    uploadFileName = nil;
    destinationFolderName = nil;
    uploadFileHandle = nil;
    uploadTimeInterval = 0.0f;
    uploadFileOffset = 0;
    isUploadingFile = NO;
    uploadFileSize = 0;
    
    writeStreamOpen=NO;
    writeStreamDataBuffer = nil;
    // clean up the stream
    CFWriteStreamClose(writeStream);
    
    // stop processing callback methods
    CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // end the thread's run loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    writeStream = NULL;
    
    // clean up the stream
    CFReadStreamClose(readStream);
    
    // stop processing callback methods
    CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // end the thread's run loop
    CFRunLoopStop(CFRunLoopGetCurrent());
    readStream = NULL;
    
    [[NSThread currentThread] cancel]; // set isCancelled flag
    
    // wake up the thread
    //[[self class] performSelector:@selector(ignore:) onThread:[NSThread currentThread] withObject:[NSNull null] waitUntilDone:NO];
}

// Write whatever data we have, as much of it as stream can handle
@end
