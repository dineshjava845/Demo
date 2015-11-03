//
//  AsyncCommandChannel.m
//  Gnome
//
//

#import "AsyncCommandChannel.h"
#import "RequestManager.h"


@interface AsyncCommandChannel()
{
    u8 mediaSourceSet;
}
@property (nonatomic,strong) NSString *hostAddress;
@property (nonatomic,assign) int portNumber;
@property (nonatomic,strong) RequestManager *rm;
@end

@implementation AsyncCommandChannel

- (id)initWithHostAddress:(NSString*)hostAddress andPortNumber:(int)portNo
{
    self = [super init];
    self.hostAddress = hostAddress;
    self.portNumber = portNo;
    self.rm = [[RequestManager alloc] init];
    mediaSourceSet = VID1;
    socketDelegateQueue = dispatch_queue_create("Command_Channel_Delegate_Queue", DISPATCH_QUEUE_SERIAL);
    tablet_usb_hb_Queue = dispatch_queue_create("HeartBeat_Message_Queue", DISPATCH_QUEUE_SERIAL);
    commandSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketDelegateQueue];
    return self;
}
- (void)openSocket
{
    NSError *err = nil;
    if (![commandSocket connectToHost:self.hostAddress onPort:self.portNumber error:&err]) // Asynchronous!
    {
        //If there was an error, it's likely something like "already connected" or "no delegate set"
        //NSLog(@"Error While Connecting To Socket:%@", err);
    }
}
-(void)disconnectSocket
{
    [commandSocket setDelegate:nil delegateQueue:NULL];
    [commandSocket disconnect];
    if (commandSocket.isDisconnected)
    {
        if ([self.delegate respondsToSelector:@selector(commandSocketDisconnected)])
            [self.delegate commandSocketDisconnected];
    }
}
- (void)disconnectRequestResponse:(u8)status
{
    //NSLog(@"Write: TABLET_USB_DISCONNECT_RESPONSE");
    NSData *disconnect_req_res_data = [self.rm GetDisconnectRequest:status];
    [commandSocket writeData:disconnect_req_res_data withTimeout:-1 tag:TABLET_USB_DISCONNECT_RESPONSE];
}

//These delegates are called on socketDelegateQueue
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //NSLog(@"Socket Connected:%d",port);
    //After successful TCP Connect on the Primary Command Channel, Tablet must send the Connect Message over this socket (see section #6.5.3) within one (1) second. TABLET_USB_CONNECT_REQUEST
    //NSLog(@"Write: TABLET_USB_CONNECT_REQUEST");
    NSData *commandData = [self.rm GetRequest:TABLET_USB_CONNECT_REQUEST];
    [commandSocket writeData:commandData withTimeout:-1.0 tag:TABLET_USB_CONNECT_REQUEST];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    //NSLog(@"Socket Disconnected With Error:%@",[err description]);
    [self disconnectSocket];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self socketDidReadData:data];
    
    [commandSocket readDataWithTimeout:-1 tag:1];
}

