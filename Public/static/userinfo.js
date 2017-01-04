// fetchuserinfo.js

function fetchUserInfo() {
	nick = $("usernick").value;
	if(nick==''){ alert("Nick can not be empty!"); $("usernick").focus();  return; }
	url = "/register/user/"+nick;
	$("fetch").disabled = true;
	$("wait").style.visibility  = "visible";
	try {
		webRequest(url, null, onUserInfo);
	} catch(ex) {
		$("nick").innerHTML = "error";
		$("wait").style.visibility  = "hidden";
		$("fetch").disabled = false;
		alert("Error accessing server. Try again later")
	}
}

function onUserInfo(json) {
	//console.log("INFO: "+json);
	$("wait").style.visibility  = "hidden";
	$("fetch").disabled = false;
	try {
		info = JSON.parse(json);
		if(info.error){ 
			$("nick").innerHTML = "error";
			$("name").innerHTML = info.error;
			$("login").style.visibility = "hidden";
			alert("Error validating information. Try again later")
			return;
		}
		$("nick").innerHTML = info.nick;
		$("name").innerHTML = info.name;
		$("avatar").src     = info.avatar;
		$("login").style.visibility = "visible";
	} catch(ex) {
		$("nick").innerHTML = "error";
		$("login").style.visibility = "hidden";
		alert("Error parsing information. Try again later")
	}
}

function loginRedirect() {
	nick = $("usernick").value;
	window.location.href = "/login/github/"+nick;
}

function $(id) {
	return document.getElementById(id);
}

function webRequest(url, data, callback, target) {
	var http = new XMLHttpRequest();
	if(!data){ mode="GET"; } else { mode="POST"; }
	http.open(mode, url, true);
	if(mode=="POST"){ http.setRequestHeader('Content-Type','application/x-www-form-urlencoded'); }
	http.onreadystatechange = function(){ if(http.readyState==4){ callback(http.responseText,target); }};
	http.send(data);
}

// End