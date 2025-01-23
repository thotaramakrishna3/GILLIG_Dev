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
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_NAME from '@salesforce/schema/Rework__c';
import PICKLIST_FIELD from '@salesforce/schema/Rework__c.Status__c';
import createRework from "@salesforce/apex/ecardOperationsController.createRework";
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import getReasoncode from "@salesforce/apex/ecardOperationsController.getReasoncode";
const FIELDS = [
    'User.FirstName',
    'User.LastName',
    'User.EmployeeNumber'
];
export default class NewReworkComponent extends LightningElement {
    @track reworkedby = USER_ID;
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
    @track addreworkmodal=false;
    @track modifiedshortageslist = [];
    @track partnumberlistrework;
    @track partnumberdetails;
    @track newrework;
    @track shortgecauselist = [];
    @track partsvendorslist = [];
    @track vendornamelist = [];
    @track deptsupervisorforselecteddept;
    @track buildstationoptionsrework; 
    @track thisdepartmentbuildstations = [];
    // Use whenever a true attribute is required in Component.html
    get returntruerework(){
      return true;
    }   

    get enableeditonpartnamerework(){
        return this.newrework.buspart_no != 'Part No. Not Found';
    }

    get buildstationselectedpartrework(){
        if(this.newrework.buildstation_id != undefined){
            return true;
        }
        else{
            return false;
        }
    }
    get ecardnotselectedrework(){
        return this.newrework.ecard_id == undefined;
    }
    get deptnotselectedrework(){
        return this.newrework.department_id == undefined;
    }
   
