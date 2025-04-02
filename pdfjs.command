# macOS上使用，其他系统使用需要把后缀改为.py
# 可以用来下载智慧中小学等使用pdfjs浏览的PDF源文件，如何获取pdfjs链接可以看blog
# 作者：wolfydw
# 最后修改时间：2024-11-15

#!/usr/bin/env python

import urllib.parse
import json
import requests
import os

def parse_pdfjs_link(preview_url):
    # 解析URL
    parsed_url = urllib.parse.urlparse(preview_url)
    query_params = urllib.parse.parse_qs(parsed_url.query)

    # 提取文件URL和headers参数
    file_url = query_params.get("file", [None])[0]
    headers_param = query_params.get("headers", [None])[0]

    if not file_url or not headers_param:
        print("无法解析链接中的文件URL或Headers参数，请检查输入的链接是否正确。")
        return None, None, None

    # 解码headers参数
    headers_json_str = urllib.parse.unquote(headers_param)
    headers = json.loads(headers_json_str)

    # 获取文件名
    file_name = os.path.basename(urllib.parse.unquote(file_url))
    
    return file_url, headers, file_name

def download_pdf(file_url, headers, file_name):
    # 获取桌面路径
    desktop_path = os.path.join(os.path.expanduser("~"), "Desktop")
    file_path = os.path.join(desktop_path, file_name)

    # 下载PDF文件
    response = requests.get(file_url, headers=headers)

    if response.status_code == 200:
        with open(file_path, "wb") as f:
            f.write(response.content)
        print(f"PDF下载成功，文件保存路径为: {file_path}")
    else:
        print(f"请求失败，状态码: {response.status_code}")

def main():
    preview_url = input("请输入pdf.js预览链接: ")
    file_url, headers, file_name = parse_pdfjs_link(preview_url)

    if file_url and headers:
        download_pdf(file_url, headers, file_name)

if __name__ == "__main__":
    main()
