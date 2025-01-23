import {modifieduserlist, getmoddeddate, getselectedformandetails, preassignforeman, preassignqc, setstatusfordisplay}  from 'c/userPermissionsComponent';
import getcrewingsuserslist from "@salesforce/apex/CrewingScheduleController.getcrewingsuserslist";
  // To modify the Department Discrepancy data for Ecard App and related components.
export function getmodifieddiscrepancylist(departmentdata,busname,buschasisnumber,departmentIdMap,empid){
    var departmentid = departmentdata.department_id;
    var departmentqc = modifieduserlist(departmentdata.qc);
    var discrepancylogs = departmentdata.discrepancylog;
    var modifieddiscrepancyList = [];
    var prod_supervisor = modifieduserlist(departmentdata.prod_supervisor);
    for(var disc in discrepancylogs){
        var index = Number(disc)+1;
        var moddedprod = modifieduserlist(discrepancylogs[disc].prod);
        var assignedprod = getselectedformandetails(discrepancylogs[disc]);
        var assigend_qc_id = modifieduserlist([discrepancylogs[disc].assigend_qc_id]);
        var qc_avilable=assigend_qc_id.length!=0?true:false;
        var verifiedby = modifieduserlist([discrepancylogs[disc].verifiedby_id]);
        var resolved_status_updatedby_id = modifieduserlist([discrepancylogs[disc].resolved_status_updatedby_id]);
        var created_by = modifieduserlist([discrepancylogs[disc].createdby_id]);
        var raised_date = getmoddeddate(discrepancylogs[disc].raised_date);
        var createdbyname;
        var createdbyempid=undefined;
        var displaycreatedbyname;
        var is_deletable=false;
        var customernamewithchasis = `${busname}, ${buschasisnumber}`;
        //var department_name = this.selecteddepartment;
        if(created_by != undefined && created_by.length != 0){
             if(created_by[0]!=undefined){
                 displaycreatedbyname = `${created_by[0].name} (${created_by[0].userid}) on ${raised_date}`;
                 createdbyname = `${created_by[0].name} (${created_by[0].userid})`;
                 createdbyempid= `${created_by[0].userid}`;

             }
        }
        if((createdbyempid==empid) && (discrepancylogs[disc].discrepancy_status.toLowerCase()=="open")){
            is_deletable=true;
        }
        var isdepartmentdiscrepancy = false;
        if(discrepancylogs[disc].discrepancy_type == 'department'){
            // assignedprod = prod_supervisor;
            moddedprod = prod_supervisor;
            isdepartmentdiscrepancy = true;
        }
        var isdownstreamdiscrepancy = false;
        if (discrepancylogs[disc].discrepancy_type == "downstream") {
            isdownstreamdiscrepancy = true;
        }
        //newly added
        var isshortdiscrepancy = false;
        if (discrepancylogs[disc].discrepancy_type == "short") {
            isshortdiscrepancy = true;
        }
        moddedprod = updateprodlistwithforeman(assignedprod,moddedprod);
        var bsavailable=discrepancylogs[disc].buildstation_code=='9999'?false:true;
        let dept_updatedby_fullname;
                        var dept_updatedbyuser = discrepancylogs[disc].dept_updatedby_id;
                        if(dept_updatedbyuser == null){
                            dept_updatedby_fullname = null;
                        }else{
                            dept_updatedby_fullname = discrepancylogs[disc].dept_updatedby_id.first_name+' '+discrepancylogs[disc].dept_updatedby_id.last_name;

                        }
        var moddeddiscrepancy = {
            index: index,
            departmentid : departmentid,
            departmentcode : getdepartmentcode(departmentid,departmentIdMap),
            modified_date : discrepancylogs[disc].modified_date,
            ecard_discrepancy_log_id : discrepancylogs[disc].ecard_discrepancy_log_id,
            ecard_discrepancy_log_number: discrepancylogs[disc].discrepancy_log_number,
            isdepartmentdiscrepancy : isdepartmentdiscrepancy,
            isdownstreamdiscrepancy: isdownstreamdiscrepancy,
            isshortdiscrepancy: isshortdiscrepancy, //newly added
            isdeletable:is_deletable,
            created_by : created_by,
            createdbyname : createdbyname,
            displaycreatedbyname : displaycreatedbyname,
            discrepancy_priority : discrepancylogs[disc].discrepancy_priority,
            customernamewithchasis : customernamewithchasis,
            first_name : discrepancylogs[disc].first_name,
            last_name : discrepancylogs[disc].last_name,
            ecard_id : discrepancylogs[disc].ecard_id,
            customername : `${discrepancylogs[disc].customer_name}`,//`${discrepancylogs[disc].first_name} ${discrepancylogs[disc].last_name}`,
            chassis_no : discrepancylogs[disc].chassis_no,
            department_name : discrepancylogs[disc].department_name,
            department_id : discrepancylogs[disc].department_id,
            busstatus_name : discrepancylogs[disc].busstatus_name, 
            workcenter_name : discrepancylogs[disc].workcenter_name,
            assigend_qc_id : discrepancylogs[disc].assigend_qc_id,
            qcavailable:qc_avilable,
            buildstation_code: discrepancylogs[disc].buildstation_code,
            buildstation_id: discrepancylogs[disc].buildstation_id,
            disc_bsavailable:bsavailable,
            dat_defect_code_id : discrepancylogs[disc].dat_defect_code_id,
            dat_discrepancy_code_id: discrepancylogs[disc].dat_discrepancy_code_id,
            defect_code : discrepancylogs[disc].defect_code,
            defect_name : discrepancylogs[disc].defect_name,
            defect_type : capitalize(discrepancylogs[disc].defect_type),
            defect_codename : `${discrepancylogs[disc].defect_code}, ${discrepancylogs[disc].defect_name}`,
            discrepancy: discrepancylogs[disc].discrepancy,
            discrepancy_name: discrepancylogs[disc].discrepancy_name,
            discrepancy_status: discrepancylogs[disc].discrepancy_status.toLowerCase(),
            discrepancy_statusdisplay : setstatusfordisplay(discrepancylogs[disc].discrepancy_status.toLowerCase()),
            discrepancy_type: capitalize(discrepancylogs[disc].discrepancy_type),
            root_cause : discrepancylogs[disc].root_cause,
            component : discrepancylogs[disc].component,
            cut_off_date : discrepancylogs[disc].cut_off_date,
            raised_date : discrepancylogs[disc].raised_date,
            raised_date_display : raised_date,
            resolved_status_updatedby_id : resolved_status_updatedby_id,
            verifiedby : verifiedby,
            prod : moddedprod,
            qc : departmentqc,
            assignedprod : assignedprod,
            assigend_qc_id : assigend_qc_id,
            dept_reason_code_name:discrepancylogs[disc].reason_name,
            dept_updatedby:dept_updatedby_fullname,
            dept_updated_date:getmoddeddate(discrepancylogs[disc].dept_updated_date)
        };
        modifieddiscrepancyList.push(moddeddiscrepancy);
    }
    return modifieddiscrepancyList;
}

