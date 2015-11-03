//
//  AsyncCommandChannel.h
//  Gnome
//

//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "usbMessage.h"
#import "usb_Data.h"
#import "usbTypes.h"

/** AsyncCommandChannelDelegate.
 
 The delegate of a AsyncCommandChannel object must adopt the AsyncCommandChannelDelegate protocol.
 
 */

@protocol AsyncCommandChannelDelegate <NSObject>
@optional
/**
To Notify when the Command Socket is Connected
 */
- (void)commandSocketConnected;

/**
To Notify when the Command Socket is DisConnected
 */
- (void)commandSocketDisconnected;

/**
To Notify when Disconnect Request is recived on the command channel
 */
- (void)disconnectRequestReceviedFromServer;

/**To Notify Response of setting encoding folder on the CCU
 @param response - response received from CCU for setting encoding folder on CCU
 */
- (void)setEncodingFolderResponse:(u8)response;

/**To Notify Response of creating a folder on the CCU
 @param response - response received from CCU for creating a folder on CCU
 */
- (void)createFolderResponse:(u8)response;

/**To periodically notify the current active procedure on the CCU/RTOS
 @param proc - Current Active Procedure Set On the CCU/RTOS
 */
- (void)receivedActiveProcedureOnRTOS:(procedure_d_t)proc;

/**To periodically notify the remote procedure on the CCU/RTOS
  @param proc - Remote Procedure On CCU
 */
- (void)receivedRequestedRTOSProcedure:(procedure_d_t)proc;

/** To periodically notify the tablet about the  USB and CCU version
 @param usbVersion - An ASCII value which represents the USB version
 @param ccuVersion - An ASCII value which represents the CCU version
 */
- (void)versionUSB:(char)usbVersion CCU:(char)ccuVersion;

/**To notify heart beat received from the CCU
 @param hb - heart beat value from CCU
 */
- (void)heartBeatReceived:(heartbeat_response_t)hb;

/**
 */
- (void)fileCompletionEventImage;

/**
 */
- (void)fileCompletionEventVideo;

/**
 @param usbQueryResponse - response from CCU for Archive To USb query from tablet
 @param mediaType - Type of media being sent.
 */
- (void)queryUSBReuestRespone:(u8)usbQueryResponse mediaType:(u8)mediaType;

@end

/** This class demonstrates AsyncCommandChannel.
 
 This class handles the read/write operations on the command socket.
 
 */

@interface AsyncCommandChannel : NSObject<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *commandSocket;
    dispatch_queue_t socketDelegateQueue;//This queue/thread will recive the delegate call-backs of GCDAsyncSocketDelegate
    dispatch_queue_t tablet_usb_hb_Queue;//Serial Queue, will send the periodic heart beat messages to USB
    //dispatch_queue_t command_socket_queue;
}
@property (nonatomic,weak) id<AsyncCommandChannelDelegate> delegate;

/**Intializes all the Queue for processing of data coming on the socket. Sets the HOST IP & Port Number
 @param _hostAddress - host IP address of the CCU created Wi-Fi network
 @param _portNo - Command channel socket port number
 */
- (id)initWithHostAddress:(NSString*)_hostAddress andPortNumber:(int)_portNo;

/**Asynchronously Opens the Command Socket of the CCU
 */
- (void)openSocket;

/**Force Disconnect the Command Socket
 */
-(void)disconnectSocket;

/** Disconnect Request from server response.
 @param status - response sent to CCU for Disconnect request coming from the CCU
 */
- (void)disconnectRequestResponse:(u8)status;

/** Initiate a TABLET_USB_HEARTBEAT & send it periodically.
 */
- (void)startSendingPeriodicHB;

/** Change the active procedure set on the CCU.
 @param pName - name of the procedure
 @param hue - Color Hue parameter of active procedure on CCU
 @param phase - Color phase parameter of active procedure on CCU
 @param saturation - Color saturation parameter of active procedure on CCU
 @param zoom - zoom parameter of active procedure on CCU
 @param sharpness - sharpness parameter of active procedure on CCU
 @param elc - elc parameter of active procedure on CCU
 @param b1SP - short press value for top button
 @param b1LP - long press value for top button
 @param b2SP - short press value for left button
 @param b2LP - long press value for left button
 @param b3SP - short press value for right button
 @param b3LP - long press value for right button
 @param target - destination target for the captured media
 */
- (void)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target;

