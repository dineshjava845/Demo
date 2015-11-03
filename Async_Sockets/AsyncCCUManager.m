//
//  AsyncCCUManager.m
//  Gnome
//

//

#import "AsyncCCUManager.h"

@interface AsyncCCUManager()
{
    AsyncCommandChannel *acc;
    ImageSocket *aic;
    VideoSocket *avc;
}
@property (nonatomic,strong) NSString *hostIP;

@end


@implementation AsyncCCUManager
@synthesize delegate;

-(id)init:(NSString *)hostIP
{
    self.hostIP = hostIP;
    return self;
}
-(void)connectToCCU
{
    acc = [[AsyncCommandChannel alloc]initWithHostAddress:self.hostIP andPortNumber:27030];
    acc.delegate = self;
    [acc openSocket];
}
-(void)forceDisconnectFromCCU
{
    [acc disconnectSocket];
    aic = nil;
    avc = nil;
    //[aic disconnectSocket];
    //[avc disconnectSocket];
    
}
- (void)disconnect:(u8)status{
    [acc disconnectRequestResponse:status];
}

- (void)setEncodingFolder:(NSString *)encodingFolderName
{
    [acc setEncodingFolderOnUSB:encodingFolderName];
}
- (void)createFolder:(NSString *)folderName;
{
    [acc createFolderForArchivingFilesOnUSB:folderName];
}
- (void)sendImageFile:(NSString*)filepath fileName:(NSString*)fileName folderName:(NSString*) folderName
{
    //To-DO image channel
    //dispatch_async(dispatch_get_main_queue(), ^{
        //[aic sendFile:filepath fileName:fileName folderName:folderName];
    //});
    [aic performSelector:@selector(sendFileToUSB:) onThread:aic withObject:[NSArray arrayWithObjects:filepath,fileName,folderName,nil] waitUntilDone:NO];
    
}
- (void)sendVideoFile:(NSString*)filepath fileName:(NSString*)fileName folderName:(NSString*) folderName
{
    //To-DO video channel
    //[avc sendFile:filepath fileName:fileName folderName:folderName];
    [avc performSelector:@selector(sendFileToUSB:) onThread:avc withObject:[NSArray arrayWithObjects:filepath,fileName,folderName,nil] waitUntilDone:NO];
}

- (void)captureImage:(NSString*)folderpath  mediaTarget:(u8)target mediaSource:(u8)source
{
    [acc captureMedia:TABLET_USB_CAPTURE_IMAGE mediaTarget:target mediaSource:source];

    [aic setFolderPath:folderpath];
}
- (void)startRecording:(NSString*)folderpath  mediaTarget:(u8)target mediaSource:(u8)source
{
    [acc captureMedia:TABLET_USB_START_VIDEO_RECORD mediaTarget:target mediaSource:source];

    [avc setFolderPath:folderpath];
}
- (void)stopRecordingOnMediaSource:(u8)source
{
    [acc stopVideoRecordingOnMediaSource:source];
}

- (void)setKeyboardInput:(char)key
{
    [acc setKeyBoardMap:key];
}

- (void)setColor:(int)hue sat:(int)sat phase:(int)phase
{
    [acc setColorHue:hue colorSaturation:sat colorPhase:phase];
}
- (void)setELC:(int)elc
{
    [acc setELC:elc];
}
- (void)setSharpness:(int)sharpness
{
    [acc setSharpness:sharpness];
}
- (void)setZoom:(int)zoom
{
    [acc setZoom:zoom];
}

- (void)setButtonMap:(int)b1 button2:(int)b2 button3:(int)b3 shortButton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3
{
    [acc setButton1Short:sb1 button1Long:b1 button2Short:sb2 button2Long:b2 button3Short:sb3 button3Long:b3];
}

- (void)setWhiteBalance:(int)white
{
    [acc setWhiteBalance:white];
}
- (void)setLightSource:(int)lightStatus
{
    [acc setLightSource:lightStatus];
}


- (void)getProfile:(int)profile;
{
    [acc fetchRemoteProcedureAtIndex:profile];
}

- (void)setProfile:(int)hue sat:(int)sat phase:(int)phase white:(int)white sharpness:(int)sharpness zoom:(int)zoom elc:(int)elc button1:(int)b1 button2:(int)b2 button3:(int)b3 shortbutton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3 profileName:(NSString *)profileName mediaTarget:(u8)mediaTarget procedureindex:(int)index
{
    [acc setRemoteProcedureWithProcedureName:profileName ColorHue:hue Phase:phase Saturation:sat whiteBalance:white Zoom:zoom Sharpness:sharpness ELC:elc button1Short:sb1 button1Long:b1 button2Short:sb2 button2Long:b2 button3Short:sb3 button3Long:b3 mediaTarget:mediaTarget  atIndex:index];
}

