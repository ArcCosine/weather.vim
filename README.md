weather.vim
===========

Description
-----------
vimで日本の天気を表示するプラグイン。
日本気象協会のtenki.jpのwebサービスを使って、
日本各地の天気を表示します。

Requirements
------------
weather.vimは、web-api pluginが必要です。
https://github.com/mattn/webapi-vim


Usage
-----
  :Weather [東京|さいたま|...]

地名を省略した場合は、地域リストを表示します。


Option
------
let g:weather_city_name = '東京'

グローバル変数のweather_city_nameに地域名を指定すると、Weatherとtypeするだけで指定した都市の詳細を表示するようになります

