import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getDepartmentOperations from "@salesforce/apex/ecardOperationsController.getDepartmentOperations";
import getcrewingsuserslist from "@salesforce/apex/CrewingScheduleController.getcrewingsuserslist";
import {modifieduserlist, getmoddeddate, getselectedformandetails}  from 'c/userPermissionsComponent';
import getBusPartdetails from "@salesforce/apex/ecardOperationsController.getBusPartdetails";
import deleteTempAttachment from "@salesforce/apex/ecardOperationsController.deleteTempAttachment";
import raisenewShortage from "@salesforce/apex/ecardOperationsController.raisenewShortage";
import getPartshortagecauselist from "@salesforce/apex/ecardOperationsController.getPartshortageCauses";
import getDefaultVendorandBuyer from '@salesforce/apex/ecardOperationsController.getDefaultVendorandBuyer';
import getAllpartsVendorlist from '@salesforce/apex/ecardOperationsController.getAllpartsVendorlist';
import getAllEcarddetailsfromServer from "@salesforce/apex/DiscrepancyDatabaseController.getAllEcarddetails";
import pubsub from 'c/pubsub' ;
import createReject from "@salesforce/apex/ecardOperationsController.createReject";
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_NAME from '@salesforce/schema/Reject__c';
import PICKLIST_FIELD from '@salesforce/schema/Reject__c.Status__c';
import getReasoncode from "@salesforce/apex/ecardOperationsController.getReasoncode";
import getlocationcode from "@salesforce/apex/ecardOperationsController.getLocationcode";
const FIELDS = [
    'User.FirstName',
    'User.LastName',
    'User.EmployeeNumber'
];
export default class NewShortageComponent extends LightningElement {
    @track rejectedby = USER_ID;
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
    @api permissionset;
    @api partnumber;
    @api bstationcode;
    @api partname;
    @api partid;
    @api bstationid;
    get btndisabled() {
        if (this.permissionset != undefined) {
            return !this.permissionset.shortage_new.write;
        } else
            return false;
    }
    @track showbutton;
    @track partshortageaddmodalreject=false;
    @track modifiedshortageslist = [];
    @track partnumberlistreject;
    @track partnumberdetails;
    @track newreject;
    @track shortgecauselist = [];
    @track partsvendorslist = [];
    @track vendornamelist = [];
    @track deptsupervisorforselecteddept;
    @track buildstationoptionsreject; 
    @track thisdepartmentbuildstations = [];
    // Use whenever a true attribute is required in Component.html
    get returntruereject(){
      return true;
    }   

    get enableeditonpartnamereject(){
        return this.newreject.buspart_no != 'Part No. Not Found';
    }