/** To change the hue, saturation and phase values of an active procedure on the CCU.
 @param hue - enum hue value to be set on the active procedure
 @param saturation - enum saturation value to be set on the active procedure
 @param phase - enum phase value to be set on the active procedure
*/
- (void)setColorHue:(int)hue colorSaturation:(int)saturation colorPhase:(int)phase;

/** To change the zoom value of an active procedure on the CCU.
 @param zoom - enum zoom value to be set on the active procedure
 */
- (void)setZoom:(int)zoom;

/** To change the sharpness value of an active procedure on the CCU.
@param sharpness - enum sharpness value to be set on the active procedure
 */
- (void)setSharpness:(int)sharpness;

/** To change the ELC value of an active procedure on the CCU.
 @param elc - enum brightness value to be set on the active procedure
 */
- (void)setELC:(int)elc;

/** Set Button Mapping for an active procedure.
 @param b1LP - long press value for top button
 @param b2LP - long press value for left button
 @param b3LP - long press value for right button
 @param b1SP - short press value for top button
 @param b2SP - short press value for left button
 @param b3SP - short press value for right button 
 */
- (void)setButton1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP;

/** Initiate White Balance On CCU.
 @param white - value to set while balance on CCU
 */
- (void)setWhiteBalance:(int)white;

/** Turn On Light Source On CCU.
 @param lightStatus - value to turn on light source of CCU
 */
- (void)setLightSource:(int)lightStatus;

/** Modify the values of a remote procedure...available on the CCU device at an index.
 @param hue - Color Hue parameter of remote procedure
 @param sat - Color Saturation parameter of remote procedure
 @param phase - Color Phase parameter of remote procedure
 @param white - Color Hue parameter of remote procedure
 @param sharpness - sharpness parameter of remote procedure
 @param zoom - zoom parameter of remote procedure
 @param elc - brightness parameter of remote procedure
 @param b1 - long press value for top button
 @param b2 - long press value for left button
 @param b3 - long press value for right button
 @param sb1 - short press value for top button
 @param sb2 - short press value for left button
 @param sb3 - short press value for right button
 @param profileName - name of the procedure
 @param mediaTarget - media target for the remote procedure
 @param index - Index of the Remote Procedure on RTOS whose values shall be updated
 */
- (void)setRemoteProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation whiteBalance:(int)white Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target atIndex:(int)index;

/** Request(get) a remote procedure present on the CCU device, Index value ranges from 0...9.
 @param index - Index value of the Remote procedure requested
*/
- (void)fetchRemoteProcedureAtIndex:(int)index;

/** Send a user entered character to rtos.
 @param key - ASCII value for the character entered in the tablet application.
 */
- (void)setKeyBoardMap:(int)key;

/** Capture Media From CCU...CommandID defines (capture image/start video), target(USB/TABLET/BOTH), source(CAM1/CAM2).
 @param commandID - Command type to capture Image or start video recording
 @param target - destination target for the captured media
 @param source - media source for captured media
 */
- (void)captureMedia:(u8)commandID mediaTarget:(u8)target mediaSource:(u8)source;

/** Stop Video Recording on a started mediaSource (CAM1/CAM2).
 @param mediaSource - media source to stop recording
 */
- (void)stopVideoRecordingOnMediaSource:(u8)mediaSource;

/** File Completion response Recived acknowledgement to CCU.
 @param completionResponse - FILE_COMPLETION_NACK or FILE_COMPLETION_ACK
 */
- (void)fileCompletionResponse:(file_complete_response_t)completionResponse;

/** File Received acknowledgement to CCU.
 @param fileReceivedResponse - FILE_RECEIVED_NACK or FILE_RECEIVED_ACK
 */
- (void)fileReceivedResponse:(file_complete_response_t)fileReceivedResponse;

/** Create a Folder on USB For Archiving Patient Files.
 @param folderName - Create a folder on CCU with Patient MRN ID before starting Archiving files for that patient
 */
- (void)createFolderForArchivingFilesOnUSB:(NSString *)folderName;

/** Set an Encoding Folder on USB.
 @param encodingFolderName - Encoding Folder name (Patient MRN ID) to be set on the USB when a patinet file is opened
 */
- (void)setEncodingFolderOnUSB:(NSString *)folderName;

/** Set Media Source.
 @param source - Media Source if it is channel 1 or channel 2
 */
- (void)setMediaSource:(u8)source;

/**To parse the version information coming from the CCU
 @param data - version information data
 */
- (void)parseVersion:(NSData *)data;

/** To parse the heart beat information coming from the CCU
 @param hbData - heart beat data
 */
- (void)parseHeatbeat:(NSData *)hbData;

@end
