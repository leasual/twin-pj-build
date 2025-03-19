#define PJ_CONFIG_IPHONE                    1
#define PJ_CONFIG_ANDROID                   0

#define PJMEDIA_HAS_SILK_CODEC              0
#define PJMEDIA_HAS_WEBRTC_AEC              1
#define PJMEDIA_WEBRTC_AEC_USE_MOBILE       1

#define PJMEDIA_HAS_VIDEO                   1
#define PJMEDIA_HAS_LIBYUV                  1
#define PJMEDIA_HAS_OPENH264_CODEC          1
#define PJMEDIA_HAS_SPEEX_CODEC             0
#define PJMEDIA_HAS_SPEEX_AEC               0

#define PJMEDIA_SRTP_HAS_DTLS               1
#define PJMEDIA_SRTP_HAS_AES_GCM_256        1
#define PJMEDIA_SRTP_HAS_AES_GCM_128        1

#define CUST_SKIP_MOBILE_CAMERA             1
#define CUST_USE_INTERNAL_CERT              0

#define PJ_MAX_SOCKOPT_PARAMS               5
#define PJ_SOCKET_KEEP_ALIVE_ENABLE         1
#define PJ_SOCKET_KEEP_ALIVE_IDLE           5
#define PJ_SOCKET_KEEP_ALIVE_INTERVAL       3
#define PJ_SOCKET_KEEP_ALIVE_COUNT          3
#define PJ_SOCKET_TCP_USER_TIMEOUT          15

#define PJSIP_TCP_KEEP_ALIVE_INTERVAL       20
#define PJSIP_TLS_KEEP_ALIVE_INTERVAL       20

//fix iOS 16 and Xcode 14 bug
//linked against modern SDK, VOIP socket will not wake error. 
#define PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT 1
#define PJ_ACTIVESOCK_TCP_IPHONE_OS_BG      0

#include <pj/config_site_sample.h>
