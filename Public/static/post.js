// post.js
// uses external library markdown.js

//---- POST

var postTitle    = $("post-title");
var postContent  = $("post-content");
var editTitle    = $("edit-title");
var editContent  = $("edit-content");
var newTitle     = $("new-title");
var newContent   = $("new-content");

var oldPostTitle   = "";
var oldPostContent = "";

function setPostViewMode() {
	postTitle.style.display   = "block";
	postContent.style.display = "block";
	editTitle.style.display   = "none";
	editContent.style.display = "none";
}

function setPostEditMode() {
	postTitle.style.display   = "none";
	postContent.style.display = "none";
	editTitle.style.display   = "block";
	editContent.style.display = "block";
}

function modifyPost(postId) {
	setPostEditMode();
	oldPostTitle   = newTitle.value;
	oldPostContent = newContent.value;
	return false
}

function cancelPost() {
	setPostViewMode();
	newTitle.value   = oldPostTitle;
	newContent.value = oldPostContent;
}

function savePost(postId) {
	title = newTitle.value;
	content = newContent.value;
	// if empty info alert to avoid server trips
	data = "title="+title+"&content="+content;
	webRequest("POST", "/api/post/"+postId, data, onPostSaved, postId);
}

function onPostSaved(text, postId) {
	//alert(text);
	console.log(text);
	if(text=="OK"){
		setPostViewMode();
		postTitle.innerHTML   = newTitle.value;
		postContent.innerHTML = Markdown(newContent.value);
	} else {
		alert("Error saving post. Try again later");
	}
}

function deletePost(postId) {
	ok = confirm("This post will be deleted and it won't be recoverable.\nPress OK to delete...");
	if(!ok) { return; }
	webRequest("DELETE", "/api/post/"+postId, null, onPostDeleted);
	return false;
}

function onPostDeleted(text) {
	if(text=="OK"){
		//window.location.href = "/forums"
		postContent.innerHTML = "[This post has been deleted]"
		try { document.getElementsByTagName("h6")[0].innerHTML = "[deleted]"; } catch(ex) {}
		try { document.getElementsByTagName("replies")[0].style.display = "none"; } catch(ex) {}
		try { document.getElementsByTagName("newreply")[0].style.display = "none"; } catch(ex) {}
	} else {
		alert("Error deleting post. Try again later");
	}
}

function reportPost(postId) {
	text = prompt("Enter the reason for reporting the post: ");
	if(!text) { return; }
	reason = "reason="+text;
	webRequest("POST", "/api/post/"+postId+"/report", reason, onPostReported);
	return false;
}

function onPostReported(text) {
	if(text=="OK"){
		alert("Post reported. Thanks for keeping the forum clean.");
	} else {
		alert("Error reporting post. Try again later");
	}
}


//---- REPLY

var textReply;
var editReply;
var newReply;
var oldReply = "";

function setReplyViewMode() {
	textReply.style.display = "block";
	editReply.style.display = "none";
}

function setReplyEditMode() {
	textReply.style.display = "none";
	editReply.style.display = "block";
}

function cancelReply() {
	setReplyViewMode();
	newReply.value = oldReply;
}

function modifyReply(replyId) {
	// reset all editors
	allEditReplies = document.getElementsByClassName("edit-reply");
	for(i=0; i<allEditReplies.length; i++){ allEditReplies[i].style.display = "none"; }
	allTextReplies = document.getElementsByClassName("text-reply");
	for(i=0; i<allTextReplies.length; i++){ allTextReplies[i].style.display = "block"; }
	// enable selected reply only
	textReply = $("text-reply-"+replyId);
	editReply = $("edit-reply-"+replyId);
	newReply  = $("new-reply-"+replyId);
	setReplyEditMode();
	oldReply = newReply.value;
	return false;
}

function saveReply(replyId) {
	data = "content=" + newReply.value;
	//alert(data);
	webRequest("POST", "/api/reply/"+replyId, data, onReplySaved, replyId);
}

function onReplySaved(text, replyId) {
	//alert(text);
	if(text=="OK"){
		textReply.innerHTML = Markdown(newReply.value);
		setReplyViewMode();
	} else {
		alert("Error saving reply. Try again later");
	}
}

