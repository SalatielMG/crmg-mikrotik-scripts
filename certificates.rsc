# CERTIFICATE 1

certificate add name=CRMG-CA common-name=CRMG-CA key-size=2048 key-usage=crl-sign,key-cert-sign days-valid=3650

certificate sign CRMG-CA ca-crl-host=127.0.0.1

certificate/add name=CRMG-HTTPS common-name=CRMG-HTTPS key-size=2048 days-valid=3650

certificate sign CRMG-HTTPS ca=CRMG-CA

/ip service set www-ssl certificate=CRMG-HTTPS disabled=no

# CERTIFICATE 2

certificate add name=CRMG-CA-2 common-name=CRMG-CA-2 subject-alt-name="IP:192.168.7.78" key-size=2048 key-usage=crl-sign,key-cert-sign days-valid=3650

certificate sign CRMG-CA-2 ca-crl-host=127.0.0.1
# TODO: Pending Mark Trusted ceritified

certificate/add name=CRMG-HTTPS-2 common-name=CRMG-HTTPS-2 subject-alt-name="IP:192.168.7.78" key-size=2048 days-valid=3650

certificate sign CRMG-HTTPS-2 ca=CRMG-CA-2

/ip service set www-ssl certificate=CRMG-HTTPS-2 disabled=no