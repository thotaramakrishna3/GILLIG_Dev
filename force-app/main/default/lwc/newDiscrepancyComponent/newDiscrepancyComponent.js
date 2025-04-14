import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getDepartmentOperations from "@salesforce/apex/ecardOperationsController.getDepartmentOperations";
import getcrewingsuserslist from "@salesforce/apex/CrewingScheduleController.getcrewingsuserslist";
import {modifieduserlist, getmoddeddate, getselectedformandetails}  from 'c/userPermissionsComponent';
import deleteTempAttachment from "@salesforce/apex/ecardOperationsController.deleteTempAttachment";
import getCompleteDefectCodes from "@salesforce/apex/ecardOperationsController.getDefectCodes";
import raisenewDiscrepancy from "@salesforce/apex/DiscrepancyDatabaseController.raisenewDiscrepancy";
import getAllEcarddetailsfromServer from "@salesforce/apex/DiscrepancyDatabaseController.getAllEcarddetails";
import getDepartmentdata from "@salesforce/apex/masterDataController.getDepartmentdata";
import pubsub from 'c/pubsub' ;
import EcardLogin from "@salesforce/apex/userAuthentication.EcardLogin";

export default class NewDiscrepancyComponent extends LightningElement {  
    @api buttonlabel;
    @api modalheading;
    @api ecardid;
    @api busname;
    @api buschasisnumber;
    @api departmentid;
    @api buildstationrequired;
    @api departmentIdMap;
    @api department;
    @api buildstationid;
    @api type;
    @api page;
    @api permissionset;

    @track deptsupervisorforselecteddept;
    @track buildstationoptions;
    @track selecteddeptbsdetails = []; 
    @track newdiscrepancy;
    @track newdiscrepancymodal = false;
    @track defectoptions = [];
    @track paintdefects = [];
    @track otherdefects = [];
    @track alldefectcode;
    @track showtypeselection = true;
    @track departmentoptions;
    @track departmentName;
    @track priorityoptions = [{"label":"High", "value":"High"}, {"label":"Normal", "value":"Normal"}, {"label":"Low", "value":"Low"}] ; 
    @track discrepancyDB = false;
    @track ecardoptions = [];
    @track ecardnamechasislist = [];
    
    get ecardnotselected() {
        if (this.newdiscrepancy.ecardid == undefined) {
            return true;
        } else {
            return false;
        }
    }

    get departmentnotselected() {
        if (this.newdiscrepancy.departmentid == undefined) {
            return true;
        } else {
            return false;
        }
    }

    get enableDeptDiscrepancy() {
        return this.permissionset.dept_discrepancy_new.write;
    }
    // Use whenever a false attribute is required in Component.html
    get returnfalse(){
            return false;
    }
  
    // Use whenever a true attribute is required in Component.html
    get returntrue(){
          return true;
    }
    
    //used to enable disable the discrepancy button
    get disablebutton() {
        if (this.permissionset != undefined) {
            return !this.permissionset.discrepancy_new.write;
        } else
            return false;
    }

