// fetchuserinfo.js

function fetchUserInfo() {
	nick = $("usernick").value;
	if(nick==''){ alert("Nick can not be empty!"); $("usernick").focus();  return; }
	url = "/register/user/"+nick;
	$("wait").style.visibility  = "visible";
	$("fetch").disabled = true;
	webRequest(url, null, onUserInfo);
}

function onUserInfo(json) {
	//console.log("INFO: "+json);
	info = JSON.parse(json);
	$("nick").innerHTML = info.nick;
	$("name").innerHTML = info.name;
	$("avatar").src     = info.avatar;
	$("fetch").disabled = false;
	$("wait").style.visibility  = "hidden";
	$("login").style.visibility = "visible";
}

function loginRedirect() {
	nick = $("usernick").value;
	window.location.href = "/login/github/"+nick;
}

function $(id) {
	return document.getElementById(id);
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