-(void)socketDidReadData:(NSData *)data
{
    NSUInteger len = [data length];
    NSUInteger expectedLength = 0;
    Byte *byteData= (Byte*)malloc(len);
    [data  getBytes:byteData length:len];
    if (byteData[0] == PROTOCOL_USB_TO_TABLET)
    {
        switch (byteData[1])
        {
            case USB_TABLET_CONNECT_RESPONSE:
            {
                expectedLength = 10;
                //NSLog(@"Did Read : USB_TABLET_CONNECT_RESPONSE :%lu",(unsigned long)[data length]);
                if (byteData[8] == TABLET_CONNECT_OK)
                {
                    //NSLog(@"TABLET_CONNECT_OK");
                    //start sending periodic data on command channel
                    [self startSendingPeriodicHB];
                    if ([self.delegate respondsToSelector:@selector(commandSocketConnected)])
                        [self.delegate commandSocketConnected];
                }
                else if (byteData[8] == TABLET_CONNECT_NAK)
                    NSLog(@"TABLET_CONNECT_NAK");
            }
                break;
            case USB_TABLET_GET_VERSION_RESPONSE: //11 Bytes
            {
                expectedLength = 11;
                //NSLog(@"Did Read : USB_TABLET_GET_VERSION_RESPONSE:%lu",(unsigned long)[data length]);
                [self parseVersion:data];
            }
                break;
            case USB_TABLET_HEARTBEAT://14 Bytes
            {
                expectedLength = 14;
                //NSLog(@"Did Read : USB_TABLET_HEARTBEAT :%lu",(unsigned long)[data length]);
                [self parseHeatbeat:data];
                break;
            }
            case USB_TABLET_CREATE_FOLDER_RESPONSE:
            {
                expectedLength = 10;
                //NSLog(@"Did Read : USB_TABLET_CREATE_FOLDER_RESPONSE :%lu",(unsigned long)[data length]);
                if(byteData[8] == CREATE_FOLDER_RESPONSE_ACK)
                {
                    //NSLog(@"CREATE_FOLDER_RESPONSE_ACK");
                }
                if(byteData[8] == CREATE_FOLDER_RESPONSE_DUPLICATE_ACK)
                {
                    //NSLog(@"CREATE_FOLDER_RESPONSE_DUPLICATE_ACK");
                }
                if(byteData[8] == CREATE_FOLDER_RESPONSE_ERROR_NACK)
                {
                    //NSLog(@"CREATE_FOLDER_RESPONSE_ERROR_NACK");
                }
                if(byteData[8] == CREATE_FOLDER_RESPONSE_NO_USB_FLASH_NACK)
                {
                    //NSLog(@"CREATE_FOLDER_RESPONSE_NO_USB_FLASH_NACK");
                }
                if ([self.delegate respondsToSelector:@selector(createFolderResponse:)])
                    [self.delegate createFolderResponse:byteData[8]];
            }
                break;
            case USB_TABLET_DISCONNECT_REQUEST:
            {
                expectedLength = 9;
                //NSLog(@"Did Read : USB_TABLET_DISCONNECT_REQUEST :%lu",(unsigned long)[data length]);
                if ([self.delegate respondsToSelector:@selector(disconnectRequestReceviedFromServer)])
                    [self.delegate disconnectRequestReceviedFromServer];
            }
                break;
            case USB_TABLET_QUERY_READY_RECEIVE_RESPONSE:
            {
                expectedLength = 11;
                //NSLog(@"Did Read : USB_TABLET_QUERY_READY_RECEIVE_RESPONSE :%lu",(unsigned long)[data length]);
                if(byteData[9] == QUERY_USB_READY_ACK)
                {
                    //NSLog(@"QUERY_USB_READY_ACK");
                    if ([self.delegate respondsToSelector:@selector(queryUSBReuestRespone:mediaType:)])
                        [self.delegate queryUSBReuestRespone:byteData[9] mediaType:byteData[8]];
                }
                else if(byteData[9] == QUERY_USB_READY_NACK)
                {
                    //NSLog(@"QUERY_USB_READY_NACK");
                    if ([self.delegate respondsToSelector:@selector(queryUSBReuestRespone:mediaType:)])
                        [self.delegate queryUSBReuestRespone:byteData[9] mediaType:byteData[8]];
                }
            }
                break;
            case USB_TABLET_SEND_FILE_TO_FLASH_RESPONSE:
            {
                expectedLength = 11;
                //NSLog(@"Did Read :USB_TABLET_SEND_FILE_TO_FLASH_RESPONSE:%lu",(unsigned long)[data length]);
            }
                break;
                
            case USB_TABLET_SET_ENCODING_FOLDER_RESPONSE://10 Bytes
            {
                expectedLength = 10;
                //NSLog(@"Did Read : USB_TABLET_SET_ENCODING_FOLDER_RESPONSE:%lu",(unsigned long)[data length]);
                if(byteData[8] == SEND_ENCODING_FOLDER_RESPONSE_ACK)
                {
                    //NSLog(@"SEND_ENCODING_FOLDER_RESPONSE_ACK");
                }
                if(byteData[8] == SEND_ENCODING_FOLDER_RESPONSE_ERROR_NACK)
                {
                    //NSLog(@"SEND_ENCODING_FOLDER_RESPONSE_ERROR_NACK");
                }
                if(byteData[8] == SEND_ENCODING_FOLDER_RESPONSE_NO_USB_FLASH_NACK)
                {
                    //NSLog(@"SEND_ENCODING_FOLDER_RESPONSE_NO_USB_FLASH_NACK");
                }
                if(byteData[8] == SEND_ENCODING_FOLDER_RESPONSE_INVALID_STATE)
                {
                    //NSLog(@"SEND_ENCODING_FOLDER_RESPONSE_INVALID_STATE");
                }
                if ([self.delegate respondsToSelector:@selector(setEncodingFolderResponse:)])
                    [self.delegate setEncodingFolderResponse:byteData[8]];
            }
                break;
                
            default:
                break;
        }
    }
    else if (byteData[0] == PROTOCOL_RTOS_TO_TABLET)
    {
        switch (byteData[1])
        {
            case RTOS_TABLET_GET_PROCEDURE_RESPONSE: //51 bytes
            {
                expectedLength = 51;
                //NSLog(@"Did Read : RTOS_TABLET_GET_PROCEDURE_RESPONSE: %lu",(unsigned long)[data length]);
                procedure_d_t res;
                NSData *proc_data = [data subdataWithRange:NSMakeRange(9, sizeof(res))];
                //make a new procedure_d_t
                [proc_data getBytes:&res length:sizeof(res)];
                if ([self.delegate respondsToSelector:@selector(receivedActiveProcedureOnRTOS:)])
                    [self.delegate receivedRequestedRTOSProcedure:res];
            }
                break;
            case RTOS_TABLET_REPORT_PARAMETERS://51 bytes
            {
                expectedLength = 50;
                //NSLog(@"Did Read : RTOS_TABLET_REPORT_PARAMETERS: %lu",(unsigned long)[data length]);
                procedure_d_t res;
                NSData *proc_data = [data subdataWithRange:NSMakeRange(8, sizeof(res))];
                //make a new PacketJoin
                [proc_data getBytes:&res length:sizeof(res)];
                if ([self.delegate respondsToSelector:@selector(receivedActiveProcedureOnRTOS:)])
                    [self.delegate receivedActiveProcedureOnRTOS:res];
            }
                break;
            default:
                break;
                
        }
    }
    //Filter the data if more than expected & reiterate
    free(byteData);
    if ([data length]>expectedLength)
    {
        NSData *additionalData = [data subdataWithRange:NSMakeRange(expectedLength, ([data length]-expectedLength))];
        [self socketDidReadData:additionalData];
    }
}

