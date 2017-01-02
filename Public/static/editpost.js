// editpost.js


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
	webRequest("POST", "/api/post/"+postId, data, onPostSaved);
}

function onPostSaved(text, target) {
	//alert(text);
	if(text=="OK"){
		setPostViewMode();
		postTitle.innerHTML   = newTitle.value;
		postContent.innerHTML = markdown.parse(newContent.value);
	} else {
		alert("Error saving post. Try again later");
	}
}

function deletePost(postId) {
	ok = confirm("This post will be deleted and it won't be recoverable.\nPress OK to delete...");
	if(!ok) { return; }
	webRequest("DELETE", "/api/post/"+postId, null, onPostDeleted);
	//alert("Feature not yet implemented. Post was not deleted.");
}

function onPostDeleted(text, target) {
	//alert(text);
	if(text=="OK"){
		// TODO: redirect to forum
	} else {
		alert("Error deleting post. Try again later");
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
}

function saveReply(replyId) {
	data = "content=" + newContent.value;
	webRequest("POST", "/api/reply/"+replyId, data, onReplySaved);
}

function onReplySaved(text, target) {
	//alert(text);
	if(text=="OK"){
		setReplyViewMode();
		textReply.innerHTML = markdown.parse(newReply.value);
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
}

function onReplyDeleted(text, target) {
	//alert(text);
	if(text=="OK"){
		reply = $("reply-"+target);
		if(reply) { reply.style.display = "none"; }
	} else {
		alert("Error deleting post. Try again later");
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