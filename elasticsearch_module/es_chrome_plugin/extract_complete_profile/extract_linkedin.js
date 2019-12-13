var myURL = "https://af.linkedin.com/";

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

		var time_gap = 300000;			// 5 mins of time delay for each link to click on the main/landing page

		var cnt = 0;					// checking if it is going p1, p2, p3 before entering into the next

		var from_cnt_p1 = 1;
		var to_cnt_p1 = 5;				// 1-5; 6-10; 11-15; 16-20; 21-26

		var from_cnt_p2 = 1;
		var to_cnt_p2 = 2;				// 1-10; 11-20; 21-30; 31-40; 41-50; 51-60; 61-70; 71-80; 81-90; 91-100

		var from_cnt_p3 = 1;
		var to_cnt_p3 = 2;				// 1-10; 11-20; 21-30; 31-40; 41-50; 51-60; 61-70; 71-80; 81-90; 91-100

		var from_cnt_p4 = 1;
		var to_cnt_p4 = 20;				// 1-20; don't change

		//P1: For the first landing page

		$(tab_source).find('.directory ol li a').each(function() {
			var hrefl = $(this).attr('href');

			if(cnt >= from_cnt_p1-1 && cnt <= to_cnt_p1-1) {		// doing from from_cnt_p1 link to to_cnt_p1 link
				//window.open(hrefl,'_self');

				if(cnt != from_cnt_p1-1) {							// initially, no delay
					delay = Number(delay) + Number(time_gap);
				}

				setTimeout(function() {
					console.log(new Date()+"\t Clicked on: "+hrefl);
					window.open(hrefl);
					window.close();
				}, delay);

				links += hrefl+"\n";
			}

			cnt = Number(cnt) + 1;
		});

		//message.innerText = links;
	} catch(err) {
		alert(err);
	}

	var page_no = 0;
	var myURL_temp = window.location.href;

	if(myURL_temp.indexOf("people-") >= 0) {
		var myURL_temp_split = myURL_temp.split("\/");

		var myURL_temp_last = myURL_temp_split[myURL_temp_split.length-2];

		if(myURL_temp_last.indexOf("people-") == 0) {
			var myURL_temp_last_split = myURL_temp_last.split("-");

			page_no = myURL_temp_last_split.length;
		}
	}

	//P2: For the 2nd page

	if(page_no == 2) {
		if(cnt == 0) {
			$(tab_source).find('.column li a').each(function() {
				var hrefl = $(this).attr('href');

				if(cnt >= from_cnt_p2-1 && cnt <= to_cnt_p2-1) {		//doing from from_cnt_p2 link to to_cnt_p2 link
					// if(cnt <= 3) {		//doing for first 4 links
					if(hrefl.indexOf('https:') !== -1 || hrefl.indexOf('http:') !== -1 ){
						//window.open(hrefl,'_self');

						setTimeout(function() {
							window.open(hrefl);
							window.close();
						}, 300);
					} else {
						basic = myURL.split('.com/');
						//window.open(basic[0]+'.com'+hrefl,'_self');

						setTimeout(function() {
							window.open(basic[0]+'.com'+hrefl);
							window.close();
						}, 300);
					}

					links += hrefl+"\n";
				}

				cnt = Number(cnt) + 1;
			});
		}
	}

	//P3: For the 3rd page

	if(page_no == 3) {
		if(cnt == 0) {
			$(tab_source).find('.column li a').each(function() {
				var hrefl = $(this).attr('href');

				if(cnt >= from_cnt_p3-1 && cnt <= to_cnt_p3-1) {		//doing from from_cnt_p3 link to to_cnt_p3 link
					// if(cnt <= 3) {		//doing for first 4 links
					if(hrefl.indexOf('https:') !== -1 || hrefl.indexOf('http:') !== -1 ){
						//window.open(hrefl,'_self');

						setTimeout(function() {
							window.open(hrefl);
							window.close();
						}, 300);
					} else {
						basic = myURL.split('.com/');
						//window.open(basic[0]+'.com'+hrefl,'_self');

						setTimeout(function() {
							window.open(basic[0]+'.com'+hrefl);
							window.close();
						}, 300);
					}

					links += hrefl+"\n";
				}

				cnt = Number(cnt) + 1;
			});
		}
	}

	//P4: For the 4th page

	if(page_no == 4) {
		if(cnt == 0) {
			$(tab_source).find('.column li a').each(function() {
				var hrefl = $(this).attr('href');

				if(cnt >= from_cnt_p4-1 && cnt <= to_cnt_p4-1) {		//doing from from_cnt_p4 link to to_cnt_p4 link
					// if(cnt <= 3) {		//doing for first 4 links
					if(hrefl.indexOf('https:') !== -1 || hrefl.indexOf('http:') !== -1 ){
						//window.open(hrefl,'_self');

						setTimeout(function() {
							window.open(hrefl);
							window.close();
						}, 300);
					} else {
						basic = myURL.split('.com/');
						//window.open(basic[0]+'.com'+hrefl,'_self');

						setTimeout(function() {
							window.open(basic[0]+'.com'+hrefl);
							window.close();
						}, 300);
					}

					links += hrefl+"\n";
				}

				cnt = Number(cnt) + 1;
			});
		}
	}

	//P5: For the 5th page, top 10 professionals list

	if(cnt == 0) {
		$(tab_source).find('.professionals ul li div div h3 a').each(function() {
			var hrefl = $(this).attr('href');

			//if(cnt <= 9) {		//doing for first 10 links
				if(hrefl.indexOf('https:') !== -1 || hrefl.indexOf('http:') !== -1 ){
					//window.open(hrefl,'_self');

					setTimeout(function() {
						window.open(hrefl);
						window.close();
					}, 300);
					//exportInputs(tab_source)
				} else {
					basic = myURL.split('.com/');
					//window.open(basic[0]+'.com'+hrefl,'_self');

					setTimeout(function() {
						window.open(basic[0]+'.com'+hrefl);
						window.close();
					}, 300);

					//exportInputs(tab_source)
				}

				links += hrefl+"\n";
			//}

			cnt = Number(cnt) + 1;
		});
	}

	//P6: For the 6th page, complete profile page

	// scraping the data from profile
	if(cnt == 0) {
		var pro_name;
		$(tab_source).find('.profile-card div div h1').each(function() {
			pro_name = $(this).text();
		});

		setTimeout(function() {
			exportInputs(pro_name, tab_source);
		}, 1000);

//			exportInputs(pro_name, tab_source);
	}

	console.log("links visited:\n"+links);

	//return html;
}

function exportInputs(pro_name, tab_source) {
	myURL = window.location.href;
	var myURL_parse = myURL.split("\/");

	var profile_url_name = "lin_"+myURL_parse[myURL_parse.length-1];

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
