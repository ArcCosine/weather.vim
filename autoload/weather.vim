let s:title = '------------------------  WEATHER-VIM  ------------------------'
let s:toAll = '>>全国'
let s:locations = []
let [s:WIN_ALL, s:WIN_CITY] = range(2)


function! s:out(line)
  call setline(line('$')+1, a:line)
endfunction

function! weather#list(A, L, P)
  let items = []
  for item in g:weather#city_list
    if !has_key(item, 'id')
      continue
    endif
    if item.name =~ '^'.a:A
      call add(items, item.name)
    endif
  endfor
  return items
endfunction

function! weather#all(...)
  if len(a:000) > 0
    let location = filter(copy(g:weather#city_list), 'v:val.name == a:000[0]')
    if len(location) > 0
      call weather#city(location[0].id)
    endif
    return
  endif

  " open window
  call s:open_win()
  let b:weather_win = s:WIN_ALL

  setl modifiable
  % delete _

  let cities = ''
  let first = 1
  for city in g:weather#city_list
    if !has_key(city, 'id')
      if cities != ''
        call s:out('  ' . cities)
        let cities = ''
      endif
      if first == 1
        call setline(1, s:title)
        let first = 0
      else
        call s:out('')
      endif
      call s:out(city.name)
    else
      let cities .= city.name . ' '
    endif
  endfor
  if cities != ''
    call s:out('  ' . cities)
  endif
  call s:out('')

  setl nomodifiable
  call cursor(b:cline[s:WIN_ALL], 3)

endfunction

function! weather#city(city)
  " request
  try
    let json = webapi#json#decode(webapi#http#get('http://weather.livedoor.com/forecast/webservice/json/v1?city=' . a:city).content)
  catch /.*/
    echoerr "get weather data error."
    return
  endtry

  if len(json.forecasts) < 3
    call add(json.forecasts, {'date':'', 'dateLabel':'', 'telop':'', 'temperature':{}})
  endif

  " open window
  call s:open_win()
  let b:weather_win = s:WIN_CITY
  setl modifiable
  % delete _

  " title
  call setline(1, s:title)

  " weather
  call s:out(printf('| (%10s)  | (%10s)  | (%10s)  | %s',    json.forecasts[0].date, json.forecasts[1].date, json.forecasts[2].date, json.location.area))
  call s:out(printf('| %-10s    | %-10s    | %-10s    | %s', json.forecasts[0].dateLabel, json.forecasts[1].dateLabel, json.forecasts[2].dateLabel, json.location.prefecture))
  call s:out(printf('| %-10s    | %-10s    | %-10s    | %s', json.forecasts[0].telop, json.forecasts[1].telop, json.forecasts[2].telop, json.location.city))
  let templ = ''
  for idx in range(len(json.forecasts))
    if has_key(json.forecasts[idx].temperature, 'min')
      try
        let templ .= printf('| %-10s    ', json.forecasts[idx].temperature.min.celsius . ' 〜 ' . json.forecasts[idx].temperature.max.celsius . '°')
      catch /.*/
        let templ .= '|               '
      endtry
    else
      let templ .= '|               '
    endif
  endfor
  call s:out(templ . '| ')

  " 詳細
  call s:out('---------------------------------------------------------------')
  call s:out(map(split(json.description.text, '。 \{0,1\}'), 'v:val . "。"'))
  call s:out('')
  call s:out(s:toAll)
  call s:out('')

  " copyright
  call s:out('---------------------------------------------------------------')
  call s:out(json.copyright.title)
  call s:out(json.copyright.provider[0].name . ' ' . json.copyright.provider[0].link)
  call s:out('')
  setl nomodifiable

  let s:locations = json.pinpointLocations
endfunction

function! s:open_win()
  if !exists('b:weather_win')
    new
    silent edit weather
    setl bt=nofile noswf wrap hidden nolist nomodifiable ft=weather
    nnoremap <buffer><Plug>(weather-click) :<C-u>call weather#click()<CR>
    nnoremap <buffer><Plug>(weather-back) :<C-u>call weather#back()<CR>
    nmap <buffer><CR> <Plug>(weather-click)
    nmap <buffer><BS> <Plug>(weather-back)
    let b:weather_win = 0
    let b:cline = [0, 0]
  endif
endfunction

function! weather#click()
  let word = expand('<cWORD>')
  let b:cline[b:weather_win] = line('.')
  if b:weather_win == s:WIN_CITY
    if word == s:toAll
      call weather#all()
    endif
  elseif b:weather_win == s:WIN_ALL
    let location = filter(copy(g:weather#city_list), 'v:val.name == word')
    if len(location) > 0 && has_key(location[0], 'id')
      call weather#city(location[0].id)
    endif
  endif
endfunction

function! weather#back()
  call weather#all()
endfunction

" --- city lit ---

let g:weather#city_list = [
  \ { "name":"道北"},
  \ { "name":"稚内", "id":"011000"},
  \ { "name":"旭川", "id":"012010"},
  \ { "name":"留萌", "id":"012020"},
  \ { "name":"道東"},
  \ { "name":"網走", "id":"013010"},
  \ { "name":"北見", "id":"013020"},
  \ { "name":"紋別", "id":"013030"},
  \ { "name":"根室", "id":"014010"},
  \ { "name":"釧路", "id":"014020"},
  \ { "name":"帯広", "id":"014030"},
  \ { "name":"道南"},
  \ { "name":"室蘭", "id":"015010"},
  \ { "name":"浦河", "id":"015020"},
  \ { "name":"道央"},
  \ { "name":"札幌", "id":"016010"},
  \ { "name":"岩見沢", "id":"016020"},
  \ { "name":"倶知安", "id":"016030"},
  \ { "name":"道南"},
  \ { "name":"函館", "id":"017010"},
  \ { "name":"江差", "id":"017020"},
  \ { "name":"青森県"},
  \ { "name":"青森", "id":"020010"},
  \ { "name":"むつ", "id":"020020"},
  \ { "name":"八戸", "id":"020030"},
  \ { "name":"岩手県"},
  \ { "name":"盛岡", "id":"030010"},
  \ { "name":"宮古", "id":"030020"},
  \ { "name":"大船渡", "id":"030030"},
  \ { "name":"宮城県"},
  \ { "name":"仙台", "id":"040010"},
  \ { "name":"白石", "id":"040020"},
  \ { "name":"秋田県"},
  \ { "name":"秋田", "id":"050010"},
  \ { "name":"横手", "id":"050020"},
  \ { "name":"山形県"},
  \ { "name":"山形", "id":"060010"},
  \ { "name":"米沢", "id":"060020"},
  \ { "name":"酒田", "id":"060030"},
  \ { "name":"新庄", "id":"060040"},
  \ { "name":"福島県"},
  \ { "name":"福島", "id":"070010"},
  \ { "name":"小名浜", "id":"070020"},
  \ { "name":"若松", "id":"070030"},
  \ { "name":"茨城県"},
  \ { "name":"水戸", "id":"080010"},
  \ { "name":"土浦", "id":"080020"},
  \ { "name":"栃木県"},
  \ { "name":"宇都宮", "id":"090010"},
  \ { "name":"大田原", "id":"090020"},
  \ { "name":"群馬県"},
  \ { "name":"前橋", "id":"100010"},
  \ { "name":"みなかみ", "id":"100020"},
  \ { "name":"埼玉県"},
  \ { "name":"さいたま", "id":"110010"},
  \ { "name":"熊谷", "id":"110020"},
  \ { "name":"秩父", "id":"110030"},
  \ { "name":"千葉県"},
  \ { "name":"千葉", "id":"120010"},
  \ { "name":"銚子", "id":"120020"},
  \ { "name":"館山", "id":"120030"},
  \ { "name":"東京都"},
  \ { "name":"東京", "id":"130010"},
  \ { "name":"大島", "id":"130020"},
  \ { "name":"八丈島", "id":"130030"},
  \ { "name":"父島", "id":"130040"},
  \ { "name":"神奈川県"},
  \ { "name":"横浜", "id":"140010"},
  \ { "name":"小田原", "id":"140020"},
  \ { "name":"新潟県"},
  \ { "name":"新潟", "id":"150010"},
  \ { "name":"長岡", "id":"150020"},
  \ { "name":"高田", "id":"150030"},
  \ { "name":"相川", "id":"150040"},
  \ { "name":"富山県"},
  \ { "name":"富山", "id":"160010"},
  \ { "name":"伏木", "id":"160020"},
  \ { "name":"石川県"},
  \ { "name":"金沢", "id":"170010"},
  \ { "name":"輪島", "id":"170020"},
  \ { "name":"福井県"},
  \ { "name":"福井", "id":"180010"},
  \ { "name":"敦賀", "id":"180020"},
  \ { "name":"山梨県"},
  \ { "name":"甲府", "id":"190010"},
  \ { "name":"河口湖", "id":"190020"},
  \ { "name":"長野県"},
  \ { "name":"長野", "id":"200010"},
  \ { "name":"松本", "id":"200020"},
  \ { "name":"飯田", "id":"200030"},
  \ { "name":"岐阜県"},
  \ { "name":"岐阜", "id":"210010"},
  \ { "name":"高山", "id":"210020"},
  \ { "name":"静岡県"},
  \ { "name":"静岡", "id":"220010"},
  \ { "name":"網代", "id":"220020"},
  \ { "name":"三島", "id":"220030"},
  \ { "name":"浜松", "id":"220040"},
  \ { "name":"愛知県"},
  \ { "name":"名古屋", "id":"230010"},
  \ { "name":"豊橋", "id":"230020"},
  \ { "name":"三重県"},
  \ { "name":"津", "id":"240010"},
  \ { "name":"尾鷲", "id":"240020"},
  \ { "name":"滋賀県"},
  \ { "name":"大津", "id":"250010"},
  \ { "name":"彦根", "id":"250020"},
  \ { "name":"京都府"},
  \ { "name":"京都", "id":"260010"},
  \ { "name":"舞鶴", "id":"260020"},
  \ { "name":"大阪府"},
  \ { "name":"大阪", "id":"270000"},
  \ { "name":"兵庫県"},
  \ { "name":"神戸", "id":"280010"},
  \ { "name":"豊岡", "id":"280020"},
  \ { "name":"奈良県"},
  \ { "name":"奈良", "id":"290010"},
  \ { "name":"風屋", "id":"290020"},
  \ { "name":"和歌山県"},
  \ { "name":"和歌山", "id":"300010"},
  \ { "name":"潮岬", "id":"300020"},
  \ { "name":"鳥取県"},
  \ { "name":"鳥取", "id":"310010"},
  \ { "name":"米子", "id":"310020"},
  \ { "name":"島根県"},
  \ { "name":"松江", "id":"320010"},
  \ { "name":"浜田", "id":"320020"},
  \ { "name":"西郷", "id":"320030"},
  \ { "name":"岡山県"},
  \ { "name":"岡山", "id":"330010"},
  \ { "name":"津山", "id":"330020"},
  \ { "name":"広島県"},
  \ { "name":"広島", "id":"340010"},
  \ { "name":"庄原", "id":"340020"},
  \ { "name":"山口県"},
  \ { "name":"下関", "id":"350010"},
  \ { "name":"山口", "id":"350020"},
  \ { "name":"柳井", "id":"350030"},
  \ { "name":"萩", "id":"350040"},
  \ { "name":"徳島県"},
  \ { "name":"徳島", "id":"360010"},
  \ { "name":"日和佐", "id":"360020"},
  \ { "name":"香川県"},
  \ { "name":"高松", "id":"370000"},
  \ { "name":"愛媛県"},
  \ { "name":"松山", "id":"380010"},
  \ { "name":"新居浜", "id":"380020"},
  \ { "name":"宇和島", "id":"380030"},
  \ { "name":"高知県"},
  \ { "name":"高知", "id":"390010"},
  \ { "name":"室戸岬", "id":"390020"},
  \ { "name":"清水", "id":"390030"},
  \ { "name":"福岡県"},
  \ { "name":"福岡", "id":"400010"},
  \ { "name":"八幡", "id":"400020"},
  \ { "name":"飯塚", "id":"400030"},
  \ { "name":"久留米", "id":"400040"},
  \ { "name":"佐賀県"},
  \ { "name":"佐賀", "id":"410010"},
  \ { "name":"伊万里", "id":"410020"},
  \ { "name":"長崎県"},
  \ { "name":"長崎", "id":"420010"},
  \ { "name":"佐世保", "id":"420020"},
  \ { "name":"厳原", "id":"420030"},
  \ { "name":"福江", "id":"420040"},
  \ { "name":"熊本県"},
  \ { "name":"熊本", "id":"430010"},
  \ { "name":"阿蘇乙姫", "id":"430020"},
  \ { "name":"牛深", "id":"430030"},
  \ { "name":"人吉", "id":"430040"},
  \ { "name":"大分県"},
  \ { "name":"大分", "id":"440010"},
  \ { "name":"中津", "id":"440020"},
  \ { "name":"日田", "id":"440030"},
  \ { "name":"佐伯", "id":"440040"},
  \ { "name":"宮崎県"},
  \ { "name":"宮崎", "id":"450010"},
  \ { "name":"延岡", "id":"450020"},
  \ { "name":"都城", "id":"450030"},
  \ { "name":"高千穂", "id":"450040"},
  \ { "name":"鹿児島県"},
  \ { "name":"鹿児島", "id":"460010"},
  \ { "name":"鹿屋", "id":"460020"},
  \ { "name":"種子島", "id":"460030"},
  \ { "name":"名瀬", "id":"460040"},
  \ { "name":"沖縄県"},
  \ { "name":"那覇", "id":"471010"},
  \ { "name":"名護", "id":"471020"},
  \ { "name":"久米島", "id":"471030"},
  \ { "name":"南大東", "id":"472000"},
  \ { "name":"宮古島", "id":"473000"},
  \ { "name":"石垣島", "id":"474010"},
  \ { "name":"与那国島", "id":"474020"},
  \ ]