// Update PROD list with foreman users who are not listed 
export function updateprodlistwithforeman(selectedprod, allprod){
    function checkifexisting(element, searcharray) {
        var elementexisting = true;
        for (var i in searcharray) {
            if (searcharray[i].Id == element) {
                elementexisting = false;
            }
        }
        return elementexisting;
    }
    var updatedprodlist = [];
    if (allprod != undefined && allprod.length != 0) {
        updatedprodlist = JSON.parse(JSON.stringify(allprod));
    }
    if (selectedprod != undefined && selectedprod.length != 0) {
        for (var i in selectedprod) {
            if (checkifexisting(selectedprod[i].Id, updatedprodlist)) {
                updatedprodlist.push(selectedprod[i]);
            }
        }
    }
    return updatedprodlist;
}

// To modify the Department Shortages data for Ecard App and related components.
export function getmodifiedshortageslist(departmentdata,departmentIdMap,empid){
    //var departmentqc = modifieduserlist(departmentdata.qc);
        var departmentid = departmentdata.department_id;
        var shortagelogs = departmentdata.discrepancylog;
        var modifiedshortagesList = [];
        var prod_supervisor = modifieduserlist(departmentdata.prod_supervisor);
        //this.deptsupervisor = prod_supervisor;
        for(var disc in shortagelogs){
            var index = Number(disc)+1;
            var shortageobj = shortagelogs[disc];
            var created_by = modifieduserlist([shortageobj.createdby_id]);
            var raised_date = getmoddeddate(shortageobj.raised_date);
            var createdbyname;
            var displaycreatedbyname;
            var createdbyempid=undefined;
            if(created_by != undefined && created_by.length != 0){
                 if(created_by[0]!=undefined){
                     displaycreatedbyname = `${created_by[0].name} (${created_by[0].userid}) on ${raised_date}`;
                     createdbyname = `${created_by[0].name} (${created_by[0].userid})`;
                     createdbyempid= `${created_by[0].userid}`;
                 }
            }
            var is_deletable=false;
            if((createdbyempid==empid) && (shortageobj.discrepancy_status.toLowerCase()=="open")){
                is_deletable=true;
            }
            var partname;
            if(shortageobj.buspart_id != null ){
                partname = shortageobj.buspart_name;
            }
            else{
                partname = shortageobj.custom_part_name;
            }
            var bsavailable=shortageobj.buildstation_code=='9999'?false:true;
            var qc_avilable=shortageobj.assigend_qc_id!=null?true:false;
            var moddedshortage = {
                index: index,
                departmentid : departmentid,
                departmentcode : getdepartmentcode(departmentid, departmentIdMap),
                createdbyname : createdbyname,
                displaycreatedbyname : displaycreatedbyname,
                modified_date : shortageobj.modified_date,
                buildstation_code :  shortageobj.buildstation_code,
                buildstation_id :  shortageobj.buildstation_id,
                disc_bsavailable : bsavailable,
                part_shortage_id : shortageobj.part_shortage_id,
                buspart_id : shortageobj.buspart_id,
                buspart_name : partname, //shortageobj.buspart_name,
                custom_part_name : shortageobj.custom_part_name,
                buspart_no : shortageobj.buspart_no,
                busstatus_id : shortageobj.busstatus_id,
                busstatus_name : shortageobj.busstatus_name,
                chassis_no : shortageobj.chassis_no,
                component : shortageobj.component,
                createdby_id : modifieduserlist([shortageobj.createdby_id]),
                defect_codename : `${shortageobj.defect_code}, ${shortageobj.defect_name}`,
                discrepancy_statusdisplay : setstatusfordisplay(shortageobj.discrepancy_status.toLowerCase()),
                discrepancy_type: capitalize(shortageobj.discrepancy_type),
                cut_off_date : shortageobj.cut_off_date,
                displaycutoffdate : getmoddeddate(shortageobj.cut_off_date),
                dat_defect_code_id : shortageobj.dat_defect_code_id,
                defect_code : shortageobj.defect_code,
                defect_name : shortageobj.defect_name,
                defect_type : shortageobj.defect_type,
                isdeletable:is_deletable,
                department_id : shortageobj.department_id,
                department_name : shortageobj.department_name,
                discrepancy : shortageobj.discrepancy,
                discrepancy_priority : capitalize(shortageobj.discrepancy_priority),
                discrepancy_status : shortageobj.discrepancy_status.toLowerCase(),
                ecard_discrepancy_area_id : shortageobj.ecard_discrepancy_area_id,
                ecard_discrepancy_log_id : shortageobj.ecard_discrepancy_log_id,
                ecard_discrepancy_log_number: shortageobj.discrepancy_log_number,
                ecard_id : shortageobj.ecard_id,
                ecard_operation_log_id : shortageobj.ecard_operation_log_id,
                first_name : shortageobj.first_name,
                last_name :  shortageobj.last_name,
                customername : `${shortageobj.customer_name}`,//`${shortageobj.first_name} ${shortageobj.last_name}`,
                has_part_shortage : shortageobj.has_part_shortage,
                assignedprod : getselectedformandetails(shortageobj),
                part_avilable : shortageobj.part_avilable,
                po_no : shortageobj.po_no,
                allprodlist : modifieduserlist(shortageobj.prod),
                allqclist : modifieduserlist(shortageobj.qc),
                quantity : shortageobj.quantity,
                assigend_qc_id : modifieduserlist([shortageobj.assigend_qc_id]),
                qcavailable:qc_avilable,
                raised_date : shortageobj.raised_date,
                raised_date_display : getmoddeddate(shortageobj.raised_date),
                raised_status_updated_date : shortageobj.raised_status_updated_date,
                resolved_date : shortageobj.resolved_date,
                resolved_status_updatedby_id : modifieduserlist([shortageobj.resolved_status_updatedby_id]),
                resolved_status_updated_date : shortageobj.resolved_status_updated_date,
                root_cause : shortageobj.root_cause,
                verifiedby_id : modifieduserlist([shortageobj.verifiedby_id]),
                verified_date : shortageobj.verified_date,
                verified_status_updated_date : shortageobj.verified_status_updated_date,
                workcenter_code : shortageobj.workcenter_code,
                workcenter_name : shortageobj.workcenter_name,
                buyer : shortageobj.buyer,
                carrier_arrival_text : shortageobj.carrier_arrival_text,
                carrier_text : shortageobj.carrier_text,
                date_received : shortageobj.date_received,
                is_b_whs_kit : shortageobj.is_b_whs_kit,
                is_long_term : shortageobj.is_long_term,
                is_ship_short: shortageobj.is_ship_short,
                remarks : shortageobj.remarks,
                planner_code : shortageobj.planner_code,
                shortage_cause_id : shortageobj.shortage_cause_id != null ? shortageobj.shortage_cause_id.toString() : null,
                tracking : shortageobj.tracking,
                vendor_name : shortageobj.vendor_name,
                vendor_number : shortageobj.vendor_number,
                ship_short_pco: shortageobj.ship_short_pco
            };
            modifiedshortagesList.push(moddedshortage);
        }
        return modifiedshortagesList;
}

