//
//  ZcurlManager.m
//  ZAPM
//
//  Created by lZackx on 2022/8/1.
//

#import "ZcurlManager.h"
#import "Zcurl.h"
#import "curl.h"


@implementation ZcurlManager

// MARK: - Life Cycle
static ZcurlManager *_shared;

+ (instancetype)shared {
    if (_shared == nil) {
        _shared = [[ZcurlManager alloc] init];
    }
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        curl_global_init(CURL_GLOBAL_SSL);
    }
    return self;
}

- (instancetype)copy {
    return self;
}

- (instancetype)mutableCopy {
    return self;
}

- (void)dealloc {
    curl_global_cleanup();
}

// MARK: - API
- (void)performWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        ZLog(@"curl perform failed: %@", urlString);
        return;
    }
    [self performWithURL:url];
}

- (void)performWithURL:(NSURL *)url {
    
    CURLcode code;
    CURL *curl = curl_easy_init();
    
    // verbose
    int verbose = 0L;
#if ZCURL_DEBUG
    verbose = 1L;
#endif
    code = curl_easy_setopt(curl, CURLOPT_VERBOSE, verbose);
    ZLog(@"CURLOPT_VERBOSE status: %u", code);
    
    // URL
    code = curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);
    ZLog(@"CURLOPT_URL status: %u", code);
    // SSL
    NSBundle *zcurlBundle = [NSBundle bundleForClass:[Zcurl class]];
    NSString *caPath = [zcurlBundle pathForResource:@"cacert" ofType:@"pem"];
    code = curl_easy_setopt(curl, CURLOPT_CAINFO, [caPath UTF8String]);
    ZLog(@"CURLOPT_CAINFO status: %u", code);
    
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
    ZLog(@"CURLOPT_SSL_VERIFYPEER status: %u", code);
    
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2L);
    ZLog(@"CURLOPT_SSL_VERIFYHOST status: %u", code);
    
    // Certificate
    code = curl_easy_setopt(curl, CURLOPT_CERTINFO, 1L);
    ZLog(@"CURLOPT_CERTINFO status: %u", code);

    // Cookies
    code = curl_easy_setopt(curl, CURLOPT_COOKIEFILE, "");
    ZLog(@"CURLOPT_COOKIEFILE status: %u", code);
    
    
    // delegate: - (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url;
    if ([self.delegate respondsToSelector:@selector(curl:willPerformWithURL:)]) {
        [self.delegate curl:curl willPerformWithURL:url];
    }
    
    // perform
    code = curl_easy_perform(curl);
    ZLog(@"perform status: %u", code);
    
    NSDictionary *info = [self infoForCURL:curl];
    ZLog(@"curl info:\n%@", info);
    // delegate: - (void)curl:(CURL *)curl didPerformWithURL:(NSURL *)url info:(NSDictionary *)info;
    if ([self.delegate respondsToSelector:@selector(curl:didPerformWithURL:info:)]) {
        [self.delegate curl:curl didPerformWithURL:url info:info];
    }
    
    curl_easy_cleanup(curl);
}