- (void)parseVersion:(NSData *)data
{
    NSUInteger len = [data length];
    Byte *byteData= (Byte*)malloc(len);
    [data  getBytes:byteData length:len];
    if ([self.delegate respondsToSelector:@selector(versionUSB:CCU:)])
        [self.delegate versionUSB:byteData[8] CCU:byteData[9]];
    free(byteData);
}
- (void)parseHeatbeat:(NSData *)hbData
{
    NSUInteger len = [hbData length];
    Byte *response= (Byte*)malloc(len);
    [hbData  getBytes:response length:len];
    unsigned char bits[8];
    unsigned char mask = 1;
    heartbeat_response_t hb;
    for (int i = 0; i < 8; i++) {
        bits[i] = response[8] & (mask << i);
        bits[i] >>=i;
    }
    
    hb.userpower = bits[7];
    hb.standby = bits[6];
    hb.rtos_tablet_connection = bits[5];
    hb.lightguide = bits[4];
    hb.ccu = bits[3];
    hb.camera = bits[2];
    if(bits[1] == 0 && bits[0] == 0){hb.chip = 0;}
    if(bits[1] == 1 && bits[0] == 0){hb.chip = 1;}
    if(bits[1] == 0 && bits[0] == 1){hb.chip = 2;}
    if(bits[1] == 1 && bits[0] == 1){hb.chip = 3;}
    
    for (int i = 0; i < 8; i++) {
        bits[i] = response[9] & (mask << i);
        bits[i] >>=i;
    }
    if(bits[1] == 0 && bits[0] == 0){hb.system = 0;}
    if(bits[1] == 0 && bits[0] == 1){hb.system = 1;}
    if(bits[1] == 1 && bits[0] == 0){hb.system = 2;}
    if(bits[1] == 1 && bits[0] == 1){hb.system = 3;}
    
    hb.usbpcnt = response[11];
    hb.vid1 = VID1DECODE(response[10]);
    hb.vid2 = VID2DECODE(response[10]);
    
    
    /*switch (response[12]) {
        case 0:
            hb.systemstate = USBSYS_NO_ERROR;
            break;
        case 1:
            hb.systemstate = USBSYS_ERROR_INTERNAL;
            break;
        case 2:
            hb.systemstate = USBSYS_SHUTTING_DOWN;
            break;
            
            
        default:
            break;
    }*/
    
    hb.usbCapState = USB_CAP_FUTURE1;
    
    if(mediaSourceSet == VID1){
        if(bits[0] == 1 && bits[1] == 0 && bits[2] == 0 ){hb.usbCapState = USB_CAP_CAPTURE_DISABLED;}
        if(bits[0] == 0 && bits[1] == 1 && bits[2] == 0 ){hb.usbCapState = USB_CAP_CONFIGURING_CAPTURE;}
        if(bits[0] == 1 && bits[1] == 1 && bits[2] == 0 ){hb.usbCapState = USB_CAP_IDLE_READY;}
        if(bits[0] == 0 && bits[1] == 0 && bits[2] == 1 ){hb.usbCapState = USB_CAP_RECORDING;}
        if(bits[0] == 1 && bits[1] == 0 && bits[2] == 1 ){hb.usbCapState = USB_CAP_CAPTURING_IMAGE;}
        if(bits[0] == 0 && bits[1] == 1 && bits[2] == 1 ){hb.usbCapState = USB_CAP_RECORDING_AND_IMAGE_CAPTURE;}
        if(bits[0] == 1 && bits[1] == 1 && bits[2] == 1 ){hb.usbCapState = USB_CAP_FUTURE1;}
        
        
    }else {
        for (int i = 0; i < 8; i++) {
            bits[i] = response[11] & (mask << i);
            bits[i] >>=i;
        }
        if(bits[4] == 1 && bits[5] == 0 && bits[6] == 0 ){hb.usbCapState = USB_CAP_CAPTURE_DISABLED;}
        if(bits[4] == 0 && bits[5] == 1 && bits[6] == 0 ){hb.usbCapState = USB_CAP_CONFIGURING_CAPTURE;}
        if(bits[4] == 1 && bits[5] == 1 && bits[6] == 0 ){hb.usbCapState = USB_CAP_IDLE_READY;}
        if(bits[4] == 0 && bits[5] == 0 && bits[6] == 1 ){hb.usbCapState = USB_CAP_RECORDING;}
        if(bits[4] == 1 && bits[5] == 0 && bits[6] == 1 ){hb.usbCapState = USB_CAP_CAPTURING_IMAGE;}
        if(bits[4] == 0 && bits[5] == 1 && bits[6] == 1 ){hb.usbCapState = USB_CAP_RECORDING_AND_IMAGE_CAPTURE;}
        if(bits[4] == 1 && bits[5] == 1 && bits[6] == 1 ){hb.usbCapState = USB_CAP_FUTURE1;}
    }
    if(hb.usbCapState != USB_CAP_FUTURE1){
        //NSLog(@"usbCapState = %d",hb.usbCapState);
    }
    
    
    //hb.systemstate = response[12];
    for (int i = 0; i < 3; i++) {
        bits[i] = response[12] & (mask << i);
        bits[i] >>=i;
    }
    //NSLog(@"bits[0]:%d bits[1]:%d bits[2]:%d",bits[0],bits[1],bits[2]);
  
    if(bits[2] == 0 && bits[1] == 0 && bits[0] == 0) hb.systemstate = USBSYS_NO_ERROR; //000
    else if (bits[2] == 0 && bits[1] == 0 && bits[0] == 1) hb.systemstate = USBSYS_ERROR_INTERNAL_SOFTWARE;//001
    else if (bits[2] == 0 && bits[1] == 1 && bits[0] == 0) hb.systemstate = USBSYS_ERROR_INTERNAL_HARDWARE;//010
    else if (bits[2] == 0 && bits[1] == 1 && bits[0] == 1) hb.systemstate = USBSYS_ERROR_EXTERNAL_RTOS;//011
    else if (bits[2] == 1 && bits[1] == 0 && bits[0] == 0) hb.systemstate = USBSYS_ERROR_EXTERNAL_TABLET;//100
    else if (bits[2] == 1 && bits[1] == 0 && bits[0] == 1) hb.systemstate = USBSYS_ERROR_EXTERNAL_FLASH;//101
    else if (bits[2] == 1 && bits[1] == 1 && bits[0] == 0) hb.systemstate = USBSYS_SHUTTING_DOWN;//110
    else if (bits[2] == 1 && bits[1] == 1 && bits[0] == 1) hb.systemstate = USBSYS_SYSTEM_FAILURE_SHUT_DOWN;//111
    
    hb.busy = response[12] & USB_BUSY_TRANSFER_STATUS_MASK ? 1 :0;
    hb.flash = response[12] & USB_FLASH_DRIVE_ATTACHED_MASK ? 1 :0;
    if ([self.delegate respondsToSelector:@selector(heartBeatReceived:)]) {
        [self.delegate heartBeatReceived:hb];
    }
    free(response);
    //hb.flash = 0;
    //[uidelegate heartBeat:hb];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{

}
/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //NSLog(@"Did Write Data With Tag : %ld",tag);
    if (tag == TABLET_USB_CONNECT_REQUEST)
    {
        [commandSocket readDataWithTimeout:-1 tag:1];
    }
    
    //if (tag == TABLET_USB_FILE_COMPLETION_RESPONSE) //NSLog(@"Did Write: TABLET_USB_FILE_COMPLETION_RESPONSE");
    //if (tag == TABLET_USB_MEDIA_FILE_RECEIVED) //NSLog(@"Did Write: TABLET_USB_FILE_COMPLETION_RESPONSE");
}