// Get Department Code Shortened
export function getdepartmentcode(departmentid, departmentIdMap) {
    //var departmentcode = '-';
    var departmentcode = '';
    if (departmentid != null) {
        for (var i in departmentIdMap) {
            if (departmentIdMap[i].value != 'None' && departmentIdMap[i].label != 'ALL DEPARTMENTS') {
                if (departmentIdMap[i].value == departmentid.toString()) {
                    var departmentname = departmentIdMap[i].label;
                    departmentcode = departmentname.split('-')[0];
                }
            }
        }
    }

    return departmentcode;
}

    // Capitalize string passed Display purposes.
export function  capitalize(text){
        if (typeof text !== 'string') return '';
        return text.charAt(0).toUpperCase() + text.slice(1);
}

export function getmodifiedvalidationlist(buidstationdata){
    var validationsitems = { 
        has_validation_pic: buidstationdata.has_validation_pic != undefined ?  buidstationdata.has_validation_pic : false,
        has_bm35: buidstationdata.has_bm35 != undefined ?  buidstationdata.has_bm35 : false,
        has_op_check: buidstationdata.has_op_check != undefined ?  buidstationdata.has_op_check : false,
        has_operation_check: buidstationdata.has_operation_check != undefined ?  buidstationdata.has_operation_check : false,
        has_pco: buidstationdata.has_pco != undefined ?  buidstationdata.has_pco : false,
        hasdiscrepancy: false, // Passing false because the view has changed = new column introduced
        has8410: true,  // Passing true value to show Build Station Code.
        validation_image_uri : buidstationdata.validation_image_uri,
        picture_validation_id : buidstationdata.picture_validation_id,
        validation_pic_required : buidstationdata.validation_pic_required != undefined ?  buidstationdata.validation_pic_required : true
       };
    return validationsitems;
}

