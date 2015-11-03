//
//  AsyncCCUManager.h
//  Gnome
//
//

#import <Foundation/Foundation.h>
#import "usbMessage.h"
#import "usb_Data.h"
#import "usbTypes.h"
#import "AsyncCommandChannel.h"
#import "ImageSocket.h"
#import "VideoSocket.h"

/** AsyncCCUManagerDelegate.
 
 The delegate of a AsyncCCUManager object must adopt the AsyncCCUManagerDelegate protocol.
 
 */

@protocol AsyncCCUManagerDelegate <NSObject>

/** Get notify when connection to CCU is successed.
 */
- (void)connected;

/** Get notify when tablet is disconnected from the CCU.
 */
- (void)disconnectedFromServer;

/** Get notify when CCU sends request to disconnect when Second tablet is trying to Connect.
 */
- (void)disconnectRequestServer;

/** Get heat beat information.
 @param RxTransaction
 @param TxTransaction
 */
- (void)heartBeatTransaction:(int)RxTransaction TxTransaction:(int)TxTransaction;

/**To notify heart beat received from the CCU
 @param hb Heart beat value from CCU
 */
- (void)heartBeat:(heartbeat_response_t)hb;

/** To notify the tablet about the  USB and CCU version
 @param usb An ASCII value which represents the USB version
 @param ccu An ASCII value which represents the CCU version
 */
- (void)versionInfo:(char)usb CCU:(char)ccu;

/** Get file downloaing status.
 @param totalsize Total Size of the file(Video/Image) being downloaded
 @param current Chunk of total file data received in the current received packet
 @param filename Name of the file coming from the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)fileDownloadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/** Get the downloaded information.
 @param filepath Temporary path where the file being downloaded is stored
 @param filesize Total size of the file being downloaded.
 @param downloadTime Time taken to download the file in seconds
 @param mediaType File type indicating if it is a Video or Image
 */
- (void)fileDownloaded:(NSString*)filepath fileSize:(NSInteger)filesize downloadTime:(NSTimeInterval)downloadTime mediaType:(u8)mediaType;

/**To Notify Response of creating a folder on the CCU
 @param response Response received from CCU for creating a folder on CCU
 */
- (void) createFolderResponse:(u8)response;

/**To Notify Response of setting encoding folder on the CCU
 @param response Response received from CCU for setting encoding folder on CCU
 */
- (void) createEncoderFolderResponse:(u8)response;

/** Get file uploading status.
 @param totalsize Total Size of the file(Video/Image) being uploaded
 @param current Chunk of total file data uploaded in the current uploaded packet
 @param filename Name of the file being sent to the CCU
 @param mediaType File type indicating if it is a Video or Image
 */
- (void) fileUploadingProgress:(NSInteger)totalsize completed:(NSInteger)current filename:(NSString*)filename mediaType:(u8)mediaType;

/** Get Notified about the uploaded file.
 @param filepath Source path of the file on the tablet
 @param filesize Total size of the file being uploaded in bytes.
 @param uploadTime Time taken to upload the file in seconds
 */
-(void) fileUploaded:(NSString*)filepath fileSize:(NSInteger)filesize uploadTime:(NSTimeInterval)uploadTime;

/**Active Procedure Set on the RTOS
 @param proc Procedure currently active on the RTOS
 */
-(void)activeRTOSProcedure:(procedure_d_t)proc;

/**
 @param proc
 */
-(void)receivedRequestedRTOSProcedure:(procedure_d_t)proc;

/**
 @param response
 @param mediaType
 */
-(void)queryUSBRecivedResponse:(u8)response mediaType:(u8)mediaType;

-(void)NACKResponseToFileCompletionEvent;

@end

/** This class demonstrates AsyncCCUManager.
 
 This class manages the interaction between all the socket classes and the ui classes of the application. Also notifies the SNGCCUSharedManager about the updates from the sockets.
 
 */

@interface AsyncCCUManager : NSObject<AsyncCommandChannelDelegate,ImageSocketDelegate,VideoSocketDelegate>
{
    __weak id <AsyncCCUManagerDelegate>delegate;
}

@property (nonatomic,weak) id <AsyncCCUManagerDelegate>delegate;

/**
 @param hostIP IP Address of the socket
 */
- (id)init:(NSString *)hostIP;

/**To send a request to establish  a connection between CCU and Tablet
 */
- (void)connectToCCU;

/**To send a request to end a connection between CCU and Tablet.
 */
-(void)forceDisconnectFromCCU;

/**Response Sent to Disconnect Request from CCU
 @param status Response sent to CCU for Disconnect request coming from the CCU
 */
- (void)disconnect:(u8)status;

/** Set an Encoding Folder on USB.
 @param encodingFolderName Encoding Folder name (Patient MRN ID) to be set on the USB when a patinet file is opened
 */
- (void)setEncodingFolder:(NSString *)encodingFolderName;

/** Create a Folder on USB For Archiving Patient Files.
 @param folderName Create a folder on CCU with Patient MRN ID before starting Archiving files for that patient
 */
- (void)createFolder:(NSString *)folderName;

/**
 @param filePath Source file path of the Image/Text/Audio
 @param fileName Source file name on tablet application
 @param folderName Destination folder name on USB
 */
- (void)sendImageFile:(NSString*)filepath fileName:(NSString*)fileName folderName:(NSString*) folderName;

/**
 @param filePath Source file path of the Video
 @param fileName Source file name on tablet application
 @param folderName Destination folder name on USB
 */
- (void)sendVideoFile:(NSString*)filepath fileName:(NSString*)fileName folderName:(NSString*) folderName;

