var weekTemplate =
'<table class="table week" data-week="[WEEK-NUMBER]">' +
'	<tr>' +
'		<th>' +
'			Week [WEEK-NUMBER-DISPLAY]' +
'		</th>' +
'	</tr>' +
'	[SLOTS]' +
'</table>';

var tagPlaceholderTemplate = 
'<div class="tag-placeholder">[TEXT]' +
'</div>';

var slotTemplate =
'	<tr>' +
'		<td class="slot [CLASS]" data-week="[WEEK-NUMBER]" data-day="[DAY-NUMBER]" data-slot="[SLOT-NUMBER]">' + tagPlaceholderTemplate + '</td>' +
'	</tr>';

var tagTemplate = 
'<div class="tag panel panel-[PANEL-TYPE]" rel="tooltip" title="[TOOLTIP]" data-html="true" data-id="[ID]" data-serial="[SERIAL]" data-type="[TYPE]">' +
'	<div class="panel-heading">[SERIAL]</div>' +
'	<div class="panel-body">[TYPE]</div>' +
'</div>';

/*
var daySeparatorTemplate =
'	<tr>' +
'		<td>' +
'			<div class="day-separator"></div>' +
'		</td>' +
'	</tr>';
*/

var poolTemplate =
'<table id="pool-table" class="table pool" style="display:none;">' +
'	<tr>' +
'		<th colspan="10">' +
'			Tags Pool' +
'		</th>' +
'	</tr>' +
'	[SLOTS]' +
'</table>';

var poolSlotTemplate =
'<td class="slot" data-week="[WEEK-NUMBER]" data-day="[DAY-NUMBER]" data-slot="[SLOT-NUMBER]">' + tagPlaceholderTemplate + '</td>';

//window.onresize = setCellPlaceholderSize;
//$.widget.bridge('uitooltip', $.ui.tooltip); //****check if this is needed
window.onbeforeunload = confirmNavigateAway;

var numWeeks = 48	;
var numDays = 5;
var tagsPerDay = 8;
var weeksToBlock = 2;
var inDroppable = false;
//var weeks;
var tags = [];
var selectedSlotsInfo = []; //selectedCellsInfo
var transactions = [];
var redoStack = [];
var isError = false;
//var isDirty = false;

