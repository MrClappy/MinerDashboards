#!/usr/bin/python3

import requests
from xml.etree import ElementTree

def get_power(ip_and_port):
    headers = {'Content-type': 'text/xml', 'SOAPACTION': '"urn:Belkin:service:insight:1#GetPower"'}
    payload = '''<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
                             s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                  <s:Body>
                   <u:GetPower xmlns:u="urn:Belkin:service:insight:1"/>
                  </s:Body>
                 </s:Envelope>'''
    r = requests.post("http://%s/upnp/control/insight1" % ip_and_port, headers=headers, data=payload)
    et = ElementTree.fromstring(r.text)
    return et.find('.//InstantPower').text