function deleteReply(replyId) {
	ok = confirm("This message will be deleted and it won't be recoverable.\nPress OK to delete...");
	if(!ok) { return; }
	textReply = $("text-reply-"+replyId);
	editReply = $("edit-reply-"+replyId);
	newReply  = $("new-reply-"+replyId);
	webRequest("DELETE", "/api/reply/"+replyId, null, onReplyDeleted, replyId);
	return false;
}

function onReplyDeleted(text, replyId) {
	//alert(text);
	if(text=="OK"){
		reply = $("reply-"+replyId);
		if(reply) { reply.style.display = "none"; }
	} else {
		alert("Error deleting message. Try again later");
	}
}

function reportReply(replyId) {
	text = prompt("Enter the reason for reporting the message: ");
	if(!text) { return; }
	reason = "reason="+text;
	webRequest("POST", "/api/reply/"+replyId+"/report", reason, onReplyReported);
	return false;
}

function onReplyReported(text) {
	if(text=="OK"){
		alert("Message reported. Thanks for keeping the forum clean.");
	} else {
		alert("Error reporting message. Try again later");
	}
}

function pickAnswer(replyId) {
	if(!replyId){ return false; }
	try {
		reply = $("reply-"+replyId);
		img = reply.getElementsByTagName("answered")[0].getElementsByTagName("img")[0];
		if (img.className == "answer-ok") { 
			webRequest("POST", "/api/reply/"+replyId+"/answer", "answer=0", onPostAnswered, img);
		} else { 
			webRequest("POST", "/api/reply/"+replyId+"/answer", "answer=1", onPostAnswered, img);
		}
	} catch(ex) {
		alert("Something went wrong. Try later");
	}
	return false;
}

function onPostAnswered(ok, img) {
	if(ok=="OK:0"){	img.className = "answer-no"; } else
	if(ok=="OK:1"){	img.className = "answer-ok"; } else {
		alert("Something went wrong. Try again later");
	}
}

function showHelp() {
	help = document.getElementsByTagName("help")[0];
	help.style.display = (help.style.display == "block" ? "none" : "block");
	return false;
}

function showLink(replyId) {
	var link = location.href;
	if(location.href.indexOf("#") > 0){
		link = location.href.substring(0, location.href.indexOf("#"));
	}
	prompt("Here is the permalink:", link + "#reply-" + replyId);
	return false;
}

function star(replyId) {
	if(!replyId){ return false; }
	try {
		img = $("star-"+replyId);
		if (img.className == "star-off") { 
			webRequest("POST", "/api/reply/"+replyId+"/star", "state=1", onStarred, replyId);
		} else { 
			webRequest("POST", "/api/reply/"+replyId+"/star", "state=0", onStarred, replyId);
		}
	} catch(ex) {
		alert("Something went wrong. Try later");
	}
	return false;
}

function onStarred(ok, replyId) {
	img = $("star-"+replyId);
	cnt = $("count-"+replyId);
	if(ok=="OK:0"){	img.className = "star-off"; cnt.innerHTML = parseInt(cnt.innerHTML)-1; } else
	if(ok=="OK:1"){	img.className = "star-on";  cnt.innerHTML = parseInt(cnt.innerHTML)+1; } else
	if(ok=="NO:1"){	alert("Reply id is required. Something went wrong."); } else 
	if(ok=="NO:2"){	alert("Star value is required. Something went wrong."); } else 
	if(ok=="NO:3"){	alert("Must be logged in to star messages."); } else 
	if(ok=="NO:4"){	alert("Message not found. Something went wrong."); } else 
	if(ok=="NO:5"){	alert("You can not star your own messages."); } else {
		alert("Something went wrong. Try again later");
	}
}


// UTILS

function $(id) {
	return document.getElementById(id);
}

// webRequest("POST", "api/post/123", "title=hello&content=world", onReady, target)
// webRequest("DELETE", "api/post/123", null, onReady, target)
function webRequest(mode, url, data, callback, target) {
	var http = new XMLHttpRequest();
	http.open(mode, url, true);
	if(mode=="POST"){ http.setRequestHeader('Content-Type','application/x-www-form-urlencoded'); }
	http.onreadystatechange = function(){ if(http.readyState==4){ callback(http.responseText,target); }};
	http.send(data);
}


// End