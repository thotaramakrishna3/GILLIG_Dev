//*** TEMP FUNCTIONS
function add(serial, type, customerId, customerName, week, day, slot) {
	var bus = new Object();
	bus.id = "0";
	bus.serial = serial;
	bus.type = type;
	bus.customerId = customerId;
	bus.customerName = customerName;

	var position = new Object();
	position.week = week;
	position.day = day;
	position.slot = slot;

	bus.position = position;

	if(tags.length > 0){
		var max = -1;
	
		for(var count = 0; count < tags.length; count++){
			var idNum = Number(tags[count].id);

			if(idNum > max){
				max = idNum;
			}
		}

		bus.id = String(max + 1);
	}

	tags.push(bus);
	localStorage.tagsJson = JSON.stringify(tags);
}

function del(id) {
	for(var count = 0; count < tags.length; count++){
		if(tags[count].id == String(id)){
			tags.splice(count, 1);
			localStorage.tagsJson = JSON.stringify(tags);
			break;
		}
	}
}

function clr() { localStorage.removeItem('tagsJson'); localStorage.removeItem('showPool'); }
var cls = clr;

function printTran(id){
	console.log('** Printing transactions at index ' + id);

	for(var index = 0; index < transactions[id].length; index++) {
		//Console.log("")
		console.log('Id: ' + transactions[id][index].position.id + 
				', Pos: [' + transactions[id][index].oldPosition.week + ',' + transactions[id][index].oldPosition.day + ',' + transactions[id][index].oldPosition.slot + '] [' +
				transactions[id][index].position.week + ',' + transactions[id][index].position.day + ',' + transactions[id][index].position.slot + ']');
	}
	
	console.log('** End print');
}

