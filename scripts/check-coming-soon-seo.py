"""Audit both introductions locally or with --live against their canonical sites."""
import sys
import struct
from pathlib import Path
from html.parser import HTMLParser
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from xml.etree import ElementTree as ET

class Page(HTMLParser):
    def __init__(self):
        super().__init__(); self.meta={}; self.links={}; self.h1=0; self.website=False; self.items={}; self.title=''; self.in_title=False
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if tag=='meta':
            self.meta[a.get('name',a.get('property',''))]=a.get('content','')
        if tag=='link': self.links[a.get('rel','')]=a.get('href','')
        if 'itemprop' in a: self.items[a['itemprop']]=a.get('content',a.get('href',''))
        if a.get('itemtype')=='https://schema.org/WebSite': self.website=True
        if tag=='h1': self.h1+=1
        if tag=='title': self.in_title=True
    def handle_endtag(self,tag):
        if tag=='title': self.in_title=False
    def handle_data(self,data):
        if self.in_title: self.title+=data

root=Path(__file__).resolve().parents[1]/'site'
live='--live' in sys.argv
for slug,domain in [('yaqeen','yaqeen-w.tech'),('afrimed','health.afrimed.space')]:
    base=f'https://{domain}/'
    def read(path):
        if not live: return (root/slug/path).read_bytes()
        with urlopen(Request(base+(path if path!='index.html' else ''),headers={'User-Agent':'Googlebot'}),timeout=30) as r:
            assert r.status==200
            assert 'noindex' not in r.headers.get('X-Robots-Tag','').lower()
            return r.read()
    page=Page();page.feed(read('index.html').decode())
    assert page.h1==1 and 30<=len(page.title)<=70, domain
    assert 90<=len(page.meta['description'])<=165
    assert page.links['canonical']==base
    assert 'noindex' not in page.meta['robots'] and 'index' in page.meta['robots']
    for key in ['og:title','og:description','og:site_name','og:image','og:image:alt','twitter:card','twitter:title','twitter:description','twitter:image']:
        assert page.meta.get(key), (domain,key)
    assert page.meta['og:url']==base
    assert page.meta['og:image']==page.meta['twitter:image']==base+'social-preview.png'
    assert page.website and page.items['url']==base and page.items['name']
    png=read('social-preview.png'); assert png[:8]==b'\x89PNG\r\n\x1a\n'
    assert struct.unpack('>II',png[16:24])==(1200,630)
    robots=read('robots.txt').decode();assert f'Sitemap: {base}sitemap.xml' in robots and 'Disallow: /' not in robots
    tree=ET.fromstring(read('sitemap.xml')); assert [n.text for n in tree.iter() if n.tag.endswith('}loc')]==[base]
    if live:
        with urlopen(base+'index.html',timeout=30) as r: assert r.url==base
        try:
            urlopen(base+'missing-page-seo-check',timeout=30)
            raise AssertionError('Missing page must return 404')
        except HTTPError as error:
            assert error.code==404
    print(f'PASS {domain}: metadata, canonical, WebSite, robots, sitemap, share image')