- (void)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target
{
    [acc setActiveProcedureWithProcedureName:pName ColorHue:hue Phase:phase Saturation:saturation Zoom:zoom Sharpness:sharpness ELC:elc button1Short:b1SP button1Long:b1LP button2Short:b2SP button2Long:b2LP button3Short:b3SP button3Long:b3LP mediaTarget:target];
}

- (void)setMediaSource:(u8)source
{
    [acc setMediaSource:source];
}

-(BOOL)isFileRxInProgress
{
    BOOL rxFlag = NO;
    if (aic != nil && avc!=nil)
    {
        BOOL imgRX = [aic fileReceptionInProgress];
        BOOL vidRX = [avc fileReceptionInProgress];
        if (imgRX == YES || vidRX == YES) rxFlag = YES;
    }
    return rxFlag;
}
-(BOOL)isFileTxInProgress
{
    BOOL txFlag = NO;
    if (aic != nil && avc!=nil)
    {
        BOOL imgTX = [aic fileTransmissionInProgress];
        BOOL vidTX = [avc fileTransmissionInProgress];
        if (imgTX == YES || vidTX == YES) txFlag = YES;
    }
    return txFlag;
}



#pragma mark - Async-Command-Channel-Delegates

-(void)commandSocketConnected
{
    //Command Socket is now opened...now open image channel 27032
    //dispatch_async(dispatch_get_main_queue(), ^{
    aic = [[ImageSocket alloc]initWithURLString:self.hostIP port:27032];
    [aic start];
    //NSLog(@"Image Thread Stack Size:%d",aic.stackSize);
    aic.delegate = self;
    //});
    
}
-(void)commandSocketDisconnected
{
    acc = nil;
    if (aic == nil && avc == nil && acc == nil) {
        [self.delegate disconnectedFromServer];
        return;
    }
}
- (void)setEncodingFolderResponse:(u8)response
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate createEncoderFolderResponse:response]; 
    });
    
}

- (void)createFolderResponse:(u8)response
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate createFolderResponse:response]; 
    });
    
}

- (void)receivedActiveProcedureOnRTOS:(procedure_d_t)proc
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate activeRTOSProcedure:proc]; 
    });
    
}

- (void)receivedRequestedRTOSProcedure:(procedure_d_t)proc
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate receivedRequestedRTOSProcedure:proc]; 
    });
    
}
- (void)versionUSB:(char)usbVersion CCU:(char)ccuVersion
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate versionInfo:usbVersion CCU:ccuVersion]; 
    });
}
- (void)heartBeatReceived:(heartbeat_response_t)hb
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate heartBeat:hb]; 
    });
}

- (void)disconnectRequestReceviedFromServer
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate disconnectRequestServer]; 
    });
}

#pragma mark - Async-Image-Channel-Delegates
-(void)imageSocketConnected
{
    //image Socket is now opened...now open video channel27033
    avc = [[VideoSocket alloc]initWithURLString:self.hostIP port:27033];
    [avc start];
    
    avc.delegate = self;
}
-(void)advancedImageSocketConnected
{
    //image Socket is now opened...now open video channel
    avc = [[VideoSocket alloc]initWithURLString:self.hostIP port:27033];
    [avc start];
    //NSLog(@"Video Thread Stack Size:%d",avc.stackSize);
    avc.delegate = self;
}

-(void)imageSocketDisConnected
{
    aic = nil;
    if (aic == nil && avc == nil && acc == nil) {
        [self.delegate disconnectedFromServer];
        return;
    }
}
-(void)advancedImageSocketDisConnected
{
    NSLog(@"Image Socket Disconnected");
    [aic resetData];
    aic = nil;
    if (aic == nil && avc == nil && acc == nil) {
        [self.delegate disconnectedFromServer];
        return;
    }
}

- (void)advancedImageDownloadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate fileDownloadingProgress:totalsize completed:current filename:filename mediaType:mediaType]; 
    });
}

// get the downloaded information
- (void)advancedImageDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate fileDownloaded:filepath fileSize:filesize downloadTime:downloadTime mediaType:mediaType]; 
    });
}

- (void)advancedSendImageFileReceivedResponse:(file_complete_response_t)fileReceived
{
    [acc fileReceivedResponse:fileReceived];
}

- (void)advancedSendImageFileCompletionResponseAck:(file_complete_response_t)fileCompletion
{
    [acc fileCompletionResponse:fileCompletion];
}

- (void)advancedImageFileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploadingProgress:totalsize completed:current filename:filename mediaType:mediaType];
    });
}

// get the uploaded information
-(void)advancedImageFileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploaded:filepath fileSize:filesize uploadTime:uploadTime];
    });
}

