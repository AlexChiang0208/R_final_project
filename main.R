# 需先在 R.md 用 python 讀取 contents
contents = py$contents

### 文字雲 ###
# 步驟一：分詞－知道是一個中文的詞
# 步驟二：統計詞語出現的次數
# 步驟三：刪掉頻率太少的詞
# 步驟四：使用文字雲套件繪圖

library(jiebaR) # 中文分詞套件
library(wordcloud2) # 文字雲套件

# 中文分詞
jiebaR_worker = jiebaR::worker()
title_segment = jiebaR_worker[contents]

# 停用詞過濾函數：filter_segment
filter = c('ST', '1.8', '14')
title_segment = jiebaR::filter_segment(title_segment, filter)

# 利用 table() 做次數分配表
title_table = table(title_segment)
title_table = data.frame(title_table)

# 出現次數排序
title_order_table = title_table[order(title_table$Freq, decreasing=TRUE),]

# 計算詞的字數
title_nchar = nchar(as.character(title_order_table$title_segment))

# 刪除『字數』等於 1 的詞
title_order_table = title_order_table[title_nchar > 1,]

# 只保留出現『頻率』 >= 2 的詞
title_order_table = title_order_table[title_order_table$Freq >= 2,]

# 繪製文字雲
cloud1 = wordcloud2::wordcloud2(title_order_table)
cloud1



### Google Trends 搜尋熱度的趨勢變化 ###
library(gtrendsR)

# 查詢關鍵字－文字雲出現最多次的前三名
keyword = c("報導", "美國", "庫藏")

# 查詢國家
geo = "TW"

# 查詢範圍：web, news, images, froogle, youtube
gprop = "news"

# 查詢時間
start_date = "2021-01-01"
end_date = "2021-06-18"
time = paste(start_date, end_date)

# 只回傳時間序列資料
onlyInterest = FALSE

# 開始查詢
trends = gtrendsR::gtrends(keyword=keyword, 
                           geo=geo, 
                           gprop=gprop,
                           time=time,
                           onlyInterest=onlyInterest)

# 查詢結果
interest_over_time = trends$interest_over_time

# 調整資料格式
interest_over_time$hits[interest_over_time$hits == "<1"] = 0
interest_over_time$hits = as.numeric(interest_over_time$hits)

# 繪製折線圖
library(dygraphs)
library(xts)
data = data.frame(time=interest_over_time$date, 
                  hits=interest_over_time$hits,
                  keyword=interest_over_time$keyword)

data_df = reshape2::dcast(data, time ~ keyword, value.var="hits")
data_xts = xts(x=data_df, order.by=data_df$time)
data_xts$time = NULL
fig_dygraph = dygraphs::dygraph(data_xts) %>% 
  dySeries(keyword[1], color="blue") %>% 
  dySeries(keyword[2], color="red") %>% 
  dySeries(keyword[3], color="green") %>% 
  dyRangeSelector(height=20)
fig_dygraph

# 統整查詢結果
data_df = reshape2::dcast(interest_over_time, 
                          date ~ keyword,
                          value.var="hits")

# 繪製好看表格
DT::datatable(data_df)



### 繪製股價圖 ###
library(plotly)
library(quantmod)

# 包裝成函式，方便使用
candlestick = function(ticker, start = "2021-01-01", 
                       end = "2021-06-18"){
  # 讀取股價資料
  Asset = getSymbols(ticker, from=start, to=end, auto.assign=FALSE)
  df = data.frame(Date=index(Asset), coredata(Asset))

  # 畫圖
  fig = df %>%
    plot_ly(x=~Date, 
            type="candlestick",
            open=~df[,2], 
            close=~df[,5],
            high=~df[,3], 
            low=~df[,4]) %>% 
    layout(title= paste("Candlestick Chart", ticker))
  fig
  }

candlestick(ticker = "2603.TW")