var tagsString = 
	'[' +
	//week 1
	'{"id":"0","serial":"RW17T1J","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":0,"day":0,"slot":0}},' +
	'' +
	'{"id":"2","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":0,"day":2,"slot":0}},' +
	'{"id":"3","serial":"Z4J9E4X","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":0,"day":3,"slot":0}},' +
	'{"id":"4","serial":"2LFBT4P","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":4,"slot":0}},' +

	'{"id":"5","serial":"341PW80","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":0,"day":0,"slot":1}},' +
	'{"id":"6","serial":"KI1ABHM","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":1,"slot":1}},' +
	'{"id":"7","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":0,"day":2,"slot":1}},' +
	'' +
	'' +

	'{"id":"10","serial":"GJZYN26","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":0,"day":0,"slot":2}},' +
	'{"id":"11","serial":"0S46JZX","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":0,"day":1,"slot":2}},' +
	'{"id":"12","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":2,"slot":2}},' +
	'{"id":"13","serial":"V154VU3","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":0,"day":3,"slot":2}},' +
	'{"id":"14","serial":"H7A3JKH","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":4,"slot":2}},' +
	
	'' +
	'{"id":"16","serial":"36CP2BG","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":0,"day":1,"slot":3}},' +
	'{"id":"17","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":0,"day":2,"slot":3}},' +
	'{"id":"18","serial":"Z9FWIDF","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":0,"day":3,"slot":3}},' +
	'{"id":"19","serial":"U7MID7I","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":0,"day":4,"slot":3}},' +
	
	'{"id":"20","serial":"SFXMXLX","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":0,"day":0,"slot":4}},' +
	'{"id":"21","serial":"Z5B61E3","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":0,"day":1,"slot":4}},' +
	'{"id":"22","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":0,"day":2,"slot":4}},' +
	'' +
	'{"id":"24","serial":"T89J95L","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":0,"day":4,"slot":4}},' +
	
	'{"id":"25","serial":"JBQB7LX","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":0,"day":0,"slot":5}},' +
	'{"id":"26","serial":"BOIIRWM","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":0,"day":1,"slot":5}},' +
	'' +
	'{"id":"28","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":3,"slot":5}},' +
	'{"id":"29","serial":"9IO996H","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":0,"day":4,"slot":5}},' +

	'{"id":"30","serial":"R1I7TQW","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":0,"day":0,"slot":6}},' +
	'' +
	'{"id":"32","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":0,"day":2,"slot":6}},' +
	'{"id":"33","serial":"TASA6G1","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":0,"day":3,"slot":6}},' +
	'{"id":"34","serial":"CB5NHGS","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":0,"day":4,"slot":6}},' +

	'{"id":"35","serial":"WUGIINB","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":0,"day":0,"slot":7}},' +
	'{"id":"36","serial":"XAPIV7N","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":0,"day":1,"slot":7}},' +
	'{"id":"37","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":0,"day":2,"slot":7}},' +
	'' +
	'' +

	//week 2
	'{"id":"40","serial":"RW17T1J","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":1,"day":0,"slot":0}},' +
	'' +
	'{"id":"42","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":1,"day":2,"slot":0}},' +
	'{"id":"43","serial":"Z4J9E4X","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":1,"day":3,"slot":0}},' +
	'{"id":"44","serial":"2LFBT4P","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":4,"slot":0}},' +

	'{"id":"45","serial":"341PW80","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":1,"day":0,"slot":1}},' +
	'{"id":"46","serial":"KI1ABHM","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":1,"slot":1}},' +
	'{"id":"47","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":1,"day":2,"slot":1}},' +
	'' +
	'' +

	'{"id":"50","serial":"GJZYN26","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":1,"day":0,"slot":2}},' +
	'{"id":"51","serial":"0S46JZX","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":1,"day":1,"slot":2}},' +
	'{"id":"52","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":2,"slot":2}},' +
	'{"id":"53","serial":"V154VU3","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":1,"day":3,"slot":2}},' +
	'{"id":"54","serial":"H7A3JKH","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":4,"slot":2}},' +
	
	'' +
	'{"id":"56","serial":"36CP2BG","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":1,"day":1,"slot":3}},' +
	'{"id":"57","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":1,"day":2,"slot":3}},' +
	'{"id":"58","serial":"Z9FWIDF","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":1,"day":3,"slot":3}},' +
	'{"id":"59","serial":"U7MID7I","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":1,"day":4,"slot":3}},' +
	
	'{"id":"60","serial":"SFXMXLX","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":1,"day":0,"slot":4}},' +
	'{"id":"61","serial":"Z5B61E3","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":1,"day":1,"slot":4}},' +
	'{"id":"62","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":1,"day":2,"slot":4}},' +
	'' +
	'{"id":"64","serial":"T89J95L","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":1,"day":4,"slot":4}},' +
	
	'{"id":"65","serial":"JBQB7LX","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":1,"day":0,"slot":5}},' +
	'{"id":"66","serial":"BOIIRWM","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":1,"day":1,"slot":5}},' +
	'' +
	'{"id":"68","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":3,"slot":5}},' +
	'{"id":"69","serial":"9IO996H","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":1,"day":4,"slot":5}},' +

	'{"id":"70","serial":"R1I7TQW","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":1,"day":0,"slot":6}},' +
	'' +
	'{"id":"72","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":1,"day":2,"slot":6}},' +
	'{"id":"73","serial":"TASA6G1","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":1,"day":3,"slot":6}},' +
	'{"id":"74","serial":"CB5NHGS","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":1,"day":4,"slot":6}},' +

	'{"id":"75","serial":"WUGIINB","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":1,"day":0,"slot":7}},' +
	'{"id":"76","serial":"XAPIV7N","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":1,"day":1,"slot":7}},' +
	'{"id":"77","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":1,"day":2,"slot":7}},' +
	'' +
	'' +

	//week3
	'{"id":"80","serial":"RW17T1J","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":2,"day":0,"slot":0}},' +
	'' +
	'{"id":"82","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":2,"day":2,"slot":0}},' +
	'{"id":"83","serial":"Z4J9E4X","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":2,"day":3,"slot":0}},' +
	'{"id":"84","serial":"2LFBT4P","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":4,"slot":0}},' +

	'{"id":"85","serial":"341PW80","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":2,"day":0,"slot":1}},' +
	'{"id":"86","serial":"KI1ABHM","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":1,"slot":1}},' +
	'{"id":"87","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":2,"day":2,"slot":1}},' +
	'' +
	'' +

	'{"id":"90","serial":"GJZYN26","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":2,"day":0,"slot":2}},' +
	'{"id":"91","serial":"0S46JZX","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":2,"day":1,"slot":2}},' +
	'{"id":"92","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":2,"slot":2}},' +
	'{"id":"93","serial":"V154VU3","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":2,"day":3,"slot":2}},' +
	'{"id":"94","serial":"H7A3JKH","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":4,"slot":2}},' +
	
	'' +
	'{"id":"96","serial":"36CP2BG","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":2,"day":1,"slot":3}},' +
	'{"id":"97","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":2,"day":2,"slot":3}},' +
	'{"id":"98","serial":"Z9FWIDF","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":2,"day":3,"slot":3}},' +
	'{"id":"99","serial":"U7MID7I","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":2,"day":4,"slot":3}},' +
	
	'{"id":"100","serial":"SFXMXLX","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":2,"day":0,"slot":4}},' +
	'{"id":"101","serial":"Z5B61E3","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":2,"day":1,"slot":4}},' +
	'{"id":"102","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":2,"day":2,"slot":4}},' +
	'' +
	'{"id":"104","serial":"T89J95L","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":2,"day":4,"slot":4}},' +
	
	'{"id":"105","serial":"JBQB7LX","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":2,"day":0,"slot":5}},' +
	'{"id":"106","serial":"BOIIRWM","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":2,"day":1,"slot":5}},' +
	'' +
	'{"id":"108","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":3,"slot":5}},' +
	'{"id":"109","serial":"9IO996H","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":2,"day":4,"slot":5}},' +

	'{"id":"110","serial":"R1I7TQW","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":2,"day":0,"slot":6}},' +
	'' +
	'{"id":"112","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":2,"day":2,"slot":6}},' +
	'{"id":"113","serial":"TASA6G1","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":2,"day":3,"slot":6}},' +
	'{"id":"114","serial":"CB5NHGS","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":2,"day":4,"slot":6}},' +

	'{"id":"115","serial":"WUGIINB","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":2,"day":0,"slot":7}},' +
	'{"id":"116","serial":"XAPIV7N","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":2,"day":1,"slot":7}},' +
	'{"id":"117","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":2,"day":2,"slot":7}},' +
	'' +
	'' +

	//week4
	'{"id":"120","serial":"RW17T1J","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":3,"day":0,"slot":0}},' +
	'' +
	'{"id":"122","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":3,"day":2,"slot":0}},' +
	'{"id":"123","serial":"Z4J9E4X","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":3,"day":3,"slot":0}},' +
	'{"id":"124","serial":"2LFBT4P","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":4,"slot":0}},' +

	'{"id":"125","serial":"341PW80","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":3,"day":0,"slot":1}},' +
	'{"id":"126","serial":"KI1ABHM","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":1,"slot":1}},' +
	'{"id":"127","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":3,"day":2,"slot":1}},' +
	'' +
	'' +

	'{"id":"130","serial":"GJZYN26","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":3,"day":0,"slot":2}},' +
	'{"id":"131","serial":"0S46JZX","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":3,"day":1,"slot":2}},' +
	'{"id":"132","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":2,"slot":2}},' +
	'{"id":"133","serial":"V154VU3","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":3,"day":3,"slot":2}},' +
	'{"id":"134","serial":"H7A3JKH","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":4,"slot":2}},' +
	
	'' +
	'{"id":"136","serial":"36CP2BG","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":3,"day":1,"slot":3}},' +
	'{"id":"137","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":3,"day":2,"slot":3}},' +
	'{"id":"138","serial":"Z9FWIDF","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":3,"day":3,"slot":3}},' +
	'{"id":"139","serial":"U7MID7I","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":3,"day":4,"slot":3}},' +
	
	'{"id":"140","serial":"SFXMXLX","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":3,"day":0,"slot":4}},' +
	'{"id":"141","serial":"Z5B61E3","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":3,"day":1,"slot":4}},' +
	'{"id":"142","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":3,"day":2,"slot":4}},' +
	'' +
	'{"id":"144","serial":"T89J95L","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":3,"day":4,"slot":4}},' +
	
	'{"id":"145","serial":"JBQB7LX","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":3,"day":0,"slot":5}},' +
	'{"id":"146","serial":"BOIIRWM","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":3,"day":1,"slot":5}},' +
	'' +
	'{"id":"148","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":3,"slot":5}},' +
	'{"id":"149","serial":"9IO996H","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":3,"day":4,"slot":5}},' +

	'{"id":"150","serial":"R1I7TQW","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":3,"day":0,"slot":6}},' +
	'' +
	'{"id":"152","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":3,"day":2,"slot":6}},' +
	'{"id":"153","serial":"TASA6G1","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":3,"day":3,"slot":6}},' +
	'{"id":"154","serial":"CB5NHGS","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":3,"day":4,"slot":6}},' +

	'{"id":"155","serial":"WUGIINB","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":3,"day":0,"slot":7}},' +
	'{"id":"156","serial":"XAPIV7N","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":3,"day":1,"slot":7}},' +
	'{"id":"157","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":3,"day":2,"slot":7}},' +
	'' +
	'' +

	//week5
	'{"id":"160","serial":"RW17T1J","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":4,"day":0,"slot":0}},' +
	'' +
	'{"id":"162","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":4,"day":2,"slot":0}},' +
	'{"id":"163","serial":"Z4J9E4X","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":4,"day":3,"slot":0}},' +
	'{"id":"164","serial":"2LFBT4P","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":4,"slot":0}},' +

	'{"id":"165","serial":"341PW80","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":4,"day":0,"slot":1}},' +
	'{"id":"166","serial":"KI1ABHM","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":1,"slot":1}},' +
	'{"id":"167","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":4,"day":2,"slot":1}},' +
	'' +
	'' +

	'{"id":"170","serial":"GJZYN26","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":4,"day":0,"slot":2}},' +
	'{"id":"171","serial":"0S46JZX","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":4,"day":1,"slot":2}},' +
	'{"id":"172","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":2,"slot":2}},' +
	'{"id":"173","serial":"V154VU3","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":4,"day":3,"slot":2}},' +
	'{"id":"174","serial":"H7A3JKH","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":4,"slot":2}},' +
	
	'' +
	'{"id":"176","serial":"36CP2BG","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":4,"day":1,"slot":3}},' +
	'{"id":"177","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":4,"day":2,"slot":3}},' +
	'{"id":"178","serial":"Z9FWIDF","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":4,"day":3,"slot":3}},' +
	'{"id":"179","serial":"U7MID7I","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":4,"day":4,"slot":3}},' +
	
	'{"id":"180","serial":"SFXMXLX","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":4,"day":0,"slot":4}},' +
	'{"id":"181","serial":"Z5B61E3","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":4,"day":1,"slot":4}},' +
	'{"id":"182","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":4,"day":2,"slot":4}},' +
	'' +
	'{"id":"184","serial":"T89J95L","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":4,"day":4,"slot":4}},' +
	
	'{"id":"185","serial":"JBQB7LX","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":4,"day":0,"slot":5}},' +
	'{"id":"186","serial":"BOIIRWM","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":4,"day":1,"slot":5}},' +
	'' +
	'{"id":"188","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":3,"slot":5}},' +
	'{"id":"189","serial":"9IO996H","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":4,"day":4,"slot":5}},' +

	'{"id":"190","serial":"R1I7TQW","type":"BRT+","customerId":"B345","customerName":"Apple","position":{"week":4,"day":0,"slot":6}},' +
	'' +
	'{"id":"192","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":4,"day":2,"slot":6}},' +
	'{"id":"193","serial":"TASA6G1","type":"BRT","customerId":"A123","customerName":"Dell","position":{"week":4,"day":3,"slot":6}},' +
	'{"id":"194","serial":"CB5NHGS","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":4,"day":4,"slot":6}},' +

	'{"id":"195","serial":"WUGIINB","type":"BRT","customerId":"B345","customerName":"Apple","position":{"week":4,"day":0,"slot":7}},' +
	'{"id":"196","serial":"XAPIV7N","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":4,"day":1,"slot":7}},' +
	'{"id":"197","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":4,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 6
	'' +
	'' +
	'{"id":"202","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":5,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"207","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"212","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"217","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"222","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":5,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"227","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"232","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"237","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":5,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 7
	'' +
	'' +
	'{"id":"242","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":6,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"247","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"252","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"257","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"262","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":6,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"267","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"272","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"277","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":6,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 8
	'' +
	'' +
	'{"id":"282","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":7,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"287","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"292","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"297","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"302","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":7,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"307","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"312","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"317","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":7,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 9
	'' +
	'' +
	'{"id":"322","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":8,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"327","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"332","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"337","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"342","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":8,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"347","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"352","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"357","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":8,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 10
	'' +
	'' +
	'{"id":"362","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":9,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"367","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"372","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"377","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"382","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":9,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"387","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"392","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"397","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":9,"day":2,"slot":7}},' +
	'' +
	'' +

	// week 11
	'' +
	'' +
	'{"id":"402","serial":"8C1M809","type":"CNG","customerId":"B345","customerName":"Apple","position":{"week":10,"day":2,"slot":0}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"407","serial":"QEVILPQ","type":"BRT+","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":1}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"412","serial":"MC01R4K","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":2}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"417","serial":"1TPMQI6","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":3}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"422","serial":"646RPKS","type":"Diesel","customerId":"B345","customerName":"Apple","position":{"week":10,"day":2,"slot":4}},' +
	'' +
	'' +
	
	'' +
	'' +
	'{"id":"427","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":5}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"432","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":6}},' +
	'' +
	'' +

	'' +
	'' +
	'{"id":"437","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":10,"day":2,"slot":7}},' +
	'' +
	'' +

	//Buffer pool
	'{"id":"1001","serial":"J5VAX4C","type":"CNG","customerId":"A123","customerName":"Dell","position":{"week":-1,"day":1,"slot":0}},' +
	'{"id":"1002","serial":"SJS8XE1","type":"Diesel","customerId":"A123","customerName":"Dell","position":{"week":-1,"day":1,"slot":3}},' +
	'{"id":"1003","serial":"G6AI2QQ","type":"Hybrid","customerId":"A123","customerName":"Dell","position":{"week":-1,"day":1,"slot":5}}' +

	']';
//**** END OF TEMP