- (void)startSendingPeriodicHB
{
    if ([commandSocket isConnected])
    {
        //NSLog(@"Write: TABLET_USB_HEARTBEAT");
        NSData *hb_Data = [self.rm GetRequest:TABLET_USB_HEARTBEAT];
        [commandSocket writeData:hb_Data withTimeout:-1 tag:TABLET_USB_HEARTBEAT];
    
        //NSLog(@"Write: TABLET_USB_GET_VERSION");
        NSData *verson_Data = [self.rm GetRequest:TABLET_USB_GET_VERSION];
        [commandSocket writeData:verson_Data withTimeout:-1 tag:TABLET_USB_GET_VERSION];
    
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, TABLET_USB_HB_TIME_INTERVAL_NS);
        dispatch_after(when, tablet_usb_hb_Queue, ^{ @autoreleasepool {
            [self  startSendingPeriodicHB];
        }});
    }
}

//Change the active procedure set on the CCU.
- (void)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target
{
    //NSLog(@"Write: TABLET_RTOS_SET_ACTIVE_PROCEDURE");
    NSData *set_active_proc_data = [self.rm setActiveProcedureWithProcedureName:pName ColorHue:hue Phase:phase Saturation:saturation Zoom:zoom Sharpness:sharpness ELC:elc button1Short:b1SP button1Long:b1LP button2Short:b2SP button2Long:b2LP button3Short:b3SP button3Long:b3LP mediaTarget:target];
    [commandSocket writeData:set_active_proc_data withTimeout:-1 tag:TABLET_RTOS_SET_ACTIVE_PROCEDURE];
}