    get buildstationselectedpartreject(){
        if(this.newreject.buildstation_id != undefined){
            return true;
        }
        else{
            return false;
        }
    }
    get ecardnotselectedreject(){
        return this.newreject.ecard_id == undefined;
    }
    get deptnotselectedreject(){
        return this.newreject.department_id == undefined;
    }
    get returntruereject() {
        return true;
    }
    @track rejectreasoncode=[];
    connectedCallback(){
        this.getCode();
        this.getLocationCode();
    }
    @track reasoncode;
    getCode(){
    getReasoncode()
    .then((result) => {
        this.reasoncode = result;
        for(let i=0;i<=result.length;i++){
            if(result[i].RecordType.Name == 'Reject'){
                this.rejectreasoncode.push({
                    "label":result[i].Reason_Code__c,
                    "value":result[i].Reason_Code__c
                });           
            }
        }
    })
    .catch((error) => {
    });
    
}
@track locationcode=[];
@track locationvaluecode =[];
getLocationCode(){
getlocationcode()
.then((result) => {
    var data = JSON.parse(result.responsebody).data.locations;
    let locationcode = [];
    let locationvaluecode = [];
    for(let i=0;i<data.length;i++){
            locationcode.push({
                "label":data[i].location__c,
                "value":data[i].location__c
            });
            locationvaluecode.push({
                "label":data[i].location__c,
                "value":data[i].location_id__c
            });           
    }
    this.locationcode = locationcode;
    this.locationvaluecode = locationvaluecode;
})
.catch((error) => {
});

}
    @api page;
    @track fullName;
    @track showSpinner = true;
    @track rejectdb = false;
    userId = USER_ID;
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    user({ error, data }) {
        if (error) {
        } else if (data) {
            this.fullName = `${data.fields.FirstName.value} ${data.fields.LastName.value}`;
            this.EmployeeId = data.fields.EmployeeNumber.value
        }
    }
    // To show Report reject addition Modal
    async showReportRejectAdd(event) {
        this.showSpinner = true;
        var selectedrejectbus = `${this.busname}, ${this.buschasisnumber}`;
        var ecardid = this.ecardid;
        var options = [];
        for (var i in this.departmentIdMap) {
            if (this.departmentIdMap[i].value != 'None' && this.departmentIdMap[i].label != 'ALL DEPARTMENTS' && this.departmentIdMap[i].label != 'All Departments') {
                options.push(this.departmentIdMap[i]);
            }
        }
        this.departmentoptionsreject = options;
        this.departmentName = this.department;
        if (this.departmentName == 'ALL DEPARTMENTS') {
            this.departmentid = this.departmentoptionsreject[0].value;
        }
        else {
            this.departmentid = this.departmentid;
        }
        var departmentId = this.departmentid;
        var ecardiddeptid = { ecard_id: ecardid, dept_id: departmentId };
        var allPRODlist = [];
        var allQClist = [];
        var PRODlist = [];
        var QClist = [];
        var emptylist = [];
        var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" }
        var newreject = {}; 
        if (this.page == 'rejectdb') {
            this.rejectdb = true;
        }
        if (this.rejectdb) {
            this.getAllEcarddetails();
            newreject = {
                'buspart_id': undefined,
                'buspart_no': undefined,
                'buspart_name': undefined,
                'quantity': undefined,
                'po_no': undefined,
                'cut_off_date': undefined,
                'selectedrejectbus': undefined,
                'discrepancy_type': 'partshortage',
                'department_id': undefined,
                'ecard_id': undefined,
                'priority': 'Normal',
                'buildstation_id': undefined,
                'buschasisnumber': undefined,
                'date': getmoddeddate(new Date()),
                'is_long_term': false,
                'is_ship_short': false,
                'remarks': undefined,
                'qclist': [],
                'allQClist': [],
                'prodlist': [],
                'allPRODlist': [],
                'location':undefined,
                'location_id':undefined,
                'partremove':true
            };
            this.newreject = newreject;
            this.isLocationRequired = true;
        }
        else {
            await getDepartmentOperations({ ecardiddeptid: JSON.stringify(ecardiddeptid) })
                .then(data => {
                    var prod_supervisor = modifieduserlist(data.builstationMapWrapper.prod_supervisor);
                    this.deptsupervisorforselecteddept = prod_supervisor;
                    this.buildstationoptionsreject = data.buildstationList;
                    this.buildstationoptionsreject.push(bs);
                    this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                    PRODlist = this.deptsupervisorforselecteddept;
                    var todaydate = new Date();
                    //this.moddifydefectpickvalues(departmentId);   
                    var partno = undefined;
                    var buildstation = undefined;
                    var buildstationid = undefined;
                    var partname = undefined;
                    var partid = null;
                    partno = this.partnumber;
                    buildstation = this.bstationcode;
                    buildstationid = this.bstationid != undefined ? this.bstationid.toString() : this.bstationid;
                    partname = this.partname;
                    partid = this.partid;
                    //Start - prod listing for BS
                    var buildstationdetails = this.thisdepartmentbuildstations;
                    var selectedbsstation;
                    if (buildstationid != undefined) {
                        for (var item in buildstationdetails) {
                            if (buildstationid.toString() == buildstationdetails[item].buildstation_id.toString()) {
                                selectedbsstation = buildstationdetails[item];
                            }
                        }
                    }
                    if (buildstationid != undefined && selectedbsstation.PRODlist != null) {
                        PRODlist = selectedbsstation.PRODlist;
                    }
                    newreject = {
                        'buspart_id': partid,
                        'buspart_no': partno,
                        'buspart_name': partname,
                        'quantity': undefined,
                        'po_no': undefined,
                        'cut_off_date': undefined,
                        'selectedrejectbus': selectedrejectbus,
                        'discrepancy_type': 'partshortage',
                        'department_id': departmentId.toString(),
                        'ecard_id': ecardid,
                        'priority': 'Normal',
                        'buildstation_id': buildstationid,
                        'buschasisnumber': this.buschasisnumber,
                        'date': getmoddeddate(todaydate),
                        'is_long_term': false,
                        'is_ship_short': false,
                        'qclist': [],
                        'allQClist': allQClist,
                        'prodlist': [],
                        'allPRODlist': PRODlist,
                        'location':undefined,
                        'location_id':undefined,
                        'partremove':true
                    };
                    this.newreject = newreject;
                    this.isLocationRequired = true;
                }).catch(error => {
                    this.error = error;
                    this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error');
                });
        }
        this.partshortageaddmodalreject = true;
        this.showSpinner = false;
    }