$(document).ready(function() {
	var contentHtml = '';

	//**** not required after connecting to salesforce
	if(!localStorage.tagsJson)
	{
		localStorage.tagsJson = tagsString;
	}
	tags = JSON.parse(localStorage.tagsJson);
	//

	// **** need to calculate number of weeks, days and slots dynamically for pool. also need to validate the tag moves with this number 
	for(var dayCount = 0; dayCount < 2; dayCount++) {
		for(var slotCount = 0; slotCount < tagsPerDay; slotCount++) { 
			contentHtml += '<tr>';
			for(var weekCount = 1; weekCount <= 10; weekCount++) {
				contentHtml += poolSlotTemplate.replace('[WEEK-NUMBER]', -weekCount).replace('[DAY-NUMBER]', dayCount).replace('[SLOT-NUMBER]', slotCount).replace('[TEXT]', -weekCount + ',' +  dayCount + ',' + slotCount);
			}
			contentHtml += '</tr>';
		}
	}

	$('#content').append(poolTemplate.replace('[SLOTS]', contentHtml));

	contentHtml = '';

	for(var weekCount = 0; weekCount < numWeeks; weekCount++) {
		var slots = '';

		for(var dayCount = 0; dayCount < numDays; dayCount++) {
			for(var slotCount = 0; slotCount < tagsPerDay; slotCount++) {
				var className = '';

				if(slotCount == tagsPerDay - 1) {
					className = 'bottom-border';
				} 


				 slots += slotTemplate.replace('[WEEK-NUMBER]', weekCount).replace('[DAY-NUMBER]', dayCount).replace('[SLOT-NUMBER]', slotCount).replace('[TEXT]', weekCount + ',' +  dayCount + ',' + slotCount).replace('[CLASS]', className);

			}
		
			//slots += daySeparatorTemplate;
		}

		contentHtml += weekTemplate.replace(/\[SLOTS\]/g, slots).replace(/\[WEEK-NUMBER\]/g, weekCount).replace('[WEEK-NUMBER-DISPLAY]', weekCount + 1);
	}

	$('#content').append(contentHtml);

	//weeks = $('.week');

	for(var tagsCount = 0; tagsCount < tags.length; tagsCount++) {
		var panelType;
		switch(tags[tagsCount].type) {
			case 'Diesel':
					panelType = 'danger';
					break;

			case 'CNG':
					panelType = 'success';
					break;

			case 'BRT':
					panelType = 'info';
					break;

			case 'BRT+':
					panelType = 'primary';
					break;

			case 'Hybrid':
					panelType = 'warning';
					break;
		}

		var toolTip = 'Customer Name: ' + tags[tagsCount].customerName + '<br/>Customer Id: ' + tags[tagsCount].customerId;

		var tag = tagTemplate.replace('[ID]', tags[tagsCount].id)
										.replace(/\[SERIAL\]/g, tags[tagsCount].serial)
										.replace(/\[TYPE\]/g, tags[tagsCount].type)
										.replace('[TOOLTIP]', toolTip)
										.replace('[PANEL-TYPE]', panelType);

		$('#content').find('[data-week=' + tags[tagsCount].position.week + '][data-day=' + tags[tagsCount].position.day + '][data-slot=' + tags[tagsCount].position.slot + ']').html(tag);
	}

	$('#content').find(".slot:not(:has(*))").html(tagPlaceholderTemplate); //**** should not be needed 

	$('.week').filter(':lt(' + weeksToBlock + ')').addClass('blocked-week');

	//weeks.filter(':gt(' + (weeksToBlock - 1) + ')').find('.draggable').draggable({
	$('#content').find('.tag').draggable({
		revert: true,

		revertDuration: 0,

		stack: ".tag",

		//delay: 100,

		//helper: 'clone',

		//containment: '#tags-content',

		start: function(event, ui) {
			$(this).tooltip('hide');

			if(!$(this).hasClass('multi-select')) {
				if(selectedSlotsInfo.length > 0) {
					//prevent dragging of unselected tag when multiple tags are selected
					return false;
				} else {
					//select slot on single tag drag
					selectSlot($(this));
				}
			}
		},

		stop: function(event, ui) {
			if(!inDroppable){
				$('.multi-select').css({
                	top: 0,
                	left: 0
            	});

				//clear selection on single tag drag; also in rule check fail for a tag
            	if(selectedSlotsInfo.length == 1) {
					clearSlotSelections();
				}
			}
		},

		drag: function(event, ui) {
			$(this).tooltip('hide');

			var zIndex = $(this).css('zIndex');

			$('.multi-select').css({
                top: ui.position.top,
                left: ui.position.left,
                zIndex: 20000 //zIndex
            });
		}
	});

	$('.slot').droppable({
		tolerance: "pointer",

        accept: ".tag",

		drop: function(event, ui) {
			var slot = $(this);
			var slotInfo = getSlotInfo(slot);
			slotInfo.id = $(ui.draggable[0]).attr('data-id');
			slotInfo.serial = $(ui.draggable[0]).attr('data-serial');
			slotInfo.type = $(ui.draggable[0]).attr('data-type');
			draggableDropped(slotInfo);
		},

  		over: function() { 
        	inDroppable = true; 
        },

        out: function() { 
        	inDroppable = false; 
        }
	});

	setTagPlaceholderSize();

/*
	if(!localStorage.showPool) {
		localStorage.showPool = "1";
		$('#pool-table').show();
	} else if(localStorage.showPool == "1") {
		$('#pool-table').show();
	} else {
		$('#pool-table').hide();
	}
*/

	highlightConsecutiveTags()

	$('[rel=tooltip]').tooltip({
		placement : function (context, source) {
	        var position = $(source).position();

	        if (position.left > 515) {
	            return "left";
	        }

	        if (position.left < 515) {
	            return "right";
	        }

	        if (position.top < 110) {
	            return "bottom";
	        }

	        return "top";
	    },

		trigger : 'manual'
	});
		
	$('.tag').on('tap', function(e) {
		//console.log('tap');
	    selectSlot($(this));
	});

	$('.tag').on('press', function(e) {
		var tag = $(this);
		tag.tooltip('show').on('mouseleave', function(){ tag.tooltip('hide'); });
	});

	if(!localStorage.showPool) {
		localStorage.showPool = "0";
		$('#pool-table').hide();
	} else if(localStorage.showPool == "1") {
		$('#pool-table').show();
	} else {
		$('#pool-table').hide();
	}

	checkTags();
}).disableSelection();
//***************************************** END OF ON READY