//Below methods are used to change the individual values of an active procedure on the CCU.
- (void)setColorHue:(int)hue colorSaturation:(int)saturation colorPhase:(int)phase
{
    //NSLog(@"Write: TABLET_RTOS_SET_COLOR");
    NSData *rtos_color_data = [self.rm setColor:hue sat:saturation phase:phase];
    [commandSocket writeData:rtos_color_data withTimeout:-1 tag:TABLET_RTOS_SET_COLOR];
}

- (void)setZoom:(int)zoom
{
    //NSLog(@"Write: TABLET_RTOS_SET_ZOOM");
    NSData *set_zoom_data = [self.rm setZoom:zoom];
    [commandSocket writeData:set_zoom_data withTimeout:-1 tag:TABLET_RTOS_SET_ZOOM];
}

- (void)setSharpness:(int)sharpness
{
    //NSLog(@"Write: TABLET_RTOS_SET_SHARP");
    NSData *set_sharpness_data = [self.rm setSharpness:sharpness];
    [commandSocket writeData:set_sharpness_data withTimeout:-1 tag:TABLET_RTOS_SET_SHARP];
}
- (void)setELC:(int)elc
{
    //NSLog(@"Write: TABLET_RTOS_SET_ELC");
    NSData *set_brigtness_data = [self.rm setELC:elc];
    [commandSocket writeData:set_brigtness_data withTimeout:-1 tag:TABLET_RTOS_SET_ELC];
}