    @track disctype = [];
    // To show Add new discrepancy modal and set the default values.
    async addnewdiscrepancymodal(event){
        this.isCustinspector = false;
        if(this.type=='department'){
            this.type='buildstation';
            this.buildstationrequired = true;
            this.disctype = [{ 'label': 'Job', 'value': 'buildstation' },
            { 'label': 'Department', 'value': 'department' },
            { 'label': "Out Of Station", 'value': "downstream" },
            { 'label': "Short", 'value': "short" },
            { 'label': "Customer Inspector", 'value': "custinspector" }];
            if (!this.enableDeptDiscrepancy) {
                this.disctype.splice(1, 1);
            }
        }
        else{
            this.type=='buildstation';
            this.buildstationrequired = true;
            this.disctype = [{ 'label': 'Job', 'value': 'buildstation' },
            { 'label': 'Department', 'value': 'department' },
            { 'label': "Out Of Station", 'value': "downstream" },
            { 'label': "Short", 'value': "short" },
            { 'label': "Customer Inspector", 'value': "custinspector" }];
            if (!this.enableDeptDiscrepancy) { 
                this.disctype.splice(1, 1);
            }
        }
        if (this.page == 'discrepancyDB') {
            this.discrepancyDB = true;
        }
        var options = [];
        for(var i in this.departmentIdMap){
            if(this.departmentIdMap[i].value != 'None' && this.departmentIdMap[i].label != 'ALL DEPARTMENTS'){
                options.push(this.departmentIdMap[i]);
            }
        }
        this.departmentoptions = options;
        this.departmentName = this.department;
        if(this.departmentName == 'ALL DEPARTMENTS'){
            this.departmentid = this.departmentoptions[0].value;
            this.departmentName = this.departmentoptions[0].label;
        }
        this.s3tempurlfornewdiscrepancy = [];
        this.fetchcompletedefectList();
        let newdiscrepancy = {};
        var todaydate = new Date();
        if(this.discrepancyDB){
            this.getAllEcarddetails();
            newdiscrepancy = {
                description: null,
                date: getmoddeddate(todaydate),
                type: "buildstation",
                ecardid: undefined,
                departmentid: undefined,
                buildstation_id: undefined,
                priority: "Normal",
                defectcode: undefined
            };
        }
        else {
            var ecard_id = this.ecardid;
            var departmentid = this.departmentid == undefined ? "21" : this.departmentid.toString();
            if(this.loggedinuser.approle_id == 8){
                this.isCustinspector = true;
                this.type= 'custinspector';
            const match = this.departmentoptions.find(
                dept =>
                  dept.label.toUpperCase().startsWith('CUSTOMER INSPECTOR') ||
                  dept.label.toUpperCase().endsWith('CUSTOMER INSPECTOR')
              );
              
              if (match) {
                departmentid = match.value;
              }
            }
            this.moddifydefectpickvalues(departmentid);
            var selectedbus = `${this.busname}, ${this.buschasisnumber}`;
            var ecardiddeptid = { ecard_id: ecard_id, dept_id: departmentid };
            var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" };
            await getDepartmentOperations({ ecardiddeptid: JSON.stringify(ecardiddeptid) })
                .then(data => {
                    this.buildstationoptions = data.buildstationList;
                    this.buildstationoptions.push(bs);
                    this.selecteddeptbsdetails = this.getcompleteBuilstationlist(data);

                }).catch(error => {
                    this.error = error;
                    this.showmessage('Failed to fetch Build Station Details.', 'Something unexpected occured. Please contact your Administrator.', 'error');
                });
            var buildstation_id = this.buildstationid != undefined ? this.buildstationid.toString() : this.buildstationid;
            var buildstationId = this.buildstationid;
            var buildstationdetails = this.selecteddeptbsdetails;
            var selectedbuildstation;
            if (buildstationId != undefined) {
                for (var bs in buildstationdetails) {
                    if (buildstationId.toString() == buildstationdetails[bs].buildstation_id.toString()) {
                        selectedbuildstation = buildstationdetails[bs];
                    }
                }
            }
            newdiscrepancy = {
                description: undefined,
                selectedbus: selectedbus,
                date: getmoddeddate(todaydate),
                type: this.type,
                ecardid: ecard_id,
                departmentid: departmentid,
                buildstation_id: buildstation_id,
                priority: 'Normal',
                defectcode: undefined
            };
            this.currentdept = departmentid;
        }
        this.newdiscrepancy = newdiscrepancy;
        this.newdiscrepancymodal = true;
    }    

