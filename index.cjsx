{_, SERVER_HOSTNAME} = window
#Promise = require 'bluebird'
#async = Promise.coroutine
fs = require 'fs-extra'
path = require 'path-extra'

shipData = null
beforeStatus = null
afterStatus = null
textRaw = '火力|雷装|对空|装甲|运'
nameStatuses = textRaw.split '|'

getStatus = (ship, i) ->
  # i = 0 for current status, and i = 1 for max status
  if ship
    {api_karyoku, api_raisou, api_taiku, api_soukou, api_lucky} = ship
    statuses = [api_karyoku, api_raisou, api_taiku, api_soukou, api_lucky]
    statuses.map (s) -> s[i]

onRequest = (e) ->
  if e.detail.path == '/kcsapi/api_req_kaisou/powerup'
    #console.log 'Request', e.detail.path, e.detail
    # Read target before-status
    target = window._ships[parseInt(e.detail.body.api_id, 10)]
    beforeStatus = getStatus(target, 0)
    console.log beforeStatus

onResponse = (e) ->
  if e.detail.path == '/kcsapi/api_req_kaisou/powerup'
    #console.log 'Response', e.detail.path, e.detail
    # Read target after-status
    console.log e.detail.body
    if e.detail.body.api_powerup_flag
      target = e.detail.body.api_ship
      afterStatus = getStatus(target, 0)
      console.log afterStatus
      if beforeStatus && afterStatus
        textStatuses = ("#{t}+#{s2-s1}" for [t, s1, s2] in \
              _.zip(nameStatuses, beforeStatus, afterStatus) when s2 != s1)
        setTimeout window.success, 100, '改修成功！' + textStatuses.join('，')
    else
      setTimeout window.warn, 100, '近代化改修失败……'

fs.readJSON path.join(__dirname, 'assets', 'ship-data.json'), (err, packageObj) ->
  shipData = packageObj
  if !packageObj
    console.error 'Reading ship-data.json failed: ', err
  window.addEventListener 'game.request', onRequest
  window.addEventListener 'game.response', onResponse

module.exports =
  name: 'DeltaModernization'
  author: 'DKWings'
  displayName: <span><FontAwesome name='fa-caret-square-o-up' /> 合成差分 </span>
  link: 'https://github.com/dkwingsmt'
  description: '显示近代化改修（合成）的结果'
  show: false
  version: '0.0.1'
