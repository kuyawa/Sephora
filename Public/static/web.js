function fetchUserInfo() {
	nick = document.getElementById("nick")
	url  = "/register/user/"+nick
	webRequest(url, null, onUserInfo)
}

function onUserInfo(info) {
	console.log("INFO: "+info)
}

function webRequest(url, request, callback, target) {
	var http = new XMLHttpRequest();
	if(!request){ mode="GET"; } else { mode="POST"; }
	http.open(mode, url, true);
	if(mode=="POST"){ http.setRequestHeader('Content-Type','application/x-www-form-urlencoded'); }
	http.onreadystatechange = function(){ if(http.readyState==4){ callback(http.responseText,target); }};
	http.send(request);
}

// End