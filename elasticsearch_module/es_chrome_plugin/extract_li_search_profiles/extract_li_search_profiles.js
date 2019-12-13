var myURL = "https://www.linkedin.com";

function DOMtoString(document_root) {
	var html = '',
		node = document_root.firstChild;
	while (node) {
		switch (node.nodeType) {
			case Node.ELEMENT_NODE:
				html += node.outerHTML;
				break;
			case Node.TEXT_NODE:
				html += node.nodeValue;
				break;
			case Node.CDATA_SECTION_NODE:
				html += '<![CDATA[' + node.nodeValue + ']]>';
				break;
			case Node.COMMENT_NODE:
				html += '<!--' + node.nodeValue + '-->';
				break;
			case Node.DOCUMENT_TYPE_NODE:
				// (X)HTML documents are identified by public identifiers
				html += "<!DOCTYPE " + node.name + (node.publicId ? ' PUBLIC "' + node.publicId + '"' : '') + (!node.publicId && node.systemId ? ' SYSTEM' : '') + (node.systemId ? ' "' + node.systemId + '"' : '') + '>\n';
				break;
		}
		node = node.nextSibling;
	}

	try {
		var tab_source = html;

		var links = "";

		var delay = 0;
		var time_gap = 3000;			// 1 sec of time delay for next page to click on the main/landing page

		//var from_page_number = 1;
		var to_page_number = 100;

		//P1: For the first landing page

		if(tab_source.indexOf("profile/view") >= 0) {
			exportInputs(tab_source);

			delay = Number(delay) + Number(time_gap);

			setTimeout(function() {
				$(tab_source).find('.pagination li.next a.page-link').each(function() {
					var href = $(this).attr('href');
					var next_url = "https://www.linkedin.com"+href;

					//console.log("next_url: "+next_url);

					var bla = new urlQueryGetter(next_url);
					var next_page_num = bla.getParam('page_num');

					//console.log(next_page_num);

					if(next_page_num <= to_page_number) {
						console.log("open the next_page_num: "+next_page_num);
						window.open(next_url, "_self")
					} else {
						console.log("do not open the next_page_num: "+next_page_num);
					}
				});
			}, delay);
		}
	} catch(err) {
		alert(err);
	}
}

//Quick and dirty query Getter object.
function urlQueryGetter(url){
	//array to store params
	var qParam = new Array();
	//function to get param
	this.getParam = function(x){
		return qParam[x];
	};

	//parse url
	query = url.substring(url.indexOf('?')+1);
	query_items = query.split('&');
	for(i=0; i<query_items.length;i++){
		s = query_items[i].split('=');
		qParam[s[0]] = s[1];
	}
}

function exportInputs(tab_source) {
	myURL = window.location.href;
	var myURL_parse = myURL.split("\/");

	var profile_url_name = "lin_"+myURL_parse[myURL_parse.length-1];

	downloadFileFromText(profile_url_name+'.html',tab_source);

	//window.close();
}

function downloadFileFromText(filename, content) {
	var a = document.createElement('a');
	var blob = new Blob([ content ], {type : "text/plain;charset=UTF-8"});
	a.href = window.URL.createObjectURL(blob);
	a.download = filename;
	a.style.display = 'none';
	document.body.appendChild(a);
	a.click(); //this is probably the key - simulating a click on a download link
	delete a;// we don't need this anymore
}

$(document).ready(function() {
	chrome.runtime.sendMessage({
		action: "getSource",
		source: DOMtoString(document)
	});
});