function draggableDropped(targetSlotInfo) { //target slot info only the dragged tag
	var isWeekToPool = (selectedSlotsInfo[0].week >= 0 && targetSlotInfo.week <= -1);
	var isPoolToWeek = (selectedSlotsInfo[0].week <= -1 && targetSlotInfo.week >= 0);
	var isPoolToPool = (selectedSlotsInfo[0].week <= -1 && targetSlotInfo.week <= -1);
	var isWeekToWeek = (selectedSlotsInfo[0].week >= 0 && targetSlotInfo.week >= 0);

	var findSourceSlotInfo = findInCollection(selectedSlotsInfo, targetSlotInfo.id);
	var sourceSlotInfo = findSourceSlotInfo.val; //source slot info of only the dragged tag
	var selectedSlotsNewInfo = [];
	var selectedTags = [];

	//detach all selected buses
	for(var index = 0; index < selectedSlotsInfo.length; index++) {
		var slot = $('#content').find('[data-week=' + selectedSlotsInfo[index].week + '][data-day=' + selectedSlotsInfo[index].day + '][data-slot=' + selectedSlotsInfo[index].slot + ']');
		selectedTags.push(slot.children().detach());
		slot.html(tagPlaceholderTemplate.replace('[TEXT]', selectedSlotsInfo[index].week + ',' +  selectedSlotsInfo[index].day + ',' + selectedSlotsInfo[index].slot));
	}

	//calculate new cell position and check rules
	for(var index = 0; index < selectedSlotsInfo.length; index++) {
		var slotInfo = new Object();
		slotInfo.id = selectedSlotsInfo[index].id;
		slotInfo.serial = selectedSlotsInfo[index].serial;
		slotInfo.type = selectedSlotsInfo[index].type;

		//find distance of the tag from the dragged tag, and add to it the dropped location
		if(isWeekToWeek || isPoolToPool) {
			slotInfo.week = targetSlotInfo.week + (selectedSlotsInfo[index].week - sourceSlotInfo.week);
		} else {
			slotInfo.week = targetSlotInfo.week - (selectedSlotsInfo[index].week - sourceSlotInfo.week); //because week changes from positive to negative when moved from tags-week to tags-pool and vice versa 
		}

		slotInfo.day = targetSlotInfo.day + (selectedSlotsInfo[index].day - sourceSlotInfo.day);
		slotInfo.slot = targetSlotInfo.slot + (selectedSlotsInfo[index].slot - sourceSlotInfo.slot);
		
		if(slotInfo.slot < 0) {
	 		slotInfo.day--;
	 		slotInfo.slot += tagsPerDay;
	 	} else if(slotInfo.slot >= tagsPerDay) {
	 		slotInfo.day++;
	 		slotInfo.slot -= tagsPerDay;
	 	}

	 	if(slotInfo.day < 0) {
	 		slotInfo.week--;
	 		slotInfo.day += 5; // **** check this for working saturdays
	 	} else if(slotInfo.day > 4) {
	 		slotInfo.week++;
	 		slotInfo.day -= 5; // **** check this for working saturdays
	 	}

		//if slot rules fail for any of the selected slot, then restore all selected tags to their original position
	 	if(!checkSlotValid(selectedSlotsInfo[index], slotInfo)) {
	 		console.log('[' + selectedSlotsInfo[index].week + ',' + selectedSlotsInfo[index].day +',' + selectedSlotsInfo[index].slot + '] [' + slotInfo.week + ',' + slotInfo.day + ',' + slotInfo.slot + ']');


	 		$('#content').find('.multi-select').css({
                top: 0,
                left: 0
            });

	 		for(var count = 0; count < selectedSlotsInfo.length; count++) {
				$('#content').find('[data-week=' + selectedSlotsInfo[count].week + '][data-day=' + selectedSlotsInfo[count].day + '][data-slot=' + selectedSlotsInfo[count].slot + ']').html(
					selectedTags[count].removeAttr('style').css('position', 'relative')
				);
			}

			//clear selection on single tag drag; also in drag stop event
			if(selectedSlotsInfo.length == 1) {
				clearSlotSelections();
			}

			setTagPlaceholderSize();
			checkTags();

	 		return false;
	 	}

	 	selectedSlotsNewInfo.push(slotInfo);
	}

	var transaction = [];

	//insert into new location and build transaction
	for(var index = 0; index < selectedSlotsNewInfo.length; index++) {
		$('#content').find('[data-week=' + selectedSlotsNewInfo[index].week + '][data-day=' + selectedSlotsNewInfo[index].day + '][data-slot=' + selectedSlotsNewInfo[index].slot + ']').html(
			selectedTags[index].removeAttr('style').css('position', 'relative')
		);

		var subTransaction = new Object();
		subTransaction.position = selectedSlotsNewInfo[index];
		subTransaction.oldPosition = selectedSlotsInfo[index];
		transaction.push(subTransaction);
	}

	transactions.push(transaction);
	redoStack = [];

	setTagPlaceholderSize();
	highlightConsecutiveTags();
	clearSlotSelections();
	updateHeader();

	return true;
}