/** Capture image and set the folder path.
 @param folderPath Temporary file path to save the captures image
 @param target Destination media target for the file which is going tobe captured
 @param source Channel on which image needs to be captured (CAM1/CAM2)
 */
- (void)captureImage:(NSString*)folderpath  mediaTarget:(u8)target mediaSource:(u8)source;

/** Start video recording and set the folder path.
 @param folderPath - Temporary file path to save the captures Video
 @param target - Destination media target for the file which is going to be captured.
 @param source - Channel on which video recoding shall be started (CAM1/CAM2)
 */
- (void)startRecording:(NSString*)folderpath  mediaTarget:(u8)target mediaSource:(u8)source;

/** Stop Video Recording on a started mediaSource (CAM1/CAM2).
 @param source - Channel on which video recoding shall be stopped (CAM1/CAM2)
 */
- (void)stopRecordingOnMediaSource:(u8)source;

/** Send a user entered character to rtos.
 @param key ASCII value for the character entered in the tablet application.
 */
- (void)setKeyboardInput:(char)key;

/** To change the hue, saturation and phase values of an active procedure on the CCU.
 @param hue Enum hue value to be set on the active procedure
 @param sat Enum saturation value to be set on the active procedure
 @param phase Enum phase value to be set on the active procedure
 */
- (void)setColor:(int)hue sat:(int)sat phase:(int)phase;

/** To change the ELC value of an active procedure on the CCU.
 @param elc Enum brightness value to be set on the active procedure
 */
- (void)setELC:(int)elc;

/** To change the sharpness value of an active procedure on the CCU.
 @param sharpness Enum sharpness value to be set on the active procedure
 */
- (void)setSharpness:(int)sharpness;

/** To change the zoom value of an active procedure on the CCU.
 @param zoom Enum zoom value to be set on the active procedure
 */
- (void)setZoom:(int)zoom;

/** Set Button Mapping for an active procedure.
 @param b1 Long press value for top button
 @param b2 Long press value for left button
 @param b3 Long press value for right button
 @param sb1 Short press value for top button
 @param sb2 Short press value for left button
 @param sb3 Short press value for right button
 */
- (void)setButtonMap:(int)b1 button2:(int)b2 button3:(int)b3 shortButton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3;

/** Initiate White Balance On CCU.
 @param white Value to set while balance on CCU
 */
- (void)setWhiteBalance:(int)white;

/** Turn On Light Source On CCU.
  @param lightStatus Value to turn on light source of CCU
 */
- (void)setLightSource:(int)lightStatus;

/** Request(get) a remote procedure present on the RTOS device, Index value ranges from 0...9.
 @param profile Index of the remote procedure available on the RTOS.
 */
- (void)getProfile:(int)profile;

/** Modify the values of a remote procedure...available on the CCU device at an index.
 @param hue Color Hue parameter of remote procedure
 @param sat Color Saturation parameter of remote procedure
 @param phase Color Phase parameter of remote procedure
 @param white While Balance parameter of remote procedure
 @param sharpness Sharpness parameter of remote procedure
 @param zoom Zoom parameter of remote procedure
 @param elc Brightness parameter of remote procedure
 @param b1 Long press value for top button
 @param b2 Long press value for left button
 @param b3 long press value for right button
 @param sb1 Short press value for top button
 @param sb2 Short press value for left button
 @param sb3 Short press value for right button
 @param profileName Name of the procedure
 @param mediaTarget Media target for the remote procedure
 @param index Index of the Remote Procedure on RTOS whose values shall be updated
 */
- (void)setProfile:(int)hue sat:(int)sat phase:(int)phase white:(int)white sharpness:(int)sharpness zoom:(int)zoom elc:(int)elc button1:(int)b1 button2:(int)b2 button3:(int)b3 shortbutton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3 profileName:(NSString *)profileName mediaTarget:(u8)mediaTarget procedureindex:(int)index;

/** Change the active procedure set on the CCU.
 @param pName Name of the procedure
 @param hue Color Hue parameter of active procedure on CCU
 @param phase Color phase parameter of active procedure on CCU
 @param saturation Color saturation parameter of active procedure on CCU
 @param zoom Zoom parameter of active procedure on CCU
 @param sharpness Sharpness parameter of active procedure on CCU
 @param elc Brightness parameter of active procedure on CCU
 @param b1SP Short press value for top button
 @param b1LP Long press value for top button
 @param b2SP Short press value for left button
 @param b2LP Long press value for left button
 @param b3SP Short press value for right button
 @param b3LP Long press value for right button
 @param target Destination target for the captured media
 */
- (void)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target;

/** Set Media Source.
 @param source Media Source if it is channel 1 or channel 2
 */
- (void)setMediaSource:(u8)source;

/**To Determine if there is file transfer from CCU to LENS iPad App
 @return YES if there is file transmission from CCU to LENS iPad App. Otherwise NO.
 */
- (BOOL)isFileRxInProgress;

/**To Determine if there is file transfer from LENS iPad App to CCU
 @return YES if there is file transmission from LENS iPad App to CCU. Otherwise NO.
 */
- (BOOL)isFileTxInProgress;

/**Query the USB if it is ready to accept file on the video channel
 @param folderName Destination folder for the file to be sent
 @param inFileSize Size of the File to be sent in Bytes
 */
- (void)queryUSBVideoChannel:(NSString *)folderName fileSize:(unsigned long long)inFileSize;

/**Query the USB if it is ready to accept file on the image channel
 @param folderName Destination folder for the file to be sent
 @param inFileSize Size of the File to be sent in Bytes
 */
- (void)queryUSBImageChannel:(NSString *)folderName fileSize:(unsigned long long)inFileSize;

/**
 */
-(void)printBytesReadOnVidChannel;

/**
 */
-(void)printBytesReadOnImgChannel;
@end