    @track ecardoptions;
    @track ecardnamechasislistreject;
    //To get all Ecard Details from Server
    getAllEcarddetails() {
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
                this.ecardnamechasislistreject = ecardnamelist;
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
    onbusselectionreject(event) {
        if (event.detail.labelvalue == "Select a Bus") {
            var selectedrejectbus = event.detail.selectedRecord;
            for (var ecard in this.ecardoptions) {
                if (selectedrejectbus == this.ecardoptions[ecard].label) {
                    this.newreject.selectedrejectbus = this.ecardoptions[ecard].label;
                    this.newreject.ecard_id = this.ecardoptions[ecard].value;
                }
            }
        }
    }

    // On clearing the bus selection. added
    onclearbusreject(event) {
        var emptylist = [];
        this.newreject.ecard_id = undefined;
        this.newreject.buspart_no = undefined;
        this.newreject.buspart_name = undefined;
        this.newreject.department_id = undefined;
        this.newreject.buildstation_id = undefined;
        this.newreject.buschasisnumber = undefined;
        this.newreject.qclist = emptylist;
        this.newreject.prodlist = emptylist;
        this.newreject.allQClist = emptylist;
        this.newreject.allPRODlist = emptylist;
    }

    // For getting Buildstation Details on department change for Department Discrepancy.
    getcompleteBuilstationlist(data){
        let workstationdata = data.builstationMapWrapper.workcenter; 
        var prod_supervisor = modifieduserlist(data.builstationMapWrapper.prod_supervisor);
        this.deptsupervisorforselecteddept = prod_supervisor;
        let modifiedworkstationdata = [];
        var QC  = modifieduserlist(data.builstationMapWrapper.qc);
        if(workstationdata.length != 0){
            for(var wc in workstationdata){
                let workcentre = workstationdata[wc];
                let workcenter_id = workcentre.workcenter_id;
                let workcentername = workcentre.workcentername;
                for(var bs in workcentre.buildstation){
                    var buildstation = workcentre.buildstation[bs];
                    var modifiedvalidationlist = this.getmodifiedvalidationlist(buildstation);
                    var PROD = modifieduserlist(buildstation.prod);
                    var selectedprod = getselectedformandetails(buildstation);
                    var selectedqc = modifieduserlist([buildstation.qc_approvedby_id]);
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
                        validationlist : modifiedvalidationlist,
                        selectedprod : selectedprod,
                        selectedqc : selectedqc,
                        PRODlist : PROD,
                        QClist : QC
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

    // When clearing a selected partnumber.
    onpartnumberclearreject(event) {
        this.newreject.buspart_no = undefined;
        this.newreject.buspart_name = undefined;
        if (this.partnumberlistreject == undefined && (event != undefined && event.target.dataset.id == 'partmnumbersearchreject')) {
            this.getbuspartdetails(this.newreject.ecard_id, this.newreject.buildstation_id);
        }
    }
    
     //To update other fields on user selection
     @track isLocationRequired = true;
    async updatenewreject(event){
        var targetvalue = event.target.value;
        var targetname = event.target.name;
        this.newreject[targetname] = targetvalue;
        if(targetname == 'reason_code'){
            for(let i=0;i<this.reasoncode.length;i++){
              if(this.reasoncode[i].Reason_Code__c == event.target.value){
                this.newreject.reason_code_id = this.reasoncode[i].Name;
                this.newreject.supply_chain = event.target.value;

              }
            }
        }
        if(targetname == 'location__c'){
            let selectedLocation = this.locationvaluecode.find(loc => loc.label === event.target.value);   
            if (selectedLocation) {
                this.newreject.location = targetvalue;
                this.newreject.location_id = selectedLocation.value;
            }
        }
        if(targetname == 'partremove'){
            if(event.target.checked == true){
                this.isLocationRequired = true;
            }else{
                this.isLocationRequired = false;
                this.newreject.location = undefined;
                this.newreject.location_id = undefined;
                this.newreject.location__c = undefined;
                this.newreject.location_id__c = undefined;
            }
                this.newreject.partremove = event.target.checked;
        }
        if(this.newreject.department_Name == '' || this.newreject.department_Name == null){
            for(let i=0;i<this.departmentoptionsreject.length;i++){
                if(this.departmentoptionsreject[i].value == this.newreject.department_id){
                    this.newreject.department_Name = this.departmentoptionsreject[i].label;
                
              }
            }
           }
           
        if(targetname == 'department_id'){
            //var ecardid = this.ecardid;
            var ecardid = this.newreject.ecard_id;
            var departmentId = targetvalue;
            this.newreject.department_id = departmentId;
            this.newreject.allPRODlist = [];
            var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" };
            var ecardiddeptid = {ecard_id:ecardid ,dept_id:departmentId};
            await getDepartmentOperations({ecardiddeptid:JSON.stringify(ecardiddeptid)})
            .then(data => {
                var prod_supervisor = modifieduserlist(data.builstationMapWrapper.prod_supervisor);
                this.deptsupervisorforselecteddept = prod_supervisor;
                this.buildstationoptionsreject =  data.buildstationList;
                this.buildstationoptionsreject.push(bs);
                this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                var selectedbuildstation = this.thisdepartmentbuildstations[0];
                this.newreject.buildstation_id = undefined;
                this.newreject.buspart_name = undefined;
                // this.clearpartsvendordetails();
                // Set Prod and QC also
                
                if(selectedbuildstation.QClist!=null && selectedbuildstation.QClist.length != 0){
                    this.newreject.allQClist = selectedbuildstation.QClist;
                }
                if(this.deptsupervisorforselecteddept.length != 0){
                    this.newreject.allPRODlist = this.deptsupervisorforselecteddept;
                }
                this.newreject.qclist = [];
                //this.newreject.prodlist = this.deptsupervisorforselecteddept;
                
            }).catch(error => {
                this.error = error;
                this.showmessage('Data fetch failed.','Something unexpected occured. Please contact your Administrator.','error');
            });
        }
        if(targetname == 'buildstation_id'){
            var buildstationdetails = this.thisdepartmentbuildstations;
            var buildstationId = targetvalue;
            var selectedbuildstation;
            for(var bs in buildstationdetails){
                if(buildstationId.toString() == buildstationdetails[bs].buildstation_id.toString()){
                    selectedbuildstation = buildstationdetails[bs];
                }
            }
            if(this.newreject.buildstation_id=='Unknown'){
                this.newreject.buildstation_id = this.newreject.buildstation_id=='Unknown'?-1:selectedbuildstation.buildstation_id.toString();
            this.newreject.buildstation_Name = this.newreject.buildstation_id=='-1'?'Unknown':selectedbuildstation.buildstation_id.toString();          
            }else{
                this.newreject.buildstation_id = this.newreject.buildstation_id=='Unknown'?-1:selectedbuildstation.buildstation_id.toString();     
            }
            // Reset Part Number data
             this.onpartnumberclearreject();
            //this.template.querySelector('c-operation-actions-component').clear();
            if(this.template.querySelector('[data-id="partmnumbersearchreject"]') != null){
                this.template.querySelector('[data-id="partmnumbersearchreject"]').clear();
            } 
            if(buildstationId!='Unknown'){
                //this.getbuspartdetails(this.ecardid, this.newreject.buildstation_id);
                this.getbuspartdetails(this.newreject.ecard_id, this.newreject.buildstation_id);
            }else{
                var partnumberlistreject = [];
                var partdetails = [];
                var nopartfound = {
                    "buspart_id": null,
                    "buspart_name": undefined,
                    "buspart_no": 'Part No. Not Found',
                    "product_category": null,
                    "unit_of_measure": undefined
                };
                partnumberlistreject.push('Part No. Not Found');
                partdetails.push(nopartfound);
                this.partnumberdetails = partdetails;
                this.partnumberlistreject = partnumberlistreject;
                this.onpartnumberselectionreject(event);
            }
            // Set Prod and QC also    
            var allPRODlist = [];
            var allQClist = [];
            var PRODlist = [];
            if(buildstationId!='Unknown' && selectedbuildstation.QClist!=null && selectedbuildstation.QClist.length != 0){
                allQClist = selectedbuildstation.QClist;
            }
                
            if(buildstationId!='Unknown' && selectedbuildstation.PRODlist!=null && selectedbuildstation.PRODlist.length != 0){
                allPRODlist = selectedbuildstation.PRODlist;
            }
            PRODlist = buildstationId!='Unknown'?selectedbuildstation.selectedprod:[];
               
            var QClist = buildstationId!='Unknown'?selectedbuildstation.selectedqc:[];
            this.newreject.qclist = QClist;
            this.newreject.prodlist = PRODlist;
            this.newreject.allPRODlist = allPRODlist;
            this.newreject.allQClist = allQClist;
        }

        if (this.newreject.allPRODlist.length == 0) {
            var userdetails = [];
            await getcrewingsuserslist({ deptid: this.newreject.department_id })
                .then((result) => {
                    userdetails = JSON.parse(result.responsebody).data.user;
                    this.newreject.allPRODlist = userdetails.length > 0 ? modifieduserlist(userdetails) : userdetails;
                })
                .catch((error) => {
                });
        }
        if(this.newreject.buildstation_Name == '' || this.newreject.buildstation_Name == null){
            if(this.buildstationoptionsreject != null){
            for(let j=0;j<this.buildstationoptionsreject.length;j++){
             if(this.buildstationoptionsreject[j].value == this.newreject.buildstation_id){
                 this.newreject.buildstation_Name = this.buildstationoptionsreject[j].label;
                 
             }
         }
        }

         }
    }
   
    // To hide Report shortage addition Modal
    hideReportRejectAdd(event){
        this.partshortageaddmodalreject = false;
      //  this.deletetempattachments();
    }
    getbuspartdetails(ecardid, buildstationid){
        // Get Bus Part Details
        var ecardidbuildstation = {
            "ecard_id" : ecardid,
            "build_station_id" : buildstationid
        };
        getBusPartdetails({ecardidbuildstationid : JSON.stringify(ecardidbuildstation)})
       .then(data => {
                  if(data.isError){
                    this.showmessage('Sorry we could not fetch the parts list.','Something unexpected occured. Please contact your Administrator.','error');
                  }
                  else{
                      var partsdata = JSON.parse(data.responsebody).data;
                      var partnumberlistreject = [];
                      var partdetails = [];
                      var nopartfound = {
                        "buspart_id": null,
                        "buspart_name": undefined,
                        "buspart_no": 'Part No. Not Found',
                        "product_category": null,
                        "unit_of_measure": undefined
                      };
                      partnumberlistreject.push('Part No. Not Found');
                     partdetails.push(nopartfound);
                      if(partsdata.bus_parts.length != 0){
                        for(var index in partsdata.bus_parts){
                            partdetails.push(partsdata.bus_parts[index]);
                            partnumberlistreject.push(partsdata.bus_parts[index].buspart_no + ' ('+partsdata.bus_parts[index].buspart_name +')');
                        }
                      }
                      this.partnumberdetails = partdetails;
                      this.partnumberlistreject = partnumberlistreject;
                  }
             }).catch(error => {
              this.error = error;
              this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
     
              });
    }
    onpartnumberselectionreject(event){
        if (event.detail.selectedRecord != undefined) {
            this.newreject.buspart_no = event.detail.selectedRecord;
            var partnoname=event.detail.selectedRecord;
            var selectedbuspart = partnoname.substring(0,partnoname.indexOf(' '));
            for(var i in this.partnumberdetails){
                if(selectedbuspart == this.partnumberdetails[i].buspart_no){
                    this.newreject.buspart_no = this.partnumberdetails[i].buspart_no;
                    this.newreject.buspart_name = this.partnumberdetails[i].buspart_name;
                    this.newreject.buspart_id = this.partnumberdetails[i].buspart_id;
                }
            }
        }else{
            this.newreject.buspart_no = 'Part No. Not Found';
            this.newreject.buspart_name = undefined;
            this.newreject.buspart_id = null;
        }
    }
    addnewreject(event){
        this.newreject.status = 'Open';
        const allValid = [...this.template.querySelectorAll('.partshortagevalidationreject')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && this.newreject.buspart_no != undefined) {
         var partshortageaddmodalvalues = this.newreject;
         var ispartavailable = true;
         var part_shortage;
         if(partshortageaddmodalvalues.buspart_no == 'Part No. Not Found'){
            ispartavailable = false;
            part_shortage = {
                "buspart_id": null,
                "quantity": partshortageaddmodalvalues.quantity, 
                "po_no" : partshortageaddmodalvalues.po_no,
                "custom_part_name" : partshortageaddmodalvalues.buspart_name
               };
         }
         else{
            part_shortage = {
                "buspart_id": partshortageaddmodalvalues.buspart_id, 
                "quantity": partshortageaddmodalvalues.quantity, 
                "po_no" : partshortageaddmodalvalues.po_no
               };
         }
         part_shortage['remarks'] = partshortageaddmodalvalues.remarks == undefined ? null : partshortageaddmodalvalues.remarks; //to-do
         
                this.newreject["s3_file_paths"] = null;
           
           this.newreject.rejected_by = this.rejectedby;
           this.newreject.rejected_by_employee_Id = this.EmployeeId;
        var newobj = this.newreject;
                   const { is_b_whs_kit, priority, discrepancy_type, is_long_term, is_ship_short, qclist, allQClist, prodlist, allPRODlist, ...cleanedData } = newobj;
       
                   createReject({rej : cleanedData})
        .then(data=>{
            this.showmessage('Added new Reject.','Record created successfully.','success');
            this.hideReportRejectAdd();
           this.dispatchEvent(new CustomEvent('close',{detail:''}));
           if(this.page == 'rejectdb' || this.page == 'rejecttab'){
            this.dispatchEvent(new CustomEvent('loadtable',{detail:''}));
           }
        }).catch(error => {
            this.error = error;
            this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
        });
           
        }
        else{
            this.showmessage('Please fill all required fields.','Please fill required and update all blank form entries.','warning');
        }
        refreshApex();
        
    }
    updateformans(responsebody, formanlist){
        var newresponse = JSON.parse(responsebody);
        var newformanlist;
        if(formanlist.length > 5){
            newformanlist = formanlist.slice(0, 5);
        }
        else{
            newformanlist = formanlist;
        }
        for(var i=0;i<newformanlist.length;i++){
            newresponse[`forman${i+1}_id`] = newformanlist[i].userid;
            }
        
        return newresponse;
    }
    modifydate(date) {
        var formatteddate = undefined;
        if (date != undefined) {
            var jsdate = new Date(date);
            return jsdate.getFullYear() + "-" + (jsdate.getMonth() + 1) + "-" + jsdate.getDate() + " " + "00:00:00";
        }
        return formatteddate;
    }
    @track picklistOptions = [];
    
    @wire(getObjectInfo, { objectApiName: OBJECT_NAME })
    objectInfo;
 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: PICKLIST_FIELD })
    picklistValues({ error, data }) {
        if (data) {
            this.picklistOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        } else if(error){
        }
    }

}