    @track reworkreasoncode=[];
    connectedCallback(){
        this.getCode();
    }
    @track reasoncode;
    getCode(){
    getReasoncode()
    .then((result) => {
        this.reasoncode = result;
        for(let i=0;i<=result.length;i++){
           if(result[i].RecordType.Name == 'Rework'){
                this.reworkreasoncode.push({
                    "label":result[i].Reason_Code__c,
                    "value":result[i].Reason_Code__c
                });           
            }
       }
    })
    .catch((error) => {
    });
    
}
    @api page;
    @track fullName;
    @track showSpinner = true;
    @track reworkdb = false;
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
    async showReworkAddModal(event) {
        this.showSpinner = true;
        var selectedrejectbus = `${this.busname}, ${this.buschasisnumber}`;
        var ecardid = this.ecardid;
        var options = [];
        for (var i in this.departmentIdMap) {
            if (this.departmentIdMap[i].value != 'None' && this.departmentIdMap[i].label != 'ALL DEPARTMENTS' && this.departmentIdMap[i].label != 'All Departments') {
                options.push(this.departmentIdMap[i]);
            }
        }
        this.departmentoptionsrework = options;
        this.departmentName = this.department;
        if (this.departmentName == 'ALL DEPARTMENTS') {
            this.departmentid = this.departmentoptionsrework[0].value;
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
        var newrework = {}; 
        if (this.page == 'reworkdb') {
            this.reworkdb = true;
        }
        if (this.reworkdb) {
            this.getAllEcarddetails();
            newrework = {
                'buspart_id': undefined,
                'buspart_no': undefined,
                'reworkbuspart_no': undefined,
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
                'supply_chain': undefined,
                'status' : undefined
            };
            this.newrework = newrework;
        }
        else {
            await getDepartmentOperations({ ecardiddeptid: JSON.stringify(ecardiddeptid) })
                .then(data => {
                    var prod_supervisor = modifieduserlist(data.builstationMapWrapper.prod_supervisor);
                    this.deptsupervisorforselecteddept = prod_supervisor;
                    this.buildstationoptionsrework = data.buildstationList;
                    this.buildstationoptionsrework.push(bs);
                    this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                    PRODlist = this.deptsupervisorforselecteddept;
                    var todaydate = new Date();
                    //this.moddifydefectpickvalues(departmentId);   
                    var partno = undefined;
                    var buildstation = undefined;
                    var buildstationid = undefined;
                    var partname = undefined;
                    var partid = null;
                    var reworkedpartno = undefined;
                    partno = this.partnumber;
                    reworkedpartno = this.partnumber
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
                    newrework = {
                        'buspart_id': partid,
                        'buspart_no': partno,
                        'reworkbuspart_no':reworkedpartno,
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
                        'supply_chain': undefined,
                        'status':undefined
                    };
                    this.newrework = newrework;
                }).catch(error => {
                    this.error = error;
                    this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error');
                });
        }
        this.addreworkmodal = true;
        this.showSpinner = false;
    }

    @track ecardoptions;
    @track ecardnamechasislistrework;
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
                this.ecardnamechasislistrework = ecardnamelist;
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
    onbusselectionrework(event) {
        if (event.detail.labelvalue == "Select a Bus") {
            var selectedrejectbus = event.detail.selectedRecord;
            for (var ecard in this.ecardoptions) {
                if (selectedrejectbus == this.ecardoptions[ecard].label) {
                    this.newrework.selectedrejectbus = this.ecardoptions[ecard].label;
                    this.newrework.ecard_id = this.ecardoptions[ecard].value;
                }
            }
        }
    }

    // On clearing the bus selection. added
    onclearbusrework(event) {
        var emptylist = [];
        this.newrework.ecard_id = undefined;
        this.newrework.buspart_no = undefined;
        this.newrework.buspart_name = undefined;
        this.newrework.department_id = undefined;
        this.newrework.buildstation_id = undefined;
        this.newrework.buschasisnumber = undefined;
        this.newrework.qclist = emptylist;
        this.newrework.prodlist = emptylist;
        this.newrework.allQClist = emptylist;
        this.newrework.allPRODlist = emptylist;
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
    onpartnumberclearrework(event) {
        this.newrework.buspart_no = undefined;
        this.newrework.buspart_name = undefined;
        if (this.partnumberlistrework == undefined && (event != undefined && event.target.dataset.id == 'partmnumbersearchrework')) {
            this.getbuspartdetails(this.newrework.ecard_id, this.newrework.buildstation_id);
        }
    }
    onreworkpartnumberclear(event){

        this.newrework.reworkbuspart_no = undefined;
        if (this.partnumberlistrework == undefined && (event != undefined && event.target.dataset.id == 'partmnumbersearchrework')) {
            this.getbuspartdetails(this.newrework.ecard_id, this.newrework.buildstation_id);
        }
    }
    
     //To update other fields on user selection
    async updatenewrework(event){
        var targetvalue = event.target.value;
        var targetname = event.target.name;
        this.newrework[targetname] = targetvalue;
        if(targetname == 'reason_code'){
            for(let i=0;i<this.reasoncode.length;i++){
              if(this.reasoncode[i].Reason_Code__c == event.target.value){

                this.newrework.reason_code_id = this.reasoncode[i].Name;
                this.newrework.supply_chain = event.target.value;
              }
            }
        }
        if(targetname == 'reworkbuspart_no'){
            this.newrework.reworkbuspart_no = event.target.value;
        }
        if(this.newrework.department_Name == '' || this.newrework.department_Name == null){
            for(let i=0;i<this.departmentoptionsrework.length;i++){
                if(this.departmentoptionsrework[i].value == this.newrework.department_id){
                    this.newrework.department_Name = this.departmentoptionsrework[i].label;
                
              }
            }
           }
           if(this.newrework.buildstation_Name == '' || this.newrework.buildstation_Name == null){
            if(this.buildstationoptionsrework != null){
            for(let j=0;j<this.buildstationoptionsrework.length;j++){
             if(this.buildstationoptionsrework[j].value == this.newrework.buildstation_id){
                 this.newrework.buildstation_Name = this.buildstationoptionsrework[j].label;
                 
             }
         }
        }
         }
        if(targetname == 'department_id'){
            //var ecardid = this.ecardid;
            var ecardid = this.newrework.ecard_id;
            var departmentId = targetvalue;
            this.newrework.department_id = departmentId;
            this.newrework.allPRODlist = [];
            var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" };
            var ecardiddeptid = {ecard_id:ecardid ,dept_id:departmentId};
            await getDepartmentOperations({ecardiddeptid:JSON.stringify(ecardiddeptid)})
            .then(data => {
                var prod_supervisor = modifieduserlist(data.builstationMapWrapper.prod_supervisor);
                this.deptsupervisorforselecteddept = prod_supervisor;
                this.buildstationoptionsrework =  data.buildstationList;
                this.buildstationoptionsrework.push(bs);
                this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                var selectedbuildstation = this.thisdepartmentbuildstations[0];
                this.newrework.buildstation_id = undefined;
                this.newrework.buspart_name = undefined;
                // this.clearpartsvendordetails();
                // Set Prod and QC also
                
                if(selectedbuildstation.QClist!=null && selectedbuildstation.QClist.length != 0){
                    this.newrework.allQClist = selectedbuildstation.QClist;
                }
                if(this.deptsupervisorforselecteddept.length != 0){
                    this.newrework.allPRODlist = this.deptsupervisorforselecteddept;
                }
                this.newrework.qclist = [];
                //this.newrework.prodlist = this.deptsupervisorforselecteddept;
                
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
            this.newrework.buildstation_id = this.newrework.buildstation_id=='Unknown'?-1:selectedbuildstation.buildstation_id.toString();
            // Reset Part Number data
             this.onpartnumberclearrework();
            //this.template.querySelector('c-operation-actions-component').clear();
            if(this.template.querySelector('[data-id="partmnumbersearchrework"]') != null){
                this.template.querySelector('[data-id="partmnumbersearchrework"]').clear();
            } 
            if(buildstationId!='Unknown'){
                //this.getbuspartdetails(this.ecardid, this.newrework.buildstation_id);
                this.getbuspartdetails(this.newrework.ecard_id, this.newrework.buildstation_id);
            }else{
                var partnumberlistrework = [];
                var partdetails = [];
                var nopartfound = {
                    "buspart_id": null,
                    "buspart_name": undefined,
                    "buspart_no": 'Part No. Not Found',
                    "product_category": null,
                    "unit_of_measure": undefined
                };
                partnumberlistrework.push('Part No. Not Found');
                partdetails.push(nopartfound);
                this.partnumberdetails = partdetails;
                this.partnumberlistrework = partnumberlistrework;
                this.onpartnumberselectionrework(event);
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
            this.newrework.qclist = QClist;
            this.newrework.prodlist = PRODlist;
            this.newrework.allPRODlist = allPRODlist;
            this.newrework.allQClist = allQClist;
        }
        if (this.newrework.allPRODlist.length == 0) {
            var userdetails = [];
            await getcrewingsuserslist({ deptid: this.newrework.department_id })
                .then((result) => {
                    userdetails = JSON.parse(result.responsebody).data.user;
                    this.newrework.allPRODlist = userdetails.length > 0 ? modifieduserlist(userdetails) : userdetails;
                })
                .catch((error) => {
                });
        }
    }
   
    // To hide Report shortage addition Modal
    hideReworkAddModal(event){
        this.addreworkmodal = false;
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
                      var partnumberlistrework = [];
                      var partdetails = [];
                      var nopartfound = {
                        "buspart_id": null,
                        "buspart_name": undefined,
                        "buspart_no": 'Part No. Not Found',
                        "product_category": null,
                        "unit_of_measure": undefined
                      };
                      partnumberlistrework.push('Part No. Not Found');
                     partdetails.push(nopartfound);
                      if(partsdata.bus_parts.length != 0){
                        for(var index in partsdata.bus_parts){
                            partdetails.push(partsdata.bus_parts[index]);
                            partnumberlistrework.push(partsdata.bus_parts[index].buspart_no + ' ('+partsdata.bus_parts[index].buspart_name +')');
                        }
                      }
                      this.partnumberdetails = partdetails;
                      this.partnumberlistrework = partnumberlistrework;
                  }
             }).catch(error => {
              this.error = error;
              this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
     
              });
    }
    onpartnumberselectionrework(event){
        if (event.detail.selectedRecord != undefined) {
            this.newrework.buspart_no = event.detail.selectedRecord;
            var partnoname=event.detail.selectedRecord;
            var selectedbuspart = partnoname.substring(0,partnoname.indexOf(' '));
            for(var i in this.partnumberdetails){
                if(selectedbuspart == this.partnumberdetails[i].buspart_no){
                    this.newrework.buspart_no = this.partnumberdetails[i].buspart_no;
                    this.newrework.buspart_name = this.partnumberdetails[i].buspart_name;
                    this.newrework.buspart_id = this.partnumberdetails[i].buspart_id;
                }
            }
        }else{
            this.newrework.buspart_no = 'Part No. Not Found';
            this.newrework.buspart_name = undefined;
            this.newrework.buspart_id = null;
        }
    }
    addnewrework(event){
        this.newrework.status = 'Open';
        const allValid = [...this.template.querySelectorAll('.reworkvalidation')]
            .reduce((validSoFar, inputCmp) => {

                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && this.newrework.buspart_no != undefined) {
         var partshortageaddmodalvalues = this.newrework;
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
         
                this.newrework["s3_file_paths"] = null;
           
           this.newrework.rejected_by = this.reworkedby;
           this.newrework.rejected_by_employee_Id = this.EmployeeId;
        var newobj = this.newrework;
                   const { is_b_whs_kit, priority, discrepancy_type, is_long_term, is_ship_short, qclist, allQClist, prodlist, allPRODlist, ...cleanedData } = newobj;

        createRework({rej : cleanedData})
        .then(data=>{
            this.showmessage('Added new Rework.','Record created successfully.','success');
            this.hideReworkAddModal();
           this.dispatchEvent(new CustomEvent('close',{detail:''}));
           if(this.page == 'reworkdb' || this.page == 'reworktab'){
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