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

function onPostSave() {
	setPostViewMode();
	postTitle.innerHTML   = newTitle.value;
	postContent.innerHTML = newContent.value;   /* TODO: Convert to markdown */
	// TODO: Save post
}

function onPostCancel() {
	setPostViewMode();
	newTitle.value   = oldPostTitle;
	newContent.value = oldPostContent;
}

function modifyPost(postId) {
	setPostEditMode();
	oldPostTitle   = newTitle.value;
	oldPostContent = newContent.value;
}

function deletePost(postId) {
	ok = confirm("This post will be deleted and it won't be recoverable.\nPress OK to delete...");
	// TODO: delete post
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

function onReplySave() {
	setReplyViewMode();
	textReply.innerHTML = newReply.value;  /* TODO: Convert to markdown */
	// TODO: Save reply
}

function onReplyCancel() {
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

function deleteReply(replyId) {
	ok = confirm("This message will be deleted and it won't be recoverable.\nPress OK to delete...");
	// TODO: delete reply
}

// UTILS

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