// To modify the Department BuildStation Operations data for Ecard App and related components.
export function getmodifiedbuildstationlist(departmentdata,ecardid,departmentIdMap){
    var departmentid = departmentdata.department_id;
    var has_discrepancy = departmentdata.has_discrepancy;
    var QC = modifieduserlist(departmentdata.qc);
    var workstationdata = departmentdata.workcenter;
    let modifiedworkstationdata = [];
    for(var wc in workstationdata){
        let workcentre = workstationdata[wc];
        let workcenter_id = workcentre.workcenter_id;
        let workcentername = workcentre.workcentername;
        for(var bs in workcentre.buildstation){
            var buildstation = workcentre.buildstation[bs];
            var modifiedvalidationlist = getmodifiedvalidationlist(buildstation);
            var PROD = modifieduserlist(buildstation.prod);
            var selectedprod = getselectedformandetails(buildstation);
            var selectedqc = modifieduserlist([buildstation.qc_approvedby_id]);
            var qcavailable=selectedqc.length == 0?false:true;
            if(selectedprod.length == 0){
                selectedprod = preassignforeman(PROD);
            }
            /*if(selectedqc.length == 0){
                qcavailable=false;
                //selectedqc = preassignqc(QC);
            }*/
            var bsstatus;
            if(buildstation.status == null){
                bsstatus = 'open';
            }
            else{
                bsstatus = buildstation.status; 
            }
            // Since dummydata formatting the Build Station Code.
            var s = buildstation.buildstation_code;
            var bscode ;
            if(s.includes('.')){
                bscode = s.substring(0, s.indexOf('.')+5);
            }
            else{
                bscode= s;
            }
            // Since dummydata formatting the Build Station Code.
            var buildstationdata = {
                ecard_id : ecardid,
                department_id : departmentid,
                operation : buildstation.operation,
                status : bsstatus,
                buildstation_id : buildstation.buildstation_id,
                ecard_operation_log_id : buildstation.ecard_operation_log_id,
                buildstation_code : bscode,
                workcentername : workcentername,
                workcenter_id : workcenter_id,
                fleet_id : buildstation.fleet_id,
                picture_validation_id : buildstation.picture_validation_id,
                validation_image_uri : buildstation.validation_image_uri,
                validation_pic_required : buildstation.validation_pic_required,
                picture_validation_target_image_id : buildstation.picture_validation_target_image_id,
                has_discrepancy_logged : buildstation.has_discrepancy_logged != undefined ?  buildstation.has_discrepancy_logged : false,
                has_shortage_logged : buildstation.has_shortage_logged != undefined ?  buildstation.has_shortage_logged : false,
                has_opcheck_pending : buildstation.has_operation_check,
                source_image_uri : buildstation.source_image_uri // newly added by sathish for picture validation
                };

            var modifiedwsdata = {
                ecard_id : ecardid,
                department_id : departmentid,
                modified_date : buildstation.modified_date,
                departmentcode : getdepartmentcode(departmentid,departmentIdMap),
                has_discrepancy : has_discrepancy, // Department level
                has_discrepancy_logged : buildstation.has_discrepancy_logged != undefined ?  buildstation.has_discrepancy_logged : false,
                has_shortage_logged : buildstation.has_shortage_logged != undefined ?  buildstation.has_shortage_logged : false,
                applied_date : buildstation.applied_date,
                buildstationmapping_id : buildstation.buildstationmapping_id,
                workcenter_id : workcenter_id,
                picture_validation_target_image_id : buildstation.picture_validation_target_image_id,
                picture_validation_id : buildstation.picture_validation_id,
                validation_image_uri : buildstation.validation_image_uri,
                validation_pic_required : buildstation.validation_pic_required,
                fleet_id : buildstation.fleet_id,
                ecard_operation_log_id : buildstation.ecard_operation_log_id,
                workcentername : workcentername,
                operation : buildstation.operation,
                has_descrepancy : buildstation.has_descrepancy != undefined ?  buildstation.has_descrepancy : false,
                has_attachment: buildstation.ecard_operation_log_attachment_id.length != 0 ? true : false,
                status : bsstatus,
                buildstation_id : buildstation.buildstation_id,
                buildstation_code : bscode,
                buidstationdata : buildstationdata,
                validationlist : modifiedvalidationlist,
                selectedprod : selectedprod,
                selectedqc : selectedqc,
                qcavailable : qcavailable,
                PRODlist : PROD,
                QClist : QC
            };
            if(modifiedwsdata.has_discrepancy_logged || modifiedwsdata.has_shortage_logged){
                modifiedwsdata["hasdescrepancy"] = true;
            }
            else{
                modifiedwsdata["hasdescrepancy"] = false;
            }
            modifiedworkstationdata.push(modifiedwsdata);
        }
    }
    return modifiedworkstationdata;
}