//Set Button Mapping for an active procedure
- (void)setButton1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP
{
    //NSLog(@"Write: TABLET_RTOS_SET_BUTTONS");
    NSData *button_mapping_data = [self.rm setButtonMap:b1LP button2:b2LP button3:b3LP shortButton1:b1SP shortButton2:b2SP shortButton3:b3SP];
    [commandSocket writeData:button_mapping_data withTimeout:-1 tag:TABLET_RTOS_SET_BUTTONS];
}

- (void)setWhiteBalance:(int)white
{
    //NSLog(@"Write: TABLET_RTOS_SET_WHITE_BALANCE");
    NSData *white_balance_data = [self.rm setWhiteBalance:white];
    [commandSocket writeData:white_balance_data withTimeout:-1 tag:TABLET_RTOS_SET_WHITE_BALANCE];
}
- (void)setLightSource:(int)lightStatus
{
    //NSLog(@"Write: TABLET_RTOS_SET_LIGHT_ON");
    NSData *light_source_command_data = [self.rm setLightSource:lightStatus];
    [commandSocket writeData:light_source_command_data withTimeout:-1 tag:TABLET_RTOS_SET_LIGHT_ON];
}

//Modify the values of a remote procedure...available on the CCU device at an index.
- (void)setRemoteProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation whiteBalance:(int)white Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target atIndex:(int)index
{
    //NSLog(@"Write: TABLET_RTOS_SET_PROCEDURE");
    NSData *set_proc_data = [self.rm setProfile:hue sat:saturation phase:phase white:white sharpness:sharpness zoom:zoom elc:elc button1:b1LP button2:b2LP button3:b3LP shortbutton1:b1SP shortbutton2:b2SP shortbutton3:b3SP profileName:pName mediaTarget:target procedureindex:index];
    [commandSocket writeData:set_proc_data withTimeout:-1 tag:TABLET_RTOS_SET_PROCEDURE];
}

//Request(get) a remote procedure present on the CCU device, Index value ranges from 0...9
- (void)fetchRemoteProcedureAtIndex:(int)index
{
    //NSLog(@"Write: TABLET_RTOS_GET_PROCEDURE");
    NSData *get_proc_data = [self.rm getProfile:index];
    [commandSocket writeData:get_proc_data withTimeout:-1 tag:TABLET_RTOS_GET_PROCEDURE];
}

//Send a user entered character in tablet UI to rtos
- (void)setKeyBoardMap:(int)key
{
    //NSLog(@"Write: TABLET_RTOS_KEYBOARD_INPUT:%d",key);
    NSData *character_data = [self.rm setKeyBoardMap:key];
    [commandSocket writeData:character_data withTimeout:-1 tag:TABLET_RTOS_KEYBOARD_INPUT];
}