//source slot info of the current tag, target slot info of the current tag. these are not source and target of only dragged tag. this is for every tag that is being moved.
function checkSlotValid(sourceSlotInfo, targetSlotInfo) {
	if(sourceSlotInfo.week == targetSlotInfo.week && sourceSlotInfo.day == targetSlotInfo.day && sourceSlotInfo.slot == targetSlotInfo.slot) {
		console.log('validation fail: drag and drop at same slot');
		return false;
	}

	var slot = $('[data-week=' + targetSlotInfo.week + '][data-day=' + targetSlotInfo.day + '][data-slot=' + targetSlotInfo.slot + ']');

	if(slot.length == 0) {
		console.log('validation fail: invalid slot number');
		return false;
	}

	if(slot.children('.tag').length > 0) {
		console.log('validation fail: slot already has a tag');
		return false;
	}

	return true;
}

function highlightConsecutiveTags(){
    var weeks = $('.week');

    weeks.find('td').removeClass('bg-danger');

	for(var weekCount = 0; weekCount < weeks.length; weekCount++ ) {
		var slots = $(weeks[weekCount]).find('td');

		for(slotCount = 0; slotCount < slots.length - 1; slotCount++) {
			var slot1 = $(slots[slotCount]).find('.tag').attr('data-type');
			var slot2 = $(slots[slotCount + 1]).find('.tag').attr('data-type');

			if(slot1 && slot2 && slot1 == slot2) {
				$(slots[slotCount]).addClass('bg-danger');
				$(slots[slotCount + 1]).addClass('bg-danger');
			}
		}
	}
}

