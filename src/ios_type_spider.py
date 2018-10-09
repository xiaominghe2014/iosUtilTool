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
import requests
from lxml import etree

search_url = 'https://www.theiphonewiki.com/wiki/List_of_iPhones'
headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) '
                         'AppleWebKit/537.36 (KHTML, like Gecko) '
                         'Chrome/63.0.3239.84 Safari/537.36'}
current_dir = os.path.dirname(os.path.realpath(__file__))


class IOSTypeSpider(object):

    def __init__(self):
        super().__init__()

    @staticmethod
    def get(url, char_set='utf-8'):
        session = requests.session()
        resp = session.get(url, headers=headers, stream=True, verify=False)
        resp.encoding = char_set
        return resp

    @staticmethod
    def parse_response(resp):
        try:
            text = resp.text
            tree = etree.HTML(text)
            iphone_type = tree.xpath("//span[@class='toctext']/text()")
            pattern = r'<li>\s*Internal Name\s*:\s*(.*)\s*</li>'
            internal_names = re.findall(pattern, text)
            total = min(len(iphone_type), len(internal_names))
            iphone_map = {}
            for x in range(total):
                iphone_map.setdefault(internal_names[x], iphone_type[x])
            for k, v in iphone_map.items():
                print(k, "<====>", v)
            return iphone_map
        except Exception as e:
            print(e)

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
        iphone_map = IOSTypeSpider.parse_response(resp)
        new_code = IOSTypeSpider.generator_new_code(iphone_map)
        IOSTypeSpider.replace_old_code(new_code)


def main():
    IOSTypeSpider.spider(search_url)


if __name__ == '__main__':
    main()