//Capture Media From CCU...CommandID defines (capture image/start video), target(USB/TABLET/BOTH), source(CAM1/CAM2)
- (void)captureMedia:(u8)commandID mediaTarget:(u8)target mediaSource:(u8)source
{
    //if (commandID == TABLET_USB_CAPTURE_IMAGE) NSLog(@"Write: TABLET_USB_CAPTURE_IMAGE");
    //else if (commandID == TABLET_USB_START_VIDEO_RECORD)  NSLog(@"Write: TABLET_USB_START_VIDEO_RECORD");
        
    [self.rm setMediaSource:source];
    NSData *capture_request_data = [self.rm CaptureImageOrVideo:commandID mediaTarget:target mediaSource:source];
    [commandSocket writeData:capture_request_data withTimeout:-1 tag:commandID];
}

//Stop Video Recording on a started mediaSource (CAM1/CAM2)
- (void)stopVideoRecordingOnMediaSource:(u8)mediaSource
{
    //NSLog(@"Write: TABLET_USB_STOP_VIDEO_RECORD");
    [self.rm setMediaSource:mediaSource];
    NSData *stop_recording_data = [self.rm GetRequest:TABLET_USB_STOP_VIDEO_RECORD mediaSource:mediaSource];
    [commandSocket writeData:stop_recording_data withTimeout:-1 tag:TABLET_USB_STOP_VIDEO_RECORD];
}

//File Completion response Recived acknowledgement to CCU
- (void)fileCompletionResponse:(file_complete_response_t)completionResponse
{
    //NSLog(@"Write: TABLET_USB_FILE_COMPLETION_RESPONSE");
    NSData *file_completion_response_data = [self.rm GetRequest:completionResponse cmdID:TABLET_USB_FILE_COMPLETION_RESPONSE];
    [commandSocket writeData:file_completion_response_data withTimeout:-1 tag:TABLET_USB_FILE_COMPLETION_RESPONSE];
}

//File Received acknowledgement to CCU
- (void)fileReceivedResponse:(file_complete_response_t)fileReceivedResponse
{
    //NSLog(@"Write: TABLET_USB_MEDIA_FILE_RECEIVED");
    NSData *file_received_response_data = [self.rm GetRequest:fileReceivedResponse cmdID:TABLET_USB_MEDIA_FILE_RECEIVED];
    [commandSocket writeData:file_received_response_data withTimeout:-1 tag:TABLET_USB_MEDIA_FILE_RECEIVED];
}

//Create a Folder on USB For Archiving Patient Files
- (void)createFolderForArchivingFilesOnUSB:(NSString *)folderName
{
    //NSLog(@"Write: TABLET_USB_CREATE_FOLDER");
    NSData *create_folder_data = [self.rm GetRequestForCreateFolder:TABLET_USB_CREATE_FOLDER folderName:folderName];
    [commandSocket writeData:create_folder_data withTimeout:-1 tag:TABLET_USB_CREATE_FOLDER];
}

//Set an Encoding Folder on USB
- (void)setEncodingFolderOnUSB:(NSString *)folderName
{
    //NSLog(@"Write: TABLET_USB_SET_ENCODING_FOLDER");
    NSData *set_encoding_folder_data = [self.rm GetRequestForCreateFolder:TABLET_USB_SET_ENCODING_FOLDER folderName:folderName];
    [commandSocket writeData:set_encoding_folder_data withTimeout:-1 tag:TABLET_USB_SET_ENCODING_FOLDER];
}

- (void)setMediaSource:(u8)source
{
    mediaSourceSet = source;
}
-(void)dealloc
{
    //NSLog(@"Deallocated :-)");
    commandSocket = nil;
    tablet_usb_hb_Queue = NULL;
    self.rm = nil;
    self.hostAddress = nil;
    self.portNumber = 0;
    self.delegate = nil;
}

@end