    //To get all Ecard Details from Server
    getAllEcarddetails(event) {
        getAllEcarddetailsfromServer()
            .then((result) => {
                var ecards = JSON.parse(result.response).data.ecard;
                var ecardoptions = [];
                for (var ec in ecards) {
                    var ecardopt = {
                        label: `${ecards[ec].chassis_no} (${ecards[ec].customer_name})`,
                        value: ecards[ec].ecard_id.toString()
                    };
                    ecardoptions.push(ecardopt);
                }
                this.ecardoptions = ecardoptions;
                var ecardnamelist = [];
                for (var ecard in this.ecardoptions) {
                    ecardnamelist.push(this.ecardoptions[ecard].label);
                }
                this.ecardnamechasislist = ecardnamelist;
            })
            .catch((error) => {
                const alertmessage = new ShowToastEvent({
                    title: "Failed to fetch list of Bus.",
                    message:
                        "Something unexpected occured. Please contact your Administrator",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
    }

    // Update Bus/Ecard selected in new disscrepancy
    onbusselection(event) {
        if (event.detail.labelvalue == "Select a Bus") {
            var selectedbus = event.detail.selectedRecord;
            for (var ecard in this.ecardoptions) {
                if (selectedbus == this.ecardoptions[ecard].label) {
                    this.newdiscrepancy.ecardid = this.ecardoptions[ecard].value;
                }
            }
        }
    }
    // On clearing the bus selection. added
    onclearbus(event) {
        var emptylist = [];
        this.newdiscrepancy.ecardid = undefined;
        this.newdiscrepancy.departmentid = undefined;
        this.newdiscrepancy.buildstation_id = undefined;
        this.newdiscrepancy.defectcode = undefined;
    }
    // Get Department picklist from server
    getdepartmentPicklist(event) {
        if (this.discrepancyDB) {
            var authorisationdata = "Parameter to be removed from Apex Class";
            getDepartmentdata({ authdata: authorisationdata })
                .then((result) => {
                    var departmentlistvalues = result.departmentPickList;
                    var deptpickvalues = [];
                    for (var dept in departmentlistvalues) {
                        var deprtmentopt = departmentlistvalues[dept];
                        if (deprtmentopt.value != 'None') {
                            deptpickvalues.push(deprtmentopt);
                        }
                    }
                    this.departmentoptions = deptpickvalues;
                })
                .catch((error) => {
                    const alertmessage = new ShowToastEvent({
                        title: "Department data fetch failed.",
                        message:
                            "Something unexpected occured. Please contact your Administrator",
                        variant: "error"
                    });
                    this.dispatchEvent(alertmessage);
                });
        }
    }

    // To get Complete Defect List from Server. 
    fetchcompletedefectList(event){
        getCompleteDefectCodes()
        .then(data => {
            if(data.isError){
                    this.error = error;
                    this.showmessage('Defect Data fetch failed.','Something unexpected occured. Please try again or contact your Administrator.','error');  
            }
            else{
                this.otherdefects = [];
                this.paintdefects = [];
                this.alldefectcode = [];
                this.alldefectcode = JSON.parse(data.responsebody).data.defects;
                var alldefects = this.alldefectcode;
                for(var defect in alldefects){
                    if(alldefects[defect].is_active){
                        var option = {
                            label : alldefects[defect].defect_code + ', '+ alldefects[defect].defect_name,
                            value : alldefects[defect].dat_defect_code_id.toString(),
                            defectname : alldefects[defect].defect_name,
                            defecttype : alldefects[defect].defect_type 
                        };
                        if(this.alldefectcode[defect].defect_type != 'paint'){
                            this.otherdefects.push(option);
                        }
                        else{
                            this.paintdefects.push(option);
                        }
                    }
                }
                if(this.departmentName != '07 - PAINT'){
                    this.defectoptions = this.otherdefects;
                }else{
                    this.defectoptions = this.paintdefects;
                }
            }
            })
            .catch(error => {
                this.error = error;
                this.showmessage('Defect Data fetch failed.','Something unexpected occured. Please try again or contact your Administrator.','error');
            });
    }

    // To modify defect picklist values based on Department Selection
    moddifydefectpickvalues(deptcode){
        var defecttype = 'department';
        var deptlist = JSON.parse(JSON.stringify(this.departmentoptions));
        for(var i in deptlist){
            if(deptlist[i].value === deptcode.toString()){
              defecttype = deptlist[i].defect_type;
            }
        }
        if (defecttype == 'paint') {
            this.defectoptions = this.paintdefects;
        }
        else{
            this.defectoptions = this.otherdefects;
        }
    }

    // For getting Buildstation Details on department change for Department Discrepancy.
    getcompleteBuilstationlist(data){
        let workstationdata = data.builstationMapWrapper.workcenter;
        let modifiedworkstationdata = [];
        if(workstationdata.length != 0){
            for(var wc in workstationdata){
                let workcentre = workstationdata[wc];
                let workcenter_id = workcentre.workcenter_id;
                let workcentername = workcentre.workcentername;
                for(var bs in workcentre.buildstation){
                    var buildstation = workcentre.buildstation[bs];
                    var modifiedvalidationlist = this.getmodifiedvalidationlist(buildstation);
                    var bsstatus;
                    if(buildstation.status == null){
                        bsstatus = 'open';
                    }
                    else{
                        bsstatus = buildstation.status; 
                    }
                    // Since dummydata
                    var s = buildstation.buildstation_code;
                    var bscode ;
                    if(s.includes('.')){
                        bscode = s.substring(0, s.indexOf('.')+5);
                    }
                    else{
                        bscode= s;
                    }
                    var modifiedwsdata = {
                        workcenter_id : workcenter_id,
                        ecard_operation_log_id : buildstation.ecard_operation_log_id,
                        workcentername : workcentername,
                        operation : buildstation.operation,
                        hasdescrepancy: buildstation.has_descrepancy != undefined ?  buildstation.has_descrepancy : false,
                        status    : bsstatus,
                        buildstation_id : buildstation.buildstation_id,
                        buildstation_code : bscode,
                        validationlist : modifiedvalidationlist
                    };
                    modifiedworkstationdata.push(modifiedwsdata);
                }
            }
        }
        return modifiedworkstationdata;
    }

    // Generic function to Show alert toasts.
    showmessage(title, message, variant){
        const alertmessage = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(alertmessage);
    }
    connectedCallback(){
        this.getloggedinuser();
    }
    getloggedinuser() {
        EcardLogin()
            .then((result) => {
                this.loggedinuser = result.data.user;
            })
            .catch((error) => {
            });
    }
@track isCustinspector = false;
@track currentdept;
    // Update New Discrepancy values.
    async modifynewdiscrepancyvalues(event){
        var targetvalue = event.target.value;
        var targetname = event.target.name;
        this.newdiscrepancy[targetname] = targetvalue;
        if(targetname == 'type'){
            this.buildstationrequired = targetvalue=='department'?false:true;
            var emptylist = [];   
            this.newdiscrepancy.buildstation_id = undefined;
            this.newdiscrepancy.defectcode = undefined;
            if(targetvalue == 'custinspector'){
                this.isCustinspector = true;
              targetname = 'departmentid';
              const match = this.departmentoptions.find(
                dept =>
                  dept.label.toUpperCase().startsWith('CUSTOMER INSPECTOR') ||
                  dept.label.toUpperCase().endsWith('CUSTOMER INSPECTOR')
              );
              
              if (match) {
                targetvalue = match.value;
              }
            }else{
                this.isCustinspector = false;
                this.newdiscrepancy.departmentid = this.currentdept;
                targetname = 'departmentid';
                targetvalue = this.currentdept;            
            }
        }
        if(targetname == 'departmentid'){
            this.newdiscrepancy.departmentid = targetvalue;
            if(this.newdiscrepancy.ecardid != undefined){
                this.moddifydefectpickvalues(targetvalue);
                var ecardid = this.newdiscrepancy.ecardid;
                var departmentId = targetvalue;
                var ecardiddeptid = {ecard_id:ecardid ,dept_id:departmentId};
                var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" };
                await getDepartmentOperations({ecardiddeptid:JSON.stringify(ecardiddeptid)})
                    .then(data => {
                    this.buildstationoptions =  data.buildstationList;
                    this.buildstationoptions.push(bs);
                    this.selecteddeptbsdetails = this.getcompleteBuilstationlist(data);
                    this.newdiscrepancy.buildstation_id = undefined;          
                    }).catch(error => {
                        this.error = error;
                        this.showmessage('Failed to fetch Build Station Details.','Something unexpected occured. Please contact your Administrator.','error');
                    }); 
            }
            else{
                    this.newdiscrepancy.departmentid = undefined;
                    this.showmessage('Select a Bus.','Please select a Bus before selecting Department.','warning');
                }
                
        }
        if(targetname == 'buildstation_id'){
            var buildstationdetails = this.selecteddeptbsdetails;
            var buildstationId = targetvalue;
            var selectedbuildstation;
            for (var bs in buildstationdetails) {
                if (buildstationId.toString() == buildstationdetails[bs].buildstation_id.toString()) {
                    selectedbuildstation = buildstationdetails[bs];
                }
            }
            this.newdiscrepancy.buildstation_id = buildstationId == 'Unknown' ? this.newdiscrepancy.buildstation_id : selectedbuildstation.buildstation_id.toString();
        }
    }

    @track s3tempurlfornewdiscrepancy = [];
    // Get the temporary urls from the attachmenttempComponent.
    gets3tempurls(event){
        this.s3tempurlfornewdiscrepancy = event.detail.tempurllist;
    }
    
    // To hide the new Discrepancy modal.
    hidenewdiscrepancymodal(event){
        this.newdiscrepancymodal = false;
        this.deletetempattachments();
    }

    // If attachments are added and then cancelled for a new discrepancy/partshortage to delete those attachments.
    deletetempattachments(event){
        if(this.s3tempurlfornewdiscrepancy.length != 0){
            var requestbody = {
                "s3_file_paths" : JSON.stringify(this.s3tempurlfornewdiscrepancy)
            };
            deleteTempAttachment({requestbody:JSON.stringify(requestbody)})
                .then(data => {
                    if(data.isError){
                        this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
                    }
                    else{
                            //Should we show a toast message for deleteing temp attachment ?
                    }
                            
                }).catch(error => {
                    this.error = error;
                    this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
            });
        }
    }

    // Add new Discrepancy to Server
    addnewdiscrepancytoserver(event){
        // Check Validations
        const allValid = [...this.template.querySelectorAll('.newdiscvalidation')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            //Submit information on Server
            var newdiscrepancyvalues = this.newdiscrepancy;
            if (newdiscrepancyvalues.buildstation_id == undefined || newdiscrepancyvalues.buildstation_id == 'Unknown') {
                newdiscrepancyvalues.buildstation_id = null;
            }
            var newdiscrequestbody = {
                "discrepancy_type": newdiscrepancyvalues.type,
                "discrepancy_priority": newdiscrepancyvalues.priority,
                "discrepancy_status": "open",
                "ecard_id": newdiscrepancyvalues.ecardid,
                "department_id": newdiscrepancyvalues.departmentid,
                "discrepancy": newdiscrepancyvalues.description,
                "dat_defect_code_id" : newdiscrepancyvalues.defectcode,
                "buildstation_id" : newdiscrepancyvalues.buildstation_id  
            };
            var disctype = newdiscrepancyvalues.type;
            if(this.s3tempurlfornewdiscrepancy.length != 0){
                newdiscrequestbody["s3_file_paths"] = JSON.stringify(this.s3tempurlfornewdiscrepancy);
            }
            else{
                newdiscrequestbody["s3_file_paths"] = null;
            }
            var withforemans = newdiscrequestbody;
            raisenewDiscrepancy({requestbody:JSON.stringify(withforemans), discrepancytype: disctype})
                  .then(data => {
                    if(data.isError){
                        this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
                    }
                    else{
                        this.showmessage('Added new Issue.','A new Issue was successfully raised.','success');
                        this.newdiscrepancymodal = false;
                        pubsub.fire('operationrefresh', undefined );

                    }
                        
            }).catch(error => {
                this.error = error;
                this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
            });
        }
        else{
            this.showmessage('Please fill all required fields.','Please fill required and update all blank form entries.','warning');
        }
    }

    getmodifiedvalidationlist(buidstationdata){
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
}