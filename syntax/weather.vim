if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match weatherTitle "------------------------  WEATHER-VIM  ------------------------"
syn keyword weatherToday 今日
syn keyword weatherTommorow 明日
syn keyword weatherDayAfterTommorow 明後日
syn match weatherSunny   "晴"
syn match weatherCloudy  "曇"
syn match weatherRain    "雨"
syn match weatherSnow    "雪"
syn match weatherThunder "雷"
syn match weatherAll     ">>全国"
syn match weatherDate    "(\d\d\d\d-\d\d-\d\d)"
syn match weatherHL      "---------------------------------------------------------------"

hi default link weatherTitle Function
hi default link weatherToday Title
hi default link weatherTommorow Title
hi default link weatherDayAfterTommorow Title
hi default link weatherSunny Directory
hi default link weatherCloudy Underlined
hi default link weatherThunder Error
hi default link weatherRain Type
hi default link weatherSnow PreProc
hi default link weatherDate Visual
hi default link weatherHL Debug
hi default link weatherAll Underlined

let b:current_syntax = 'weather'