function getSlotInfo(slot) {
	var slotInfo = new Object();

	var tag = slot.find('.tag');
	slotInfo.id = tag.data('id');
	slotInfo.serial = tag.data('serial');
	slotInfo.type = tag.data('type');

	slotInfo.week = Number(slot.data('week'));
	slotInfo.day = Number(slot.data('day'));
	slotInfo.slot = Number(slot.data('slot'));

	return slotInfo;
}

function selectSlot(tag) {
	//**** clear selection on any filter change

	slot = tag.parent();

	var slotInfo = getSlotInfo(slot);

	//Allow either only tags-week or only tags-pool to be selected
	if(selectedSlotsInfo.length > 0) {
		var isPreviousSelectedPool = (selectedSlotsInfo[0].week <= -1);
		var isCurrentSelectedPool = (slotInfo.week <= -1);

		if(isPreviousSelectedPool != isCurrentSelectedPool){
			return;
		}
	}

	var existingSlotInfo = findInCollection(selectedSlotsInfo, slotInfo.id);

	if(existingSlotInfo.index > -1) {
		tag.removeClass("multi-select");
		selectedSlotsInfo.splice(existingSlotInfo.index, 1);
		slot.removeClass('bg-info');
	} else {
		tag.addClass("multi-select");
		selectedSlotsInfo.push(slotInfo);
		slot.addClass('bg-info');
	}

	updateSelectedSlotsMessage();
}

function clearSlotSelections() {
	$('.bg-info').removeClass('bg-info');
	$('.multi-select').removeClass('multi-select');
	selectedSlotsInfo = [];
	updateSelectedSlotsMessage();
	return false;
}

function updateSelectedSlotsMessage() {
	if(selectedSlotsInfo.length > 0){
		$("#selectedSlotsCount").text('Selected ' + selectedSlotsInfo.length + ' tag(s)').show();
		$("#selectedSlotsClear").attr('disabled', false);
	} else {
		$("#selectedSlotsCount").hide();
		$("#selectedSlotsClear").attr('disabled', true);
	}
}

function findInTags(id) {
	for(var index = 0; index < tags.length; index++) {
		if(tags[index].id == String(id)){
			return tags[index];
		}
	}
}

function findInCollection(collection, id) {
	var returnVal = new Object();
	returnVal.index = -1;
			
	for(var index = 0; index < collection.length; index++) {
		if(collection[index].id == String(id)){
			returnVal.index = index;
			returnVal.val = collection[index];
			break;
		}
	}

	return returnVal;
}

function save() {
	if(!isError) {
		//**** clear selection??

		var saveTags = [];

		for(var outer = transactions.length - 1; outer >= 0; outer--) {
			for(var inner = 0; inner < transactions[outer].length; inner++) {
				if(findInCollection(saveTags, transactions[outer][inner].position.id).index == "-1") {
					var tag = new Object();

					tag.position = transactions[outer][inner].position;
					tag.id = tag.position.id;
					tag.serial = tag.position.serial;

					delete tag.position.id;
					delete tag.position.serial;

					saveTags.push(tag);
				}
			}
		}

		transactions = [];
		redoStack = [];

		for(var index = 0; index < saveTags.length; index++) {
			findInTags(saveTags[index].id).position = saveTags[index].position;
		}

		// **** update to SF
		localStorage.tagsJson = JSON.stringify(tags);

		updateHeader();
	}
}

function updateHeader() {
	if(transactions.length == 0 && redoStack.length == 0) {
		disableUndo(true);
		disableRedo(true);
		disableSave(true);
	} else if(transactions.length != 0 && redoStack.length != 0) {
		disableUndo(false);
		disableRedo(false);
		disableSave(false);
	} else if(transactions.length == 0 && redoStack.length != 0) {
		disableUndo(true);
		disableRedo(false);
		disableSave(true);
	} else if(transactions.length != 0 && redoStack.length == 0) {
		disableUndo(false);
		disableRedo(true);
		disableSave(false);
	}

	checkTags();
}