- (NSDictionary *)infoForCURL:(CURL *)curl {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    CURLcode code;
    
    // 1
    char *url_effective;
    code = curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_URL, &url_effective);
    ZLog(@"CURLINFO_EFFECTIVE_URL status: %u", code);
    if (url_effective == NULL) {
        url_effective = "";
    }
    [info setValue:@(url_effective) forKey:@"url_effective"];
    
    // 2
    long response_code;
    code = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
    ZLog(@"CURLINFO_RESPONSE_CODE status: %u", code);
    [info setValue:@(response_code) forKey:@"response_code"];
    
    // 3
    double time_total;
    code = curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &time_total);
    ZLog(@"CURLINFO_TOTAL_TIME status: %u", code);
    [info setValue:@(time_total) forKey:@"time_total"];

    // 4
    double time_namelookup;
    code = curl_easy_getinfo(curl, CURLINFO_NAMELOOKUP_TIME, &time_namelookup);
    ZLog(@"CURLINFO_NAMELOOKUP_TIME status: %u", code);
    [info setValue:@(time_namelookup) forKey:@"time_namelookup"];

    // 5
    double time_connect;
    code = curl_easy_getinfo(curl, CURLINFO_CONNECT_TIME, &time_connect);
    ZLog(@"CURLINFO_CONNECT_TIME status: %u", code);
    [info setValue:@(time_connect) forKey:@"time_connect"];

    // 6
    double time_pretransfer;
    code = curl_easy_getinfo(curl, CURLINFO_PRETRANSFER_TIME, &time_pretransfer);
    ZLog(@"CURLINFO_PRETRANSFER_TIME status: %u", code);
    [info setValue:@(time_pretransfer) forKey:@"time_pretransfer"];

    // 7
    double size_upload;
    code = curl_easy_getinfo(curl, CURLINFO_SIZE_UPLOAD, &size_upload);
    ZLog(@"CURLINFO_SIZE_UPLOAD status: %u", code);
    [info setValue:@(size_upload) forKey:@"size_upload"];

    // 8
    double size_download;
    code = curl_easy_getinfo(curl, CURLINFO_SIZE_DOWNLOAD, &size_download);
    ZLog(@"CURLINFO_SIZE_DOWNLOAD status: %u", code);
    [info setValue:@(size_download) forKey:@"size_download"];

    // 9
    double speed_download;
    code = curl_easy_getinfo(curl, CURLINFO_SPEED_DOWNLOAD, &speed_download);
    ZLog(@"CURLINFO_SPEED_DOWNLOAD status: %u", code);
    [info setValue:@(speed_download) forKey:@"speed_download"];

    // 10
    double speed_upload;
    code = curl_easy_getinfo(curl, CURLINFO_SPEED_UPLOAD, &speed_upload);
    ZLog(@"CURLINFO_SPEED_UPLOAD status: %u", code);
    [info setValue:@(speed_upload) forKey:@"speed_upload"];

    // 11
    long size_header;
    code = curl_easy_getinfo(curl, CURLINFO_HEADER_SIZE, &size_header);
    ZLog(@"CURLINFO_HEADER_SIZE status: %u", code);
    [info setValue:@(size_header) forKey:@"size_header"];

    // 12
    long size_request;
    code = curl_easy_getinfo(curl, CURLINFO_REQUEST_SIZE, &size_request);
    ZLog(@"CURLINFO_REQUEST_SIZE status: %u", code);
    [info setValue:@(size_request) forKey:@"size_request"];

    // 13
    long ssl_verify_result;
    code = curl_easy_getinfo(curl, CURLINFO_SSL_VERIFYRESULT, &ssl_verify_result);
    ZLog(@"CURLINFO_SSL_VERIFYRESULT status: %u", code);
    [info setValue:@(ssl_verify_result) forKey:@"ssl_verify_result"];

    // 14
    long time_file;
    code = curl_easy_getinfo(curl, CURLINFO_FILETIME, &time_file);
    ZLog(@"CURLINFO_FILETIME status: %u", code);
    [info setValue:@(time_file) forKey:@"time_file"];

    // 15
    double length_content_download;
    code = curl_easy_getinfo(curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &length_content_download);
    ZLog(@"CURLINFO_CONTENT_LENGTH_DOWNLOAD status: %u", code);
    [info setValue:@(length_content_download) forKey:@"length_content_download"];

    // 16
    double length_content_upload;
    code = curl_easy_getinfo(curl, CURLINFO_CONTENT_LENGTH_UPLOAD, &length_content_upload);
    ZLog(@"CURLINFO_CONTENT_LENGTH_UPLOAD status: %u", code);
    [info setValue:@(length_content_upload) forKey:@"length_content_upload"];

    // 17
    double time_starttransfer;
    code = curl_easy_getinfo(curl, CURLINFO_STARTTRANSFER_TIME, &time_starttransfer);
    ZLog(@"CURLINFO_STARTTRANSFER_TIME status: %u", code);
    [info setValue:@(time_starttransfer) forKey:@"time_starttransfer"];

    // 18
    char *content_type;
    code = curl_easy_getinfo(curl, CURLINFO_CONTENT_TYPE, &content_type);
    ZLog(@"CURLINFO_CONTENT_TYPE status: %u", code);
    if (content_type == NULL) {
        content_type = "";
    }
    [info setValue:@(content_type) forKey:@"content_type"];

    // 19
    double time_redirect;
    code = curl_easy_getinfo(curl, CURLINFO_REDIRECT_TIME, &time_redirect);
    ZLog(@"CURLINFO_REDIRECT_TIME status: %u", code);
    [info setValue:@(time_redirect) forKey:@"time_redirect"];

    // 20
    long num_redirects;
    code = curl_easy_getinfo(curl, CURLINFO_REDIRECT_COUNT, &num_redirects);
    ZLog(@"CURLINFO_REDIRECT_COUNT status: %u", code);
    [info setValue:@(num_redirects) forKey:@"num_redirects"];

    // 21 CURLINFO_PRIVATE

    // 22
    long http_connect;
    code = curl_easy_getinfo(curl, CURLINFO_HTTP_CONNECTCODE, &http_connect);
    ZLog(@"CURLINFO_RESPONSE_CODE status: %u", code);
    [info setValue:@(http_connect) forKey:@"http_connect"];

    // 23
    long http_auth;
    code = curl_easy_getinfo(curl, CURLINFO_HTTPAUTH_AVAIL, &http_auth);
    ZLog(@"CURLINFO_HTTPAUTH_AVAIL status: %u", code);
    [info setValue:@(http_auth) forKey:@"http_auth"];

    // 24
    long proxy_auth;
    code = curl_easy_getinfo(curl, CURLINFO_PROXYAUTH_AVAIL, &proxy_auth);
    ZLog(@"CURLINFO_PROXYAUTH_AVAIL status: %u", code);
    [info setValue:@(proxy_auth) forKey:@"proxy_auth"];

    // 25
    long error_code;
    code = curl_easy_getinfo(curl, CURLINFO_OS_ERRNO, &error_code);
    ZLog(@"CURLINFO_OS_ERRNO status: %u", code);
    [info setValue:@(error_code) forKey:@"error_code"];

    // 26
    long num_connects;
    code = curl_easy_getinfo(curl, CURLINFO_NUM_CONNECTS, &num_connects);
    ZLog(@"CURLINFO_NUM_CONNECTS status: %u", code);
    [info setValue:@(num_connects) forKey:@"num_connects"];

    // 27
    struct curl_slist *engines;
    code = curl_easy_getinfo(curl, CURLINFO_SSL_ENGINES, &engines);
    ZLog(@"CURLINFO_SSL_ENGINES status: %u", code);
    if((code == CURLE_OK) && engines) {
        struct curl_slist *targetEngine = engines;
        NSMutableString *ssl_engines = [NSMutableString string];
        [ssl_engines stringByAppendingString:@(targetEngine->data)];
        while (targetEngine->next != NULL) {
            targetEngine = targetEngine->next;
            if (targetEngine->data) {
                [ssl_engines stringByAppendingString:@";"];
                [ssl_engines stringByAppendingString:@(targetEngine->data)];
            }
        }
        [info setValue:ssl_engines forKey:@"ssl_engines"];
        curl_slist_free_all(engines);
    }

    // 28
    struct curl_slist *cookie_list;
    code = curl_easy_getinfo(curl, CURLINFO_COOKIELIST, &cookie_list);
    ZLog(@"CURLINFO_COOKIELIST status: %u", code);
    if((code == CURLE_OK) && cookie_list) {
        struct curl_slist *targetCookie = cookie_list;
        NSMutableString *cookies = [NSMutableString string];
        [cookies appendString:@(targetCookie->data)];
        while (targetCookie->next != NULL) {
            targetCookie = targetCookie->next;
            if (targetCookie->data) {
                [cookies stringByAppendingString:@";"];
                [cookies stringByAppendingString:@(targetCookie->data)];
            }
        }
        [info setValue:cookies forKey:@"cookies"];
        curl_slist_free_all(cookie_list);
    }

    // 29
    long socket_last;
    code = curl_easy_getinfo(curl, CURLINFO_LASTSOCKET, &socket_last);
    ZLog(@"CURLINFO_LASTSOCKET status: %u", code);
    [info setValue:@(socket_last) forKey:@"socket_last"];

    // 30
    char *ftp_entry_path;
    code = curl_easy_getinfo(curl, CURLINFO_FTP_ENTRY_PATH, &ftp_entry_path);
    ZLog(@"CURLINFO_FTP_ENTRY_PATH status: %u", code);
    if (ftp_entry_path == NULL) {
        ftp_entry_path = "";
    }
    [info setValue:@(ftp_entry_path) forKey:@"ftp_entry_path"];

    // 31
    char *redirect_url;
    code = curl_easy_getinfo(curl, CURLINFO_REDIRECT_URL, &redirect_url);
    ZLog(@"CURLINFO_REDIRECT_URL status: %u", code);
    if (redirect_url == NULL) {
        redirect_url = "";
    }
    [info setValue:@(redirect_url) forKey:@"redirect_url"];

    // 32
    char *remote_ip;
    code = curl_easy_getinfo(curl, CURLINFO_PRIMARY_IP, &remote_ip);
    ZLog(@"CURLINFO_PRIMARY_IP status: %u", code);
    if (remote_ip == NULL) {
        remote_ip = "";
    }
    [info setValue:@(remote_ip) forKey:@"remote_ip"];

    // 33
    double time_appconnect;
    code = curl_easy_getinfo(curl, CURLINFO_APPCONNECT_TIME, &time_appconnect);
    ZLog(@"CURLINFO_APPCONNECT_TIME status: %u", code);
    [info setValue:@(time_appconnect) forKey:@"time_appconnect"];

    // 34
    struct curl_certinfo *cert_info;
    code = curl_easy_getinfo(curl, CURLINFO_CERTINFO, &cert_info);
    ZLog(@"CURLINFO_CERTINFO status: %u", code);
    if((code == CURLE_OK) && cert_info) {
        NSMutableDictionary *certInfo = [NSMutableDictionary dictionary];
        [certInfo setValue:@(cert_info->num_of_certs) forKey:@"num_of_certs"];
        for(int i = 0; i < cert_info->num_of_certs; i++) {
            struct curl_slist *cert_info_list;
            NSMutableArray *certs = [NSMutableArray array];
            for(cert_info_list = cert_info->certinfo[i]; cert_info_list; cert_info_list = cert_info_list->next) {
                if (cert_info_list->data) {
                    [certs addObject:@(cert_info_list->data)];
                }
            }
            [certInfo setValue:certs forKey:[NSString stringWithFormat:@"%d", i]];
        }
        [info setValue:certInfo forKey:@"cert_info"];
    }

    // 35
    long condition_unmet;
    code = curl_easy_getinfo(curl, CURLINFO_CONDITION_UNMET, &condition_unmet);
    ZLog(@"CURLINFO_CONDITION_UNMET status: %u", code);
    [info setValue:@(condition_unmet) forKey:@"condition_unmet"];

    // 36
    char *rtsp_session_id;
    code = curl_easy_getinfo(curl, CURLINFO_RTSP_SESSION_ID, &rtsp_session_id);
    ZLog(@"CURLINFO_RTSP_SESSION_ID status: %u", code);
    if (rtsp_session_id == NULL) {
        rtsp_session_id = "";
    }
    [info setValue:@(rtsp_session_id) forKey:@"rtsp_session_id"];

    // 37
    long rtsp_client_cseq;
    code = curl_easy_getinfo(curl, CURLINFO_RTSP_CLIENT_CSEQ, &rtsp_client_cseq);
    ZLog(@"CURLINFO_RTSP_CLIENT_CSEQ status: %u", code);
    [info setValue:@(rtsp_client_cseq) forKey:@"rtsp_client_cseq"];

    // 38
    long rtsp_server_cseq;
    code = curl_easy_getinfo(curl, CURLINFO_RTSP_SERVER_CSEQ, &rtsp_server_cseq);
    ZLog(@"CURLINFO_RTSP_SERVER_CSEQ status: %u", code);
    [info setValue:@(rtsp_server_cseq) forKey:@"rtsp_server_cseq"];

    // 39
    long rtsp_cseq_recv;
    code = curl_easy_getinfo(curl, CURLINFO_RTSP_CSEQ_RECV, &rtsp_cseq_recv);
    ZLog(@"CURLINFO_RTSP_CSEQ_RECV status: %u", code);
    [info setValue:@(rtsp_cseq_recv) forKey:@"rtsp_cseq_recv"];

    // 40
    long remote_port;
    code = curl_easy_getinfo(curl, CURLINFO_PRIMARY_PORT, &remote_port);
    ZLog(@"CURLINFO_PRIMARY_PORT status: %u", code);
    [info setValue:@(remote_port) forKey:@"remote_port"];

    // 41
    char *local_ip;
    code = curl_easy_getinfo(curl, CURLINFO_LOCAL_IP, &local_ip);
    ZLog(@"CURLINFO_LOCAL_IP status: %u", code);
    if (local_ip == NULL) {
        local_ip = "";
    }
    [info setValue:@(local_ip) forKey:@"local_ip"];

    // 42
    long local_port;
    code = curl_easy_getinfo(curl, CURLINFO_LOCAL_PORT, &local_port);
    ZLog(@"CURLINFO_LOCAL_PORT status: %u", code);
    [info setValue:@(local_port) forKey:@"local_port"];

    // 43 CURLINFO_TLS_SESSION, use CURLINFO_TLS_SSL_PTR instead

    // 44 CURLINFO_ACTIVESOCKET, useless active socket

    // 45 CURLINFO_TLS_SSL_PTR, use for callback

    // 46
    long http_version;
    code = curl_easy_getinfo(curl, CURLINFO_HTTP_VERSION, &http_version);
    ZLog(@"CURLINFO_HTTP_VERSION status: %u", code);
    [info setValue:@(http_version) forKey:@"http_version"];

    // 47
    long proxy_ssl_verify_result;
    code = curl_easy_getinfo(curl, CURLINFO_PROXY_SSL_VERIFYRESULT, &proxy_ssl_verify_result);
    ZLog(@"CURLINFO_PROXY_SSL_VERIFYRESULT status: %u", code);
    [info setValue:@(proxy_ssl_verify_result) forKey:@"proxy_ssl_verify_result"];

    // 48
    long protocol;
    code = curl_easy_getinfo(curl, CURLINFO_PROTOCOL, &protocol);
    ZLog(@"CURLINFO_PROTOCOL status: %u", code);
    [info setValue:@(protocol) forKey:@"protocol"];

    // 49
    char *scheme;
    code = curl_easy_getinfo(curl, CURLINFO_SCHEME, &scheme);
    ZLog(@"CURLINFO_SCHEME status: %u", code);
    if (scheme == NULL) {
        scheme = "";
    }
    [info setValue:@(scheme) forKey:@"scheme"];

    // 50 CURLINFO_TOTAL_TIME_T

    // 51 CURLINFO_NAMELOOKUP_TIME_T

    // 52 CURLINFO_CONNECT_TIME_T

    // 53 CURLINFO_PRETRANSFER_TIME_T
    
    // 54 CURLINFO_STARTTRANSFER_TIME_T

    // 55 CURLINFO_REDIRECT_TIME_T

    // 56 CURLINFO_APPCONNECT_TIME_T

    // 57 CURLINFO_RETRY_AFTER

    // 58
    char *method;
    code = curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_METHOD, &method);
    ZLog(@"CURLINFO_EFFECTIVE_METHOD status: %u", code);
    if (method == NULL) {
        method = "";
    }
    [info setValue:@(method) forKey:@"method"];

    // 59
    long proxy_error;
    code = curl_easy_getinfo(curl, CURLINFO_PROXY_ERROR, &proxy_error);
    ZLog(@"CURLINFO_PROXY_ERROR status: %u", code);
    [info setValue:@(proxy_error) forKey:@"proxy_error"];

    // 60
    char *referer;
    code = curl_easy_getinfo(curl, CURLINFO_REFERER, &referer);
    ZLog(@"CURLINFO_REFERER status: %u", code);
    if (referer == NULL) {
        referer = "";
    }
    [info setValue:@(referer) forKey:@"referer"];
    
    return info;
}

@end