-(void)NACKResponseToFileCompletionEventImageChannel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate NACKResponseToFileCompletionEvent];
    });
}

#pragma mark - Async-Video-Channel-Delegates
-(void)videoSocketConnected
{
    //video Socket is now opened...All three channels are opened now
    //NSLog(@"CCU...CONNECTED");
    //start sending periodic data on command channel
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connected];
    });
}
-(void)advancedVideoSocketConnected
{
    //video Socket is now opened...All three channels are opened now
    //NSLog(@"CCU...CONNECTED");
    //start sending periodic data on command channel
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connected];
    });
}
-(void)videoSocketDisConnected
{
    [avc resetData];
    avc = nil;
    if (avc == nil && aic == nil && acc == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate disconnectedFromServer];
        });
        return;
    }
    if (acc != nil) {
        [acc disconnectSocket];
    }
    if (aic != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            aic = nil;
            //[aic disconnectSocket];
        });
        
    }
}
-(void)advancedVideoSocketDisConnected
{
    NSLog(@"Video Socket disconnected");
    avc = nil;
    if (avc == nil && aic == nil && acc == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate disconnectedFromServer];
        });
        return;
    }
    if (acc != nil) {
        [acc disconnectSocket];
    }
    if (aic != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //[aic disconnectSocket];
            aic = nil;
        });
        
    }
}
- (void)advancedVideoDownloadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate fileDownloadingProgress:totalsize completed:current filename:filename mediaType:mediaType]; 
    });
}

// get the downloaded information
- (void)videoDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [self.delegate fileDownloaded:filepath fileSize:filesize downloadTime:downloadTime mediaType:mediaType]; 
    });
}

- (void)advancedVideoDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileDownloaded:filepath fileSize:filesize downloadTime:downloadTime mediaType:mediaType];
    });
}

- (void)sendVideoFileReceivedResponse:(file_complete_response_t)fileReceived
{
    [acc fileReceivedResponse:fileReceived];
}

- (void)advancedSendVideoFileReceivedResponse:(file_complete_response_t)fileReceived
{
    [acc fileReceivedResponse:fileReceived];
}

- (void)sendVideoFileCompletionResponseAck:(file_complete_response_t)fileCompletion
{
   [acc fileCompletionResponse:fileCompletion];
}
- (void)advancedSendVideoFileCompletionResponseAck:(file_complete_response_t)fileCompletion
{
    [acc fileCompletionResponse:fileCompletion];
}

- (void)videoFileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploadingProgress:totalsize completed:current filename:filename mediaType:mediaType];
    });
}
- (void)advancedVideoFileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploadingProgress:totalsize completed:current filename:filename mediaType:mediaType];
    });
}
// get the uploaded information
-(void)videoFileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploaded:filepath fileSize:filesize uploadTime:uploadTime];
    });
}
// get the uploaded information
-(void)advancedVideoFileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate fileUploaded:filepath fileSize:filesize uploadTime:uploadTime];
    });
}

-(void)NACKResponseToFileCompletionEventVideoChannel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate NACKResponseToFileCompletionEvent];
    });
}

- (void)fileCompletionEventImage
{
    
}
- (void)queryUSBReuestRespone:(u8)usbQueryResponse mediaType:(u8)mediaType;
{
    [self.delegate queryUSBRecivedResponse:usbQueryResponse mediaType:mediaType];
}

- (void)queryUSBVideoChannel:(NSString *)folderName fileSize:(unsigned long long)inFileSize
{
    [avc performSelector:@selector(queryUSBToSendFileOnVideoChannel:) onThread:avc withObject:[NSArray arrayWithObjects:folderName,[NSNumber numberWithUnsignedLongLong:inFileSize],nil] waitUntilDone:NO];
    //[avc queryUSBToSendFileOnVideoChannel:folderName];
}
- (void)queryUSBImageChannel:(NSString *)folderName fileSize:(unsigned long long)inFileSize
{
    [aic performSelector:@selector(queryUSBToSendFileOnImageChannel:) onThread:aic withObject:[NSArray arrayWithObjects:folderName,[NSNumber numberWithUnsignedLongLong:inFileSize], nil] waitUntilDone:NO];
    //[aic queryUSBToSendFileOnImageChannel:folderName];
}

-(void)printBytesReadOnVidChannel
{
    [avc performSelector:@selector(bytesReadOnVidChannel) onThread:aic withObject:nil waitUntilDone:NO];
}
-(void)printBytesReadOnImgChannel
{
    [aic performSelector:@selector(bytesReadOnImageChannel) onThread:aic withObject:nil waitUntilDone:NO];
}

@end