// To search within the operations build station data and return with complete object.
export function getselectedbuildstationDetails(buildstationid,modifiedbuildstations){
    var selectedbuildstation;
    for(var bs in modifiedbuildstations){
        if(modifiedbuildstations[bs].buildstation_id == buildstationid){
            selectedbuildstation = modifiedbuildstations[bs];
        }
    }
    return selectedbuildstation;
}

export function getmodifiedpaginateddiscrepancylist(completediscrepancydata, empid, departmentIdMap) {
    var moddeddiscrepancydata = [];
    for (var disc in completediscrepancydata) {
        var index = Number(disc) + 1;
        var discrepancy = completediscrepancydata[disc];
        var isdepartmentdiscrepancy = false;
        if (discrepancy.discrepancy_type == "department") {
            isdepartmentdiscrepancy = true;
        }
        var isdownstreamdiscrepancy = false;
        if (discrepancy.discrepancy_type == "downstream") {
            isdownstreamdiscrepancy = true;
        }
        //newly added
        var isshortdiscrepancy = false;
        if (discrepancy.discrepancy_type == "short") {
            isshortdiscrepancy = true;
        }
        // alert(isdepartmentdiscrepancy);
        var selectedprodlist = getselectedformandetails(discrepancy);
        var allprodlist = modifieduserlist(discrepancy.prod);
        var allqclist = modifieduserlist(discrepancy.qc);
        var assigend_qc_id = modifieduserlist([
            discrepancy.assigend_qc_id
        ]);
        var created_by = modifieduserlist([
            discrepancy.createdby_id
        ]);
        var raised_date = getmoddeddate(discrepancy.raised_date);
        var createdbyname;
        var displaycreatedbyname;
        var createdbyempid = undefined;
        if (created_by != undefined && created_by.length != 0) {
            if (created_by[0] != undefined) {
                displaycreatedbyname = `${created_by[0].name} (${created_by[0].userid}) on ${raised_date}`;
                createdbyname = `${created_by[0].name}`;
                createdbyempid = `${created_by[0].userid}`;
            }
        }

        allprodlist = updateprodlistwithall(
            selectedprodlist,
            allprodlist
        );

        var raisedby_name;
        var displayraisebyname;
        if (assigend_qc_id != undefined && assigend_qc_id.length != 0) {
            if (assigend_qc_id[0] != undefined) {
                displayraisebyname = `${assigend_qc_id[0].name} (${assigend_qc_id[0].userid})`;
                raisedby_name = `${assigend_qc_id[0].name} (${assigend_qc_id[0].userid})`;
            }
        }
        var resolved_status_updatedby = modifieduserlist([
            discrepancy.resolved_status_updatedby_id
        ]);
        var verifiedby = modifieduserlist([
            discrepancy.verifiedby_id
        ]);
        var assigneduser = selectedprodlist;
        var hasbusareapicture = false;
        if (discrepancy.bus_area_picture_id != undefined) {
            hasbusareapicture = true;
        }
        var discrepancytype = discrepancy.discrepancy_type;
        if (discrepancy.discrepancy_type == 'busarea') {
            discrepancytype = 'Bus Area';
        }

        //newly added 
        else if (discrepancy.discrepancy_type == 'downstream') {
            discrepancytype = 'Out Of Station';
        }
        else if (discrepancy.discrepancy_type == 'buildstation') {
            discrepancytype = 'Job';
        }

        var bsavailable = discrepancy.buildstation_code == '9999' ? false : true;
        //alert(discrepancy.modified_date);    
        var is_deletable = false;
        if ((createdbyempid == empid) && (discrepancy.discrepancy_status.toLowerCase() == "open")) {
            is_deletable = true;
        }
        let dept_updatedby_fullname;
        var dept_updatedbyuser = discrepancy.dept_updatedby_id;
        if(dept_updatedbyuser == null){
            dept_updatedby_fullname = null;
        }else{
            dept_updatedby_fullname = discrepancy.dept_updatedby_id.first_name+' '+discrepancy.dept_updatedby_id.last_name;

        }
        var modeddiscrepancy = {
            index: index,
            modified_date: discrepancy.modified_date,
            hasbusareapicture: hasbusareapicture,
            bus_area: discrepancy.bus_area,
            bus_area_picture_id: discrepancy.bus_area_picture_id,
            buildstation_code: discrepancy.buildstation_code,
            buildstation_id: discrepancy.buildstation_id,
            busstatus_id: discrepancy.busstatus_id,
            busstatus_name: discrepancy.busstatus_name,
            chassis_no: discrepancy.chassis_no,
            component: discrepancy.component,
            first_name: discrepancy.first_name,
            last_name: discrepancy.last_name,
            customername: `${discrepancy.customer_name}`,
            customernamewithchasis: `${discrepancy.customer_name}, ${discrepancy.chassis_no}`,
            cut_off_date: discrepancy.cut_off_date,
            dat_defect_code_id: discrepancy.dat_defect_code_id,
            defect_codename: `${discrepancy.defect_code}, ${discrepancy.defect_name}`,
            defect_code: discrepancy.defect_code,
            defect_name: discrepancy.defect_name,
            defect_type: capitalize(discrepancy.defect_type),
            department_id: discrepancy.department_id,
            departmentid: discrepancy.department_id,
            departmentcode: getdepartmentcode(discrepancy.department_id, departmentIdMap),
            department_name: discrepancy.department_name,
            //description: discrepancy.discrepancy,
            discrepancy: discrepancy.discrepancy,
            discrepancy_priority: capitalize(
                discrepancy.discrepancy_priority
            ),
            discrepancy_statusdisplay: setstatusfordisplay(
                discrepancy.discrepancy_status.toLowerCase()
            ),
            discrepancy_status: discrepancy.discrepancy_status.toLowerCase(),
            discrepancy_type: capitalize(discrepancytype),
            isdepartmentdiscrepancy: isdepartmentdiscrepancy,
            isdownstreamdiscrepancy: isdownstreamdiscrepancy,
            isshortdiscrepancy: isshortdiscrepancy, //newly added
            isdeletable: is_deletable,
            ecard_discrepancy_log_id: discrepancy.ecard_discrepancy_log_id,
            ecard_discrepancy_log_number: discrepancy.discrepancy_log_number,
            ecard_id: discrepancy.ecard_id,
            ecard_operation_log_id: discrepancy.ecard_operation_log_id,
            has_part_shortage: discrepancy.has_part_shortage,
            resolved_date: getmoddeddate(discrepancy.resolved_date),
            disc_bsavailable: bsavailable,
            workcenter_name: discrepancy.workcenter_name,
            workcenter_code: discrepancy.workcenter_code,
            part_avilable: discrepancy.part_avilable,
            raised_date_display: getmoddeddate(discrepancy.raised_date),
            raised_date: discrepancy.raised_date,
            raised_status_updated_date:
                discrepancy.raised_status_updated_date,
            root_cause: discrepancy.root_cause,
            verified_date: discrepancy.verified_date,
            verified_status_updated_date:
                discrepancy.verified_status_updated_date,
            selectedprodlist: selectedprodlist,
            //allprodlist: allprodlist,
            prod: allprodlist,
            //allqclist: allqclist,
            qc: allqclist,
            assigend_qc_id: assigend_qc_id,
            qcavailable: assigend_qc_id.length != 0 ? true : false,
            // resolved_status_updatedby: resolved_status_updatedby,
            resolved_status_updatedby_id: resolved_status_updatedby,
            verifiedby: verifiedby,
            //assigneduser: assigneduser,
            assignedprod: assigneduser,
            created_by: created_by,
            createdbyname: createdbyname,
            displaycreatedbyname: displaycreatedbyname,
            filtered: "",
            dept_reason_code_name:discrepancy.reason_name,
            dept_updatedby:dept_updatedby_fullname,
            dept_updated_date:getmoddeddate(discrepancy.dept_updated_date)
        };
        moddeddiscrepancydata.push(modeddiscrepancy);
    }

    return moddeddiscrepancydata;
}

export function updateprodlistwithall(selectedprod, allprod) {
    function checkifexisting(element, searcharray) {
        var elementexisting = true;
        for (var i in searcharray) {
            if (searcharray[i].Id == element) {
                elementexisting = false;
            }
        }
        return elementexisting;
    }
    var updatedprodlist = [];
    if (allprod != undefined && allprod.length != 0) {
        updatedprodlist = JSON.parse(JSON.stringify(allprod));
    }
    if (selectedprod != undefined && selectedprod.length != 0) {
        for (var i in selectedprod) {
            if (checkifexisting(selectedprod[i].Id, updatedprodlist)) {
                updatedprodlist.push(selectedprod[i]);
            }
        }
    }
    return updatedprodlist;
}

export function sortdiscrepancytable(discrepancyList){
      var reverse = 1;
      let table = JSON.parse(JSON.stringify(discrepancyList));
      table.sort((a, b) => {
        return a["departmentcode"] >
          b["departmentcode"]
          ? 1 * reverse
          : -1 * reverse;
      });
      return table;
  }