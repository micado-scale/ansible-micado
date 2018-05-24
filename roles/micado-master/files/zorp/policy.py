from  Zorp.Core import  *
from  Zorp.Proxy import  *
from  Zorp.Http import  *
from  Zorp.Auth import  *
from  Zorp.AuthDB import *
from  Zorp.FileLock import *
from  Zorp.Cache import *
import socket
import base64

Zorp.firewall_name = 'zorp@micado-master'
config.options.kzorp_enabled = FALSE

Zone(name='internet',
     addrs=[
     '0.0.0.0/0',
]
)

EncryptionPolicy(
    name="https_clientonly_encryption_policy",
    encryption=ClientOnlyEncryption(
        client_verify=ClientNoneVerifier(),
        client_ssl_options=ClientSSLOptions(
            method=SSL_METHOD_ALL,
            cipher="ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:!aNULL:!MD5:!DSS",
            cipher_server_preference=FALSE,
            timeout=300,
            disable_sslv2=TRUE,
            disable_sslv3=TRUE,
            disable_tlsv1=TRUE,
            disable_tlsv1_1=TRUE,
            disable_tlsv1_2=FALSE,
            disable_compression=FALSE
        ),
        client_certificate_generator=StaticCertificate(
            certificate=Certificate.fromFile(
                certificate_file_path="/etc/zorp/ssl.pem",
                private_key=PrivateKey.fromFile("/etc/zorp/ssl.key")
            )
        )
    )
)

class MicadoMasterHttpProxy(HttpProxy):
    def __pre_config__(self):
        self.urlmapping = {}
        return super(MicadoMasterHttpProxy, self).__pre_config__()

    def config(self):
        super(MicadoMasterHttpProxy, self).config()
        self.rewrite_host_header = FALSE
        self.max_keepalive_requests = 1
        self.error_silent = TRUE
        self.request["GET"] = (HTTP_REQ_POLICY, self.reqRedirect)
        self.request["POST"] = (HTTP_REQ_POLICY, self.reqRedirect)
        self.request["PUT"] = (HTTP_REQ_POLICY, self.reqRedirect)
        self.response_header["Strict-Transport-Security"] = (HTTP_HDR_REPLACE, "max-age=63072000; includeSubdomains;")
        self.urlmapping["/prometheus"] = ("prometheus", 9090, False)
        self.urlmapping["/alertmanager"] = ("alertmanager", 9093, True)
        self.urlmapping["/docker-visualizer"] = ("dockervisualizer", 8080, False)
        self.urlmapping["/grafana"] = ("grafana", 3000, True)
        self.urlmapping["/dashboard"] = ("micado-dashboard", 4000, True)
        self.urlmapping["/toscasubmitter"] = ("toscasubmitter", 5050, True)

    def reqRedirect(self, method, url, version):
        proxyLog(self, HTTP_POLICY, 3, "Got URL %s", (url,))
        if url.startswith("http://"):
            self.error_status = 301
            self.error_headers="Location: %s\n" % url.replace("http://", "https://")
            return HTTP_REQ_REJECT
        return HTTP_REQ_ACCEPT

    def setServerAddress(self, host, port):
        for path in self.urlmapping.keys():
            if self.request_url_file.startswith(path):
                (container, port, remove_prefix_on_server_side) = self.urlmapping[path]
                proxyLog(self, HTTP_POLICY, 3, "Mapping url; path='%s', container='%s', port='%s'", (path, container, port))
                self.setRequestHeader("Host", container+":"+str(port))
                if remove_prefix_on_server_side:
                    import urlparse
                    newpath = self.request_url_file[len(path)+1:]
                    if newpath == "":
                        newpath = "/"
                    self.request_url = urlparse.urlunsplit((self.request_url_proto, self.request_url_host+":"+str(port), newpath, self.request_url_query, None))
                    proxyLog(self, HTTP_POLICY, 3, "Mapping to new url; url='%s'", (self.request_url))
                return HttpProxy.setServerAddress(self, socket.gethostbyname(container), port)
        return HttpProxy.setServerAddress(self, socket.gethostbyname("micado-dashboard"), 4000)

def default() :
    Service(name='interHTTPS', router=DirectedRouter(dest_addr=(SockAddrInet('127.0.0.1', 4000)), overrideable=TRUE), chainer=ConnectChainer(), proxy_class=MicadoMasterHttpProxy, max_instances=0, max_sessions=0, keepalive=Z_KEEPALIVE_NONE, encryption_policy="https_clientonly_encryption_policy")
    Dispatcher(transparent=FALSE, bindto=DBIface(protocol=ZD_PROTO_TCP, port=443, iface="eth0", family=2), rule_port="443", service="interHTTPS")
    Service(name='interHTTP', router=DirectedRouter(dest_addr=(SockAddrInet('127.0.0.1', 80),)), chainer=ConnectChainer(), proxy_class=MicadoMasterHttpProxy, max_instances=0, max_sessions=0, keepalive=Z_KEEPALIVE_NONE)
    Dispatcher(transparent=FALSE, bindto=DBIface(protocol=ZD_PROTO_TCP, port=80, iface="eth0", family=2), rule_port="80", service="interHTTP")
