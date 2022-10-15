/* notes
toStaticHTML ? don't need this if cleaned on server
*/

var chat = document.getElementById('chat')
var menu = document.getElementById('menu')
var date = new Date()
var ping = 0

function ingress (payload) {
  var data
  try {
    data = JSON.parse(payload)
  }
  catch (error) {
    chat.innerHTML += '<div>Chat ingress error.</div>'
    return
  }
  switch (data['type']) {
    case 'chat': {
      handleChat(data)
      break
    }
    default: {
      handleUnknown(data)
    }
  }
}

function handleChat (data) {
  var message = ''
  var meta
  var part
  for (var i = 0, part; i < data.parts.length; ++i) {
    part = data.parts[i]
    meta = ''
    if (part['class']) {
      meta += ' class="' + part['class'] + '"'
    }
    if (part['style']) {
      meta += ' style="' + part['style'] + '"'
    }
    message += '<span' + meta + '>' + part['body'] + '</span>'
  }
  if (message.length) {
    chat.innerHTML += '<div>' + message + '</div>'
    if (chat.scrollHeight > chat.clientHeight) {
      chat.scrollTop = chat.scrollHeight;
    }
  }
}

function handleCookie (data) {
  document.cookie = 'Max-Age=31536000; path=/; data=' + JSON.stringify(data.cookie)
}

function handleUnknown (data) {
  chat.innerHTML += '<div>Invalid chat ingress.</div>'
}

function updatePing () {
	var beginPing = date.getTime()
	var request = new XMLHttpRequest ()
	request.open('GET', '?ping')
	request.send()
	request.onreadystatechange = function () {
		if (request.readyState !== 4 || request.status !== 200) {
			return
		}
		ping = date.getTime() - beginPing
		menu.innerText = ping + 'ms'
		setTimeout(updatePing, 5e3)
	}
}

(function () {
	var request = new XMLHttpRequest ()
  request.open('GET', '?_src_=chat&proc=doneLoading')
  request.send()
	setTimeout(updatePing, 5e3)
})()
