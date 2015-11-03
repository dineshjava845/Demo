

#import "RequestManager.h"
#import "SNGCCUSharedManager.h"

@implementation RequestManager

- (void)setMediaSource:(u8)source{
    mediaSource = source;
}
- (void)setTabletState:(u8)state
{
    tabState = state;
}
- (void)setTabletInfo:(u8)info
{
    tabInfo = info;
}
- (id)init
{
    return self;
    mediaSource = VID1;
}
- (NSData *)GetRequest:(file_complete_response_t)completeresponse cmdID:(u8)cmd
{
    NSLog(@"file completion response:%d",cmd);
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int size = sizeof(file_complete_response_t);
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    
    int i=0,j=0;
    u32 txSize = sizeof(network_message_t)+size+1;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmd;
    
    bzero(&cm.padding, sizeof(cm.padding));
    
    cm.network_command_data_length = htonl(size);
    
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&completeresponse;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData* )GetSendFile:(u32)fileSize fileName:(NSString*)fileName folderName:(NSString*)folderName mediaType:(u8)mediaType{
    NSLog(@"************SEND FILE SIZE B4 htonl:%d *********",fileSize);
    usb_fileInfo_rx_t sendFile;
    uint8_t *someInt;
    sendFile.fileSize = htonl(fileSize);
    sendFile.mediaType = mediaType;
    NSLog(@"************SEND FILE SIZE AFTER htonl:%d ***********",sendFile.fileSize);
    bzero(sendFile.fileName, DEFAULT_NAME_SIZE);
    someInt = (uint8_t *)[fileName UTF8String];
    for(int i = 0; i<fileName.length; i++){
        sendFile.fileName[i] = *(someInt+i);
    }
    
    bzero(sendFile.folderName, DEFAULT_NAME_SIZE);
    someInt = (uint8_t *)[folderName UTF8String];
    for(int i = 0; i<folderName.length; i++){
        sendFile.folderName[i] = *(someInt+i);
    }
    
    
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = TABLET_USB_SEND_FILE_TO_FLASH;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(usb_fileInfo_rx_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&sendFile;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)GetRequestForDeleteFlash:(u8)cmdID folderName:(NSString*)folderName fileName:(NSString*)fileName{
    //NSLog(@"RM GetRequestForDeleteFlash:");
    uint8_t *someInt = (uint8_t *)[folderName UTF8String];
    uint8_t txBuffer[256];
    int i,j=0;
    u32 txSize;
    int size;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmdID;
    bzero(&cm.padding, sizeof(cm.padding));    
    bzero(txBuffer, 256);
    usb_fileInfo_rx_t hb;
    bzero(hb.folderName, DEFAULT_NAME_SIZE);
    bzero(hb.fileName, DEFAULT_NAME_SIZE);
    for(int i = 0; i<folderName.length; i++){
        hb.folderName[i] = *(someInt+i);
    }
    someInt = (uint8_t *)[fileName UTF8String];
    for(int i = 0; i<fileName.length; i++){
        hb.fileName[i] = *(someInt+i);
    }
    size = sizeof(usb_fileInfo_rx_t);
    txSize = sizeof(network_message_t)+size+1;
    
    cm.network_command_data_length = htonl(size);
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&hb;
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)GetRequestForCreateFolder:(u8)cmdID folderName:(NSString*)folderName{
    //NSLog(@"RM GetRequestForCreateFolder");
    if (folderName == nil) {
        return nil;
    }
    if(folderName.length > DEFAULT_NAME_SIZE){
        return nil;
    }
    uint8_t *someInt = (uint8_t *)[folderName UTF8String];
    uint8_t txBuffer[256];
    int i,j;
    u32 txSize;
    int size;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmdID;
    bzero(&cm.padding, sizeof(cm.padding));    
    bzero(txBuffer, 256);
    create_set_folder_t hb;
    bzero(hb.folderName, DEFAULT_NAME_SIZE);
    for(int i = 0; i<folderName.length; i++){
        hb.folderName[i] = *(someInt+i);
    }
    size = sizeof(hb);
    txSize = sizeof(network_message_t)+size+1;
    
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&hb;
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    
    for (j = 0 ; j < size; j++)
        txBuffer[i+j] = pPl[j];
    
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    return [NSData dataWithBytes:txBuffer length:txSize];
}
- (NSData *)setColor:(int)hue sat:(int)sat phase:(int)phase{
       // NSLog(@"RM setColor");
    tablet_rtos_color_t  c;
    /*c.hue = hue;
    c.sat = sat;
    c.phase = phase;*/
    c.color_hue = hue;
    c.color_sat = sat;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_COLOR;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(tablet_rtos_color_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&c;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
    
}
- (NSData *)setWhiteBalance:(int)white{
    //NSLog(@"RM setWhiteBalance");
//    u8  wb;    // comment out to fix 711 dead store
//    wb = white;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_WHITE_BALANCE;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = 0;
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
//    pPl = (uint8_t *)&wb;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
}

- (NSData *)setLightSource:(int)lightStatus{
     //NSLog(@"RM setLightSource");
//    u8  wb;           // comment out to fix bug 711 dead store
//    wb = lightStatus;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_LIGHT_ON;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = 0;
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    //    pPl = (uint8_t *)&wb;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
}

- (NSData *)setKeyBoardMap:(int)key{
   // NSLog(@"RM setKeyBoardMap");
    u8  wb;
    wb = key;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_KEYBOARD_INPUT;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(u8);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&wb;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
    
}
- (NSData *)setSharpness:(int)sharpness{
    //NSLog(@"RM setSharpness");

    u8  sh;
    sh = sharpness;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_SHARP;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(u8);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&sh;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)setZoom:(int)zoom{
    //NSLog(@"RM setZoom");
    u8  z;
    z = zoom;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_ZOOM;
    bzero(&cm.padding, sizeof(cm.padding));    
    size = sizeof(u8);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&z;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (int) powerOf:(int)value{
    //NSLog(@"RM powerOf");
    int result = 1;
    for(int i = 0;i<value;i++){
        result *= 2;
    }
    return result;
}
- (int) calculateButtonMap:(int)buttonL buttonShort:(int)buttonS{
    //NSLog(@"RM calculateButtonMap");
    unsigned char bits[8];
    unsigned char mask = 1;
    for (int i = 0; i < 8; i++) {
        bits[i] = buttonL & (mask << i);
        bits[i] >>=i;
    }
    unsigned char Sbits[8];
    unsigned char Smask = 1;
    for (int i = 0; i < 8; i++) {
        Sbits[i] = buttonS & (Smask << i);
        Sbits[i] >>=i;
    }
    unsigned char Rbits[8];
        int j = 0;
    for(int i = 0; i<4;i++){
        Rbits[i] = Sbits[i];
        j = i;
    }
    for(int i = 0; i<4;i++){
        Rbits[++j] = bits[i];
    }
    int result = 0;
    for(int i = 0; i<8;i++){
        if(Rbits[i] == 1){
            result += [self powerOf:i];
        }
    }
  
    return result;
}
- (NSData *)setButtonMap:(int)button1 button2:(int)button2 button3:(int)button3 shortButton1:(int)sb1 shortButton2:(int)sb2 shortButton3:(int)sb3{
    //NSLog(@"RM setButtonMap");
    tablet_rtos_buttons_t  bm;
    
    bm.bmap1 = [self calculateButtonMap:sb1 buttonShort:button1];
     bm.bmap2 = [self calculateButtonMap:sb2 buttonShort:button2];
     bm.bmap3 = [self calculateButtonMap:sb3 buttonShort:button3];
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_BUTTONS;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(tablet_rtos_buttons_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&bm;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
}
- (NSData *)setELC:(int)elc{
    //NSLog(@"RM setELC");
    u8  e;
    e = elc;
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_ELC;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(u8);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&e;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
}
-(NSData *) setProfile:(int)hue sat:(int)sat phase:(int)phase white:(int)white sharpness:(int)sharpness zoom:(int)zoom elc:(int)elc button1:(int)b1 button2:(int)b2 button3:(int)b3 shortbutton1:(int)sb1 shortbutton2:(int)sb2 shortbutton3:(int)sb3 profileName:(NSString *)profileName mediaTarget:(u8)mediaTarget procedureindex:(int)index{

   // NSLog(@"RM setProfile");
    rtos_tab_get_set_procedure_t  pr;
    pr.procedure.color_hue = hue;
    pr.procedure.color_sat = sat;
    //pr.procedure.color_phase = phase;

    pr.procedure.button1Map = [self calculateButtonMap:sb1 buttonShort:b1];
    pr.procedure.button2Map = [self calculateButtonMap:sb2 buttonShort:b2];
    pr.procedure.button3Map = [self calculateButtonMap:sb3 buttonShort:b3];

    
    pr.procedure.zoom = zoom;
    pr.procedure.sharpness = sharpness;
    pr.procedure.elc = elc;
    pr.procedure.media_target = mediaTarget;
    pr.procedure_index = index;
    
    //To-Do Decode Procedure name & set it to procedure
    char arr[32];
    strcpy(arr, [profileName cStringUsingEncoding:NSUTF8StringEncoding]);
    
    for (int i=0; i<32; i++)
    {
        pr.procedure.pName [i] = arr[i];
    }
    
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_PROCEDURE;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(rtos_tab_get_set_procedure_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&pr;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}

-(NSData *)setActiveProcedureWithProcedureName:(NSString *)pName ColorHue:(int)hue Phase:(int)phase Saturation:(int)saturation Zoom:(int)zoom Sharpness:(int)sharpness ELC:(int)elc button1Short:(int)b1SP button1Long:(int)b1LP button2Short:(int)b2SP button2Long:(int)b2LP button3Short:(int)b3SP button3Long:(int)b3LP mediaTarget:(u8)target
{
    //NSLog(@"RM setActiveProcedureWithProcedureName");
    procedure_d_t  pr;
    pr.color_hue = hue;
    pr.color_sat = saturation;
    //pr.color_phase = phase;
    
    pr.button1Map = [self calculateButtonMap:b1LP buttonShort:b1SP];
    pr.button2Map = [self calculateButtonMap:b2LP buttonShort:b2SP];
    pr.button3Map = [self calculateButtonMap:b3LP buttonShort:b3SP];
    
    pr.zoom = zoom;
    pr.sharpness = sharpness;
    pr.elc = elc;
    pr.media_target = target;
    //pr.procedure_index = index;
    
    char arr[32];
    strcpy(arr, [pName cStringUsingEncoding:NSUTF8StringEncoding]);
    
    for (int i=0; i<32; i++)
    {
        pr.pName [i] = arr[i];
    }
    
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_SET_ACTIVE_PROCEDURE;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(procedure_d_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&pr;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    NSLog(@"tx Size:%d",txSize);
    return [NSData dataWithBytes:txBuffer length:txSize];
}


- (NSData *) getProfile:(int)profile{
    //NSLog(@"RM getProfile");
    u8 pn = profile;
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_RTOS;
    cm.command_id = TABLET_RTOS_GET_PROCEDURE;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(u8);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&pn;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)GetQueryUSBReady:(u8)mediaType folderName:(NSString*)folderName withFileSize:(u32)fileSize{
    //NSLog(@"RM GetQueryUSBReady");
    usb_tablet_query_t usbTabQ;
    usbTabQ.fileSize = htonl(fileSize);
    usbTabQ.mediaType = mediaType;
    uint8_t *someInt = (uint8_t *)[folderName UTF8String];
    bzero(usbTabQ.folderName, DEFAULT_NAME_SIZE);
    
    for(int i = 0; i<folderName.length; i++){
        usbTabQ.folderName[i] = *(someInt+i);
    }
    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = TABLET_USB_QUERY_READY_RECEIVE_FILE;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(usb_tablet_query_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&usbTabQ;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}

- (NSData *)CaptureImageOrVideo:(u8)cmdID mediaTarget:(u8)mediaTarget mediaSource:(u8)source{
    //NSLog(@"RM CaptureImageOrVideo");
    
    video_cmd_t hb;
    hb.videoInput = source;
    hb.media_target = mediaTarget;

    
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmdID;
    bzero(&cm.padding, sizeof(cm.padding));    
    
    size = sizeof(video_cmd_t);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&hb;
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)GetRequest:(u8)cmdID
{
    //NSLog(@"Request manager GetRequest:%d",[NSThread isMainThread]);
    //NSLog(@"RM GetRequest:(%d",cmdID);
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmdID;
    bzero(&cm.padding, sizeof(cm.padding));    switch (cmdID) {
        case TABLET_USB_GET_VERSION:{
            usb_get_resp_tablet_version_t hb;
            hb.self_version = TAB_VERSION;
            hb.other_version = OTHER_VERSION;
            size = sizeof(usb_get_resp_tablet_version_t);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&hb;
            break;
        }
        case TABLET_USB_HEARTBEAT:{
            //NSDate *startTime = [NSDate date];
            //NSLog(@"Start time: %@",[NSDate date]);
            tablet_heartbeat_t hb;
            uint8_t *someInt;
            bzero(&hb, sizeof(tablet_heartbeat_t));
            hb.tab_state = [[SNGCCUSharedManager sharedCCManager] getTabletState];  //3;//values 1/2/34/
            hb.tab_info = [[SNGCCUSharedManager sharedCCManager] tabletInfoBasedOnTabletState:hb.tab_state];//2;//
            PatientData *patient_data = [PatientData sharedManager];
            
            // if state is in patient we do some more checking, otherwise all fields are '0'
            switch(hb.tab_state)
            {
                case 1:
                default:
                    break;
                case 2:
                case 3:
                    
                    // 1 byte for each - normalize to < 255
                    hb.tab_patient_images = (int)(patient_data.imagesCount%255);
                    hb.tab_patient_videos = (int)(patient_data.videosCount%255);

                    
                    // copy lastname first
                    int j, i = 0;
                    if (patient_data.lastName.length)
                    {
                        someInt = (uint8_t *)[patient_data.lastName UTF8String];
                        for (i = 0 ; ((i <13) && (i < patient_data.lastName.length)) ; i++)
                            hb.patientNameInfo[i] =  *(someInt+i);
                        if (patient_data.firstName.length)
                            hb.patientNameInfo[i++] = ',';
                    }
                    
                    // fill in the rest with first name characters
                    if (patient_data.firstName.length)
                    {
                        someInt = (uint8_t *)[patient_data.firstName UTF8String];
                        for (j = 0 ; ((i <16) && (j < patient_data.firstName.length)) ; i++,j++)
                            hb.patientNameInfo[i] =  *(someInt+(j));
                    }
                    break;
            }
            //NSLog(@"Tab state:%d",hb.tab_state);
            size = sizeof(tablet_heartbeat_t);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&hb;
            //NSDate *endTime = [NSDate date];
            //NSLog(@"HB Composition Time: %f",[endTime timeIntervalSinceDate:startTime]);
            break;
        }
        case TABLET_USB_CONNECT_REQUEST:{
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            break;
        }
            
        case TABLET_USB_CAPTURE_IMAGE:{
            //NSLog(@"selected media source=(%d)",mediaSource);
            video_cmd_t hb;
            hb.videoInput = mediaSource;
            hb.media_target = TABLET_ONLY;
            size = sizeof(video_cmd_t);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&hb;
            break;
            
        }
            //        case TABLET_USB_CONFIGURE:{
            //            break;
            //        }
        
        case TABLET_USB_DELETE_FILE_FLASH:{
            //            usb_fileInfo_rx_t
            break;
        }
        case TABLET_USB_DISCONNECT_RESPONSE:{
            u8  response = TABLET_DISCONNECT_OK;
            size = sizeof(response);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&response;
            break;
        }
            //        case TABLET_USB_GET_FILE_FROM_FLASH:{
            //            break;
            //        }
            //        case TABLET_USB_GET_LIST_FILES_FLASH:{
            //            break;
            //        }
        
        case TABLET_USB_MEDIA_FILE_RECEIVED:{
            break;
        }
        case TABLET_USB_SEND_FILE_TO_FLASH:{
            break;
        }
        case TABLET_USB_START_VIDEO_RECORD:{
            video_cmd_t hb;
            hb.videoInput = mediaSource;
            hb.media_target = TABLET_ONLY;
            size = sizeof(video_cmd_t);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&hb;
            break;
        }
        case TABLET_USB_STOP_VIDEO_RECORD:{
            u8 videoSrc = mediaSource;
            size = sizeof(videoSrc);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&videoSrc;
            break;
        }
    }
    for (i = 0 ; i < 8; i++)
        if (pNm)  // fix bug 711 Logic error
            txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (NSData *)GetRequest:(u8)cmdID mediaSource:(u8)source
{
    //NSLog(@"RM GetRequest:%d",cmdID);
    //NSLog(@"Request manager GetRequest:%d",[NSThread isMainThread]);
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = cmdID;
    bzero(&cm.padding, sizeof(cm.padding));    switch (cmdID) {
        case TABLET_USB_STOP_VIDEO_RECORD:{
            u8 videoSrc = source;
            size = sizeof(videoSrc);
            txSize = sizeof(network_message_t)+size+1;
            cm.network_command_data_length = htonl(size);
            pNm = (uint8_t *)&cm;
            pPl = (uint8_t *)&videoSrc;
            break;
        }
    }
    for (i = 0 ; i < 8; i++)
        if (pNm) // fix bug 711 Logic error
            txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
}
- (NSData *)GetDisconnectRequest:(u8)status
{
    //NSLog(@"RM GetDisconnectRequest");
    uint8_t txBuffer[256];
    bzero(txBuffer, 256);
    int i =0,j=0;
    u32 txSize;
    int size = 0;
    uint8_t *pNm = 0;
    uint8_t *pPl = 0;
    network_message_t cm;
    cm.protocol_id = PROTOCOL_TABLET_TO_USB;
    cm.command_id = TABLET_USB_DISCONNECT_RESPONSE;
    bzero(&cm.padding, sizeof(cm.padding));
    u8  response = status;
    size = sizeof(response);
    txSize = sizeof(network_message_t)+size+1;
    cm.network_command_data_length = htonl(size);
    pNm = (uint8_t *)&cm;
    pPl = (uint8_t *)&response;
    
    
    for (i = 0 ; i < 8; i++)
        txBuffer[i] = pNm[i];
    if(pPl != 0){
        for (j = 0 ; j < size; j++)
            txBuffer[i+j] = pPl[j];
    }
    i = i+j;
    txBuffer[i] = [self doCRC:txBuffer withSize:(sizeof(cm) + size)];
    
    return [NSData dataWithBytes:txBuffer length:txSize];
    
}
- (uint8_t)doCRC:(uint8_t *)inbuffer withSize:(uint32_t)sizer{
    //NSLog(@"RM doCRC:");
    int i, sum = 0;
    unsigned char crc;
    char checksum;
    for (i = 0 ; i < sizer ; i++)
        sum += inbuffer[i];
    checksum = sum % 256;
    crc = ~checksum + 1;
    return crc;
}
@end
