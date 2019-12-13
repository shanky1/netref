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
		var time_gap = 10;
		var cnt = 0;

		//For the first landing page

		$(tab_source).find('.directory ol li a').each(function() {
			var hrefl = $(this).attr('href');

			if(cnt <= 2) {		//doing for first 3 links
				//window.open(hrefl,'_self');

				setTimeout(function() {
					window.open(hrefl);
					window.close();
				}, 1000);
			}

			cnt = Number(cnt) + 1;

			links += hrefl+"\n";
		});

		//message.innerText = links;
	} catch(err) {
		alert(err);
	}

	//For the 2nd, 3rd and 4th pages

	if(cnt == 0) {
		$(tab_source).find('.column li a').each(function() {
			var hrefl = $(this).attr('href');

			delay = Number(delay) + Number(time_gap);

			if(cnt <= 2) {		//doing for first 3 links
				if(hrefl.indexOf('https:') !== -1 || hrefl.indexOf('http:') !== -1) {
					//window.open(hrefl,'_self');

					setTimeout(function() {
						window.open(hrefl);
						window.close();
					}, 300);
				} else {
					var myURL = window.location.href;
					basic = myURL.split('.com/');
					//window.open(basic[0]+'.com'+hrefl,'_self');

					setTimeout(function() {
						window.open(basic[0]+'.com'+hrefl);
						window.close();
					}, 300);
				}
			}

			cnt = Number(cnt) + 1;

			links += hrefl+"\n";
		});
	}

	//For the 5th page

	if(cnt == 0) {
		$(tab_source).find('.professionals ul li div div h3 a').each(function() {
			delay = Number(delay) + Number(time_gap);

			var myURL = window.location.href;
			var myURL_parse = myURL.split("\/");

			var profile_url_name = myURL_parse[myURL_parse.length-1];

			setTimeout(function() {
				exportInputs(profile_url_name, tab_source);
			}, 1000);
		});
	}
}

function exportInputs(profile_url_name, tab_source) {
	downloadFileFromText(profile_url_name+'.html',tab_source);

	window.close();
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
