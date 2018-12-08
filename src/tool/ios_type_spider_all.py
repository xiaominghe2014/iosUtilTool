#!/usr/bin/python3
# -*- coding: UTF-8 -*-

"""
@version: ??
@author: ximena
@license: MIT Licence
@contact: xiaominghe2014@gmail.com
@file: ios_type_spider
@time: 2018/10/9
    
"""
import os
import re
import json
import datetime
from lxml import etree
from selenium import webdriver


search_url = 'https://www.theiphonewiki.com/wiki/Models'
current_dir = os.path.dirname(os.path.realpath(__file__))


class IOSTypeSpider(object):
    
    def __init__(self):
        super().__init__()
    
    @staticmethod
    def get(url):
        browser = webdriver.Chrome()
        browser.get(url)
        text = browser.page_source
        browser.close()
        return text
    
    @staticmethod
    def parse_response(resp):
        ios_map = {}
        try:
            text = resp
            tree = etree.HTML(text)
            iphone_type = tree.xpath("//table[@class='wikitable']/tbody")
            valid_str = ''
            for v in iphone_type:
                print("======================table===========================")
                str_v = etree.tostring(v).decode()
                valid_str = '{}\n{}'.format(valid_str, str_v)
                tr = v.findall('tr')
                des_type = ''
                for e in tr:
                    generation = ''
                    td = e.findall('td')
                    if len(td):
                        index = 0
                        for t in td:
                            if 0 == index and len(t.findall('a')):
                                if '' == generation:
                                    des = t.findall('a')[0].text
                                    if IOSTypeSpider.is_ios_des(des):
                                        generation = des
                                        des_type = generation
                            if t.text:
                                if 0 == index and '' == generation:
                                    des = t.text
                                    if IOSTypeSpider.is_ios_des(des):
                                        generation = des
                                        des_type = generation
                                else:
                                    if t.text.find(',') != -1:
                                        if t.text.find(' ') == -1:
                                            internal = t.text
                                            print(internal.strip(), '<====>', des_type.strip())
                                            ios_map.setdefault(internal.strip(), des_type.strip())
                            index += 1
        except Exception as e:
            print(e)
        IOSTypeSpider.write_string(str(json.dumps(ios_map,
                                                  ensure_ascii=False,
                                                  sort_keys=False,
                                                  indent=4,
                                                  separators=(',', ':'))))
        return ios_map

    @staticmethod
    def replace_old_code(new_code):
        old_m = '{}/{}'.format(current_dir, "DeviceUtils.m")
        with open(old_m, 'r+', encoding='utf-8') as m:
            old_code = m.read()
            pattern = r'@\{(.*)\};'
            old_iphone_map = re.findall(pattern, old_code, re.DOTALL)
            old = old_iphone_map[0]
            new_code = old_code.replace(old, new_code)
        with open(old_m, 'w+', encoding='utf-8') as m:
            m.write(new_code)

    @staticmethod
    def generator_new_code(iphone_map):
        start_tag = '\n'
        begin_tag = '\t'*12
        per_code = '{}{}'.format(start_tag, begin_tag)
        new_code = '{}'.format(per_code)
        for k, v in iphone_map.items():
            tmp = '@"{}":@"{}",{}'.format(k, v, per_code)
            new_code = '{}{}'.format(new_code, tmp)
        return new_code
    
    @staticmethod
    def spider(url):
        resp = IOSTypeSpider.get(url)
        IOSTypeSpider.parse_response(resp)
        # new_code = IOSTypeSpider.generator_new_code(iphone_map)
        # IOSTypeSpider.replace_old_code(new_code)
    
    @staticmethod
    def write_string(text):
        with open('{}/{}'.format(current_dir, 'ios_device.json'), 'w+', encoding='utf-8') as f:
            f.write(text)
        time_code = '//generated spider in {}{}'.format(
            datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            '\n')
        ios_device_des_h = 'ios_device_des.h'
        code = text.replace('"', '\\"')
        code = code.replace('\n    ', '\\\n\t').replace('\n}', '\\\n}')
        code = '#import <Foundation/Foundation.h> \n' \
               'const NSString* IOS_DES = @"{}";'.format(code)
        des = '{}//  Copyright © ximena. All rights reserved.\n\n\n' \
              '#ifndef ios_device_des_h\n' \
              '#define ios_device_des_h \n' \
              '{}\n' \
              '#endif /* ios_device_des_h */\n'.format(time_code, code)
        with open('{}/{}'.format(current_dir, ios_device_des_h), 'w+', encoding='utf-8') as h:
            h.write(des)

    @staticmethod
    def is_ios_des(des):
        des_arr = ['AirPods', 'TV', 'Watch', 'HomePod', 'iPad', 'iPhone', 'iPod']
        for v in des_arr:
            if v in des:
                return True
        return False


def main():
    IOSTypeSpider.spider(search_url)


if __name__ == '__main__':
    main()
