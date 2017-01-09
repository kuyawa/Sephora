// Markdown.js

function Markdown(text) {
	//console.log("Markdown enter...")
	var md = removeCR(text)

    md = cleanHtml(md)
    md = parseHeaders(md)
    md = parseBold(md)
    md = parseItalic(md)
    md = parseDeleted(md)
    md = parseImages(md)
    md = parseLinks(md)
    md = parseYoutubeVideos(md)
    md = parseCodeBlock(md)
    md = parseCodeInline(md)
    md = parseHorizontalRule(md)
    md = parseUnorderedLists(md)
    md = parseOrderedLists(md)
    md = parseBlockquotes(md)
    md = parseParagraphs(md)

	//console.log("Markdown exit...")
    return md

    // Internal methods
	function removeCR(text) {
		return text.split("\r\n").join("\n")
	}

	function cleanHtml(md) {
	    return md.replace(/<.*?>/gm, "")
	}

	function parseHeaders(md) {
		var mx = md
	    mx = mx.replace(/^###(.*)?$/m, "<h3>$1</h3>")
	    mx = mx.replace(/^##(.*)?$/m, "<h2>$1</h2>")
	    mx = mx.replace(/^#(.*)?$/m, "<h1>$1</h1>")
	    return mx
	}

	function parseBold(md) {
	    return md.replace(/\*\*(.*?)\*\*/gm, "<b>$1</b>")
	}

	function parseItalic(md) {
	    return md.replace(/\*(.*?)\*/gm, "<i>$1</i>")
	}

	function parseDeleted(md) {
	    return md.replace(/~~(.*?)~~/gm, "<s>$1</s>")
	}

	function parseImages(md) {
		var mx = md
	    mx = mx.replace(/!\[(\d+)x(\d+)\]\((.*?)\)/gm, "<img src=\"$3\" width=\"$1\" height=\"$2\" />")
	    mx = mx.replace(/!\[(.*?)\]\((.*?)\)/gm, "<img alt=\"$1\" src=\"$2\" />")
	    return mx
	}

	function parseLinks(md) {
		var mx = md
	    mx = mx.replace(/\[(.*?)\]\((.*?)\)/gm, "<a href=\"$2\">$1</a>")
	    mx = mx.replace(/\[http(.*?)\]/gm, "<a href=\"http$1\">http$1</a>")
	    mx = mx.replace(/(^|\s)http(.*?)(\s|\.\s|\.$|,|$)/gm, "$1<a href=\"http$2\">http$2</a>$3")
	    return mx
	}

	function parseCodeBlock(md) {
	    return md.replace(/\`\`\`\n?([^`]+)\`\`\`/gm, "<pre>$1</pre>")
	}

	function parseCodeInline(md) {
	    return md.replace(/\`(.*?)\`/gm, "<code>$1</code>")
	}

	function parseHorizontalRule(md) {
	    return md.replace(/^---/gm, "<hr>")
	}

	function parseUnorderedLists(md) {
		var rex = /^\s*\*/gm
	    return parseBlock(md, rex, "<ul>", "</ul>", "<li>", "</li>")
	}

	function parseOrderedLists(md) {
		var rex = /^\s*\d+[\.|-]/gm
	    return parseBlock(md, rex, "<ol>", "</ol>", "<li>", "</li>")
	}

	function parseBlockquotes(md) {
		var rex1 = /^>/gm
		var rex2 = /^:/gm
		var mx = md
	    mx = parseBlock(mx, rex1, "<blockquote>", "</blockquote>")
	    mx = parseBlock(mx, rex2, "<blockquote>", "</blockquote>")
	    return mx
	}

	function parseYoutubeVideos(md) {
	    return md.replace(/\[youtube (.*?)\]/gm, "<p><a href=\"http://www.youtube.com/watch?v=$1\" target=\"_blank\"><img src=\"http://img.youtube.com/vi/$1/0.jpg\" alt=\"Youtube video\" width=\"240\" height=\"180\" /></a></p>")
	}

	function parseParagraphs(md) {
	    return md.replace(/\n\n([^\n]+)\n\n/gm, "\n\n<p>$1</p>\n\n")
	}

	function parseBlock(md, pattern, blockIni, blockEnd, lineIni, lineEnd) {
		if(!lineIni){ lineIni = "" }
		if(!lineEnd){ lineEnd = "" }
	    var lines = md.split("\n")
	    var result = []
	    var isBlock = false
	    var isFirst = true
	    
	    for(i in lines) {
	        var text = lines[i]
	        if(text.match(pattern)) {
	            isBlock = true
	            if(isFirst) { result.push(blockIni); isFirst = false }
	            text = text.replace(pattern, "")
	            text = lineIni + text.trim() + lineEnd
	        } else if(isBlock) {
	            isBlock = false
	            isFirst = true
	            text += blockEnd+"\n"
	        }
	        result.push(text)
	    }

	    if(isBlock) { result.push(blockEnd) } // close open blocks
	    
	    var mx = result.join("\n")

	    return mx
	}
}

// End