function weekFilterChanged() {
	var weeks = $('.week');

	weeks.hide();

	var from = $('#weekFrom').val();
	var to = $('#weekTo').val();

	if(from == 'from') {
		from = 1;
	}

	if(to == 'to') {
		to = weeks.length;
	}

	weeks.slice(from - 1, to).show();
}

function undo(){
	clearSlotSelections();
	var transaction = transactions.pop();

	for(var index = 0; index < transaction.length; index++) {
		var sourceSlot = $('#content').find('[data-week=' + transaction[index].position.week + '][data-day=' + transaction[index].position.day + '][data-slot=' + transaction[index].position.slot + ']');

		$('#content').find('[data-week=' + transaction[index].oldPosition.week + '][data-day=' + transaction[index].oldPosition.day + '][data-slot=' + transaction[index].oldPosition.slot + ']').html(
			sourceSlot.children()
		);

		sourceSlot.html(tagPlaceholderTemplate.replace('[TEXT]', transaction[index].position.week + ',' +  transaction[index].position.day + ',' + transaction[index].position.slot));
	}

	redoStack.push(transaction);

	setTagPlaceholderSize();
	highlightConsecutiveTags();
	updateHeader();

	return false;
}

function redo(){
	clearSlotSelections();
	var transaction = redoStack.pop();

	for(var index = 0; index < transaction.length; index++) {
		var sourceSlot = $('#content').find('[data-week=' + transaction[index].oldPosition.week + '][data-day=' + transaction[index].oldPosition.day + '][data-slot=' + transaction[index].oldPosition.slot + ']');

		$('#content').find('[data-week=' + transaction[index].position.week + '][data-day=' + transaction[index].position.day + '][data-slot=' + transaction[index].position.slot + ']').html(
			sourceSlot.children()
		);

		sourceSlot.html(tagPlaceholderTemplate.replace('[TEXT]', transaction[index].oldPosition.week + ',' +  transaction[index].oldPosition.day + ',' + transaction[index].oldPosition.slot));
	}

	transactions.push(transaction);

	setTagPlaceholderSize();
	highlightConsecutiveTags();
	updateHeader();

	return false;
}

function disableSave(val) {
	if(!isError) {
		$('#save').attr('disabled', val);

		if(val) {
			$("#header").removeClass('tags-not-saved').addClass('tags-saved');
		} else {
			$("#header").removeClass('tags-saved').addClass('tags-not-saved');
		}
	}
}

function disableUndo(val) {
	$('#undo').attr('disabled', val);
}

function disableRedo(val) {
	$('#redo').attr('disabled', val);
}

function checkTags() {
	var tagCollectionSize = tags.length;
	draggableSize = $('.tag').length;

	if(tagCollectionSize != draggableSize) {
		disableSave(true);
		$("#header").removeClass('tags-not-saved').removeClass('tags-saved').addClass('tags-error');
		isError = true;

		var message = 'Houston, we\'ve got a problem! 404: One or more tags are missing. [json:' + tagCollectionSize + ', tag:' + draggableSize + ']';
		console.log(message);
		alert(message);
	} else {
		//console.log('Tags count correct.');
	}
}

function setTagPlaceholderSize() {
	var tag = $('.week .tag:visible:eq(0)');
	$('.tag-placeholder').css('height', tag.outerHeight()).css('width', tag.outerWidth());
}

function showPool() {
	if(localStorage.showPool == "0") {
		localStorage.showPool = "1"
		$('#pool-table').show();
	} else {
		localStorage.showPool = "0"
		$('#pool-table').hide();
	}
}

function typeChanged(val) {
	var searchString = $(val).val().toLowerCase();

	if(searchString) {
		$('.tag').addClass('grayout').children('div').filter(function(index) { return $(this).text().toLowerCase() == searchString; }).parent().removeClass('grayout');
	} else {
		$('.tag').removeClass('grayout');
	}
}

function confirmNavigateAway() {
	if(!isError) {
		if(transactions.length > 0) {
			if(confirm()) {
				return true;
			} else {
				return false;
			}
		}
	}
}