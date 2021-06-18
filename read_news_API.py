### Google news API ###

# 參考資料：
# https://newsapi.org/s/taiwan-business-news-api
# https://medium.com/ccclub/ccclub-python-for-beginners-tutorial-533b8d8d96f3

import requests

api_key = 'use your api key'
url = ('https://newsapi.org/v2/top-headlines?'
       'country=tw&category=business&'
       'apiKey=' + api_key)

response = requests.get(url)
response.json().keys()

total_result = response.json()['totalResults']
articles = response.json()['articles']

contents = ''
for i in articles:
    if type(i['description']) == str:
        contents += i['description']

# 去除標點符號
punctuation = '＂＃＄％＆＇（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｟｠｢｣､\、〃〈〉《》「」『』【】〔〕〖〗〘〙〚〛〜〝〞〟〰()｜|–—‘’‛“”„‟…‧﹏﹑﹔·！？｡。'

for i in punctuation:
    contents = contents.replace(i, ' ')
