//
//  ImageSocket.m
//  Gnome

//

#import "ImageSocket.h"
#import "PatientData.h"
#import "SNGCCUSharedManager.h"
#import "RequestManager.h"
#import "UserGeneralSetting.h"
#import "CustomAlert.h"
#import "Logs.h"


#define kBufferSize 294912
#define kUploadSize 36864
#define kStackSize 1048576
@interface ImageSocket()
{
    NSString *folderPathToSaveFile;
    NSUInteger expectedFileSize;
    NSUInteger downloadedFileSize;
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
    int uploadFileOffset;
    BOOL isUploadingFile;
    unsigned long long uploadFileSize;
    
    bool writeStreamOpen;
    NSMutableData *writeStreamDataBuffer;
    
    NSMutableData *imageFileDownloadBuffer;
}

@property (nonatomic,readwrite)	NSString	*urlString;
@property (nonatomic,readwrite) NSInteger	portNumber;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) unsigned long long totalBytesReadBySocket;

- (void)socketDidReadData:(NSData *)data;

@end

@implementation ImageSocket

@synthesize delegate;

@synthesize urlString, portNumber;

- (id)initWithURLString:(NSString*)url port:(NSInteger)port
{
    self = [super init];
	
	if (self != nil)
    {
        [self setStackSize:kStackSize];
        [self setName:@"Image_Socket_Thread"];
        [self setThreadPriority:0.99];
       
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 8.0) [self setQualityOfService:NSQualityOfServiceUserInitiated];//NSQualityOfServiceUserInteractive
        
		self.urlString = url;
		self.portNumber = port;
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"telnet://%@:%i", self.urlString, (int)self.portNumber]];
        self.totalBytesReadBySocket = 0;
        requestManager = [[RequestManager alloc] init];
        expectedFileSize = 0;
        downloadedFileSize =0;
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
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[self.url host], (UInt32)[[self.url port] integerValue], &readStream, &writeStream);  // fix bug 711 value conversion issue
        //setsockopt(<#int#>, <#int#>, <#int#>, <#const void *#>, <#socklen_t#>)
        //Indicate that we want socket to be closed whenever streams are closed
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        // schedule the stream on the run loop to enable callbacks
        if (CFReadStreamSetClient(readStream, registeredEvents, imageSocketReadStreamCallback, &ctx)) {
            CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
        } else {
            //NSLog(@"Failed to assign callback method : Read Stream");
            return;
        }
        if (CFWriteStreamSetClient(writeStream, registeredEvents, imageSocketWriteStreamCallback, &ctx)) {
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

void imageSocketReadStreamCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr) {
    
    ImageSocket *currentSocket = (__bridge ImageSocket*)myPtr;
    
    switch(event) {
        case kCFStreamEventOpenCompleted:
            [currentSocket.delegate advancedImageSocketConnected];
            break;
            
            
        case kCFStreamEventHasBytesAvailable:
        {
            //read bytes until there are no more
            /*while (CFReadStreamHasBytesAvailable(stream)) {
                UInt8 buffer[kBufferSize];
                CFIndex numBytesRead = CFReadStreamRead(stream, buffer, kBufferSize);
                currentSocket.totalBytesReadBySocket += numBytesRead;
                //NSLog(@"Bytes Read:%ld",numBytesRead);
                if (numBytesRead>0)
                    [currentSocket socketDidReadData:[NSData dataWithBytes:buffer length:numBytesRead]];
            }*/
            NSData *theData = NULL;
            CFIndex theBufferLength = 0;
            const UInt8 *theBufferPtr = CFReadStreamGetBuffer(stream, theBufferLength, &theBufferLength);
            if (theBufferPtr != NULL)
            {
                theData = [NSData dataWithBytesNoCopy:(void *)theBufferPtr length:theBufferLength freeWhenDone:NO];
            }
            else
            {
                NSMutableData *theMutableData = [NSMutableData dataWithLength:kBufferSize];
                theBufferLength = CFReadStreamRead(stream, theMutableData.mutableBytes, theMutableData.length);
                if (theBufferLength > 0)
                {
                    theMutableData.length = theBufferLength;
                    theData = theMutableData;
                }
            }
             if (theData)
             {
                 currentSocket.totalBytesReadBySocket += [theData length];
                 [currentSocket socketDidReadData:theData];
             }
            
            break;
        }
        case kCFStreamEventErrorOccurred: {
            //NSLog(@"Read Stream:kCFStreamEventEndEncountered");
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
            stream = NULL;
            [currentSocket.delegate advancedImageSocketDisConnected];
            break;
            
        }
            
        case kCFStreamEventEndEncountered:
            //[controller didFinishReceivingData];
            
            // clean up the stream
            CFReadStreamClose(stream);
            
            // stop processing callback methods
            CFReadStreamUnscheduleFromRunLoop(stream,
                                              CFRunLoopGetCurrent(),
                                              kCFRunLoopCommonModes);
            
            // end the thread's run loop
            CFRunLoopStop(CFRunLoopGetCurrent());
            stream = NULL;
            [currentSocket.delegate advancedImageSocketDisConnected];
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
                //NSLog(@"Did Read : USB_TABLET_FILE_COMPLETION_EVENT:%lu",(unsigned long)dataLength);
                file_complete_response_t resp;
                resp.mediaType = MEDIA_IMAGE;
                PatientData *patientData = [PatientData sharedManager];
                UserGeneralSetting *settings = [UserGeneralSetting sharedUserSettings];
                //float deviceValue = [settings storageLevelSet];
                BOOL isLowStorage = settings.lowStorageAlert;
                //isLowStorage = (([self getPercentageOfStorageAvailableOnDevice]*100.0f) < deviceValue);
                //if ([patientData.patientMrnId length]!=0 && [patientData.lockStatus isEqualToString:@"unlocked"] && ([[SNGCCUSharedManager sharedCCManager]encodingFolderStateOnCCU] == VALID)) resp.response = FILE_COMPLETION_ACK;
                if ([patientData.patientMrnId length]!=0 && [patientData.lockStatus isEqualToString:@"unlocked"] && !isLowStorage && [[SNGCCUSharedManager sharedCCManager] encodingFolderStateOnCCU] != SET_ENCODING_FOLDER_RESPONSE_INVALID_STATE && [[SNGCCUSharedManager sharedCCManager] encodingFolderStateOnCCU] != SET_ENCODING_FOLDER_RESPONSE_INVALID_FOLDER_NAME) resp.response = FILE_COMPLETION_ACK;
                else
                {
                    resp.response = FILE_COMPLETION_NACK;
                    if (isLowStorage)
                    {
                        //dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate NACKResponseToFileCompletionEventImageChannel];
                            //NSString *messageString = [NSString stringWithFormat:NSLocalizedString(@"Device storage is lower than %d%% of total device storage. Cannot receive files.",nil),(int)deviceValue];
                            //Input_AlertDialog(NSLocalizedString(@"Low Storage!",nil), messageString, 1, nil, NSLocalizedString(@"OK",nil), nil, NO);
                        //});
                    }
                    NSString *description = @"NACK Response Sent To Image File Completion Event";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        [Logs writeAccessDataToFileWithDescription:description andTitle:@"NACK Event"];
                    });
                }
                
                [self.delegate advancedSendImageFileCompletionResponseAck:resp];
            }
                break;
            case USB_TABLET_CAPTURE_IMAGE_RESPONSE:
            {
                //NSLog(@"Did Read : USB_TABLET_CAPTURE_IMAGE_RESPONSE:%lu",(unsigned long)dataLength);
                [data getBytes:&mediaMetadata length:sizeof(mediaMetadata)];
                //mediaMetadata.fileSize = ntohl(mediaMetadata.fileSize);
                file_received_t fileRx;
                fileRx.mediaType = mediaMetadata.mediaType;
                fileRx.response = FILE_RECEIVED_NACK;
                expectedFileSize = ntohl(mediaMetadata.fileSize); //NTOHL
                NSLog(@"Expected File Size:%lu",(unsigned long)expectedFileSize);
                downloadedFileSize = 0;
                NSString *filename = [NSString stringWithFormat:@"%s",mediaMetadata.fileName];
                NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
                if(folderPathToSaveFile != nil && folderPathToSaveFile.length > 0)
                    downloadingFilePath = [folderPathToSaveFile stringByAppendingPathComponent:filename];
                else
                    downloadingFilePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:filename];
                
                imageFileDownloadBuffer = [[NSMutableData alloc] init];
                
                //NSFileManager *filemgr;
                //filemgr =[NSFileManager defaultManager];
                //[filemgr createFileAtPath:downloadingFilePath contents:nil attributes:nil];
                //downloadFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:downloadingFilePath];
                downloadTimeInterval = [NSDate timeIntervalSinceReferenceDate];
                if ([data length]>50)
                {
                    //filter this data & reiterate the method
                    NSData *additionalData = [data subdataWithRange:NSMakeRange(50, ([data length]-50))];
                    [self updateDownloadingFile:additionalData];
                }
                //NSLog(@"Did Read : USB_TABLET_CAPTURE_IMAGE_RESPONSE - File name:%s Size:%d %d",mediaMetadata.fileName,ntohl(mediaMetadata.fileSize),[data length]);
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
    //NSLog(@"Did Read : A Chunk of Data of Length:%ld",(unsigned long)dataLength);
    downloadedFileSize += dataLength;
    
    NSString *filename = [NSString stringWithFormat:@"%s",mediaMetadata.fileName];
    NSInteger totalSize = expectedFileSize;
    [imageFileDownloadBuffer appendData:data];
    //[downloadFileHandle seekToEndOfFile];
    //[downloadFileHandle writeData:data];
    //[downloadFileHandle synchronizeFile];
    
    [self.delegate advancedImageDownloadingProgress:totalSize completed:downloadedFileSize filename:filename mediaType:MEDIA_IMAGE];
    
    if(downloadedFileSize == expectedFileSize)
    {
        //NSLog(@"Did Read : Last Packet of File of Length:%d",dataLength);
        expectedFileSize = 0;
        file_complete_response_t resp;
        resp.mediaType = MEDIA_IMAGE;
        resp.response = FILE_RECEIVED_ACK;
        [self.delegate advancedSendImageFileReceivedResponse:resp];
        BOOL isFileWritten = [imageFileDownloadBuffer writeToFile:downloadingFilePath atomically:NO];
        if (isFileWritten)
        {
            imageFileDownloadBuffer = nil;
            [self.delegate advancedImageDownloaded:downloadingFilePath fileSize:totalSize downloadTime:[NSDate timeIntervalSinceReferenceDate] - downloadTimeInterval mediaType:MEDIA_IMAGE];
        }
        downloadedFileSize = 0;
    }
    if(downloadedFileSize > expectedFileSize)
    {
        NSLog(@"IF this executes there is a problem as downloaded file size cannot be greater than expected size");
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
void imageSocketWriteStreamCallback(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    ImageSocket* currentSocket = (__bridge ImageSocket *)info;
    switch(eventType)
    {
        case kCFStreamEventOpenCompleted:
            break;
     
     
        case kCFStreamEventCanAcceptBytes:
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
             [currentSocket.delegate advancedImageSocketDisConnected];
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
            [currentSocket.delegate advancedImageSocketDisConnected];
            break;
     
        default:
            break;
     }
}

-(void)queryUSBToSendFileOnImageChannel:(NSArray *)dataArray
{
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    });*/
    
    NSLog(@"Query USB Image Channel");
    NSData *queryUSBData = [requestManager GetQueryUSBReady:MEDIA_IMAGE folderName:dataArray[0] withFileSize:(u32)[dataArray[1] unsignedLongLongValue]];
    // Can stream take any data in?
    [writeStreamDataBuffer appendData:queryUSBData];
    [self writeDataBufferToWriteStream];
    
    // Write as much as we can
    //CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [queryUSBData bytes], [queryUSBData length]);
    usbQueryResponseExpected =  YES;
    //NSLog(@"Written Bytes:%ld Expected:%d",writtenBytes,[queryUSBData length]);
    
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(usbQueryResponsereceived:) withObject:[NSArray arrayWithArray:dataArray] afterDelay:1.0];
    });*/
}
- (void)writeDataBufferToWriteStream {
    @synchronized(self)
    {
        if ([writeStreamDataBuffer length] == 0 && isUploadingFile)
        {
            if (uploadFileOffset >= uploadFileSize)
            {
                [uploadFileHandle closeFile];
                uploadFileHandle = nil;
                isUploadingFile = NO;
                [self.delegate advancedImageFileUploaded:uploadFileSourcePath fileSize:uploadFileSize uploadTime:uploadTimeInterval];
            }
            else
            {
                [self uploadFile];   
            }
            
            return;
        }
        //Do we have anything to write?
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
- (void)usbQueryResponsereceived:(NSArray*)dataArray
{
    //NSLog(@"Check if query response is recived");
    if (usbQueryResponseExpected)
        [self queryUSBToSendFileOnImageChannel:dataArray];
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
    
    NSData *data = [requestManager GetSendFile:(u32)uploadFileSize fileName:uploadFileName folderName:destinationFolderName mediaType:MEDIA_IMAGE];  // fix bug 711. see GetSendFile
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
        [self.delegate advancedImageFileUploadingProgress:uploadFileSize completed:current filename:uploadFileName mediaType:MEDIA_IMAGE];
        //[self uploadFile];
        return;
    }
    else{
        
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
    if (isUploadingFile == YES)
    {
        return YES;
    }
    else return NO;
}
-(void)bytesReadOnImageChannel
{
    NSLog(@"Total Bytes read On image socket:%lld",self.totalBytesReadBySocket);
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
    
    
    [[NSThread currentThread] cancel];
}
-(void)dealloc
{
    //NSLog(@"Image Socket deallocated");
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
    
    //self = nil;
    //NSLog(@"Image Socket Dealloc");
}
// Write whatever data we have, as much of it as stream can handle
@end
