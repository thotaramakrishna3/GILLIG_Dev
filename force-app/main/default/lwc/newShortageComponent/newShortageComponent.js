import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getDepartmentOperations from "@salesforce/apex/ecardOperationsController.getDepartmentOperations";
import getcrewingsuserslist from "@salesforce/apex/CrewingScheduleController.getcrewingsuserslist";
import {modifieduserlist, getmoddeddate, getselectedformandetails}  from 'c/userPermissionsComponent';
import getBusPartdetails from "@salesforce/apex/ecardOperationsController.getBusPartdetails";
import deleteTempAttachment from "@salesforce/apex/ecardOperationsController.deleteTempAttachment";
import raisenewShortage from "@salesforce/apex/ecardOperationsController.raisenewShortage";
import raisenewMultipleShortage from "@salesforce/apex/ecardOperationsController.raisenewMultipleShortage";
import getPartshortagecauselist from "@salesforce/apex/ecardOperationsController.getPartshortageCauses";
import getDefaultVendorandBuyer from '@salesforce/apex/ecardOperationsController.getDefaultVendorandBuyer';
import getAllpartsVendorlist from '@salesforce/apex/ecardOperationsController.getAllpartsVendorlist';
import getAllEcarddetailsfromServer from "@salesforce/apex/DiscrepancyDatabaseController.getAllEcarddetails";
import pubsub from 'c/pubsub' ;
import getEcarddataWrapper from '@salesforce/apex/ecardListController.getEcarddataWrapper';

export default class NewShortageComponent extends LightningElement {
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
    //used to display/hide the shortage button based on role access
    get btndisabled() {
        if (this.permissionset != undefined) {
            return !this.permissionset.shortage_new.write;
        } else
            return false;
    }

    @track partshortageaddmodal=false;
    @track modifiedshortageslist = [];
    @track partnumberlist;
    @track partnumberdetails;
    @track newpartshortage;
    @track shortgecauselist = [];
    @track partsvendorslist = [];
    @track vendornamelist = [];
    @track deptsupervisorforselecteddept;
    @track buildstationoptions; 
    @track thisdepartmentbuildstations = [];
    @track priorityoptions = [{"label":"High", "value":"High"}, {"label":"Normal", "value":"Normal"}, {"label":"Low", "value":"Low"}] ;
    // Use whenever a false attribute is required in Component.html
    get returnfalse(){
        return false;
    }

    // Use whenever a true attribute is required in Component.html
    get returntrue(){
      return true;
    }   

    get enableeditonpartname(){
        return this.newpartshortage.buspart_no != 'Part No. Not Found';
    }

    get buildstationselectedpart(){
        if(this.newpartshortage.buildstation_id != undefined){
            return true;
        }
        else{
            return false;
        }
    }
    get ecardnotselected(){
        return this.newpartshortage.ecard_id == undefined;
    }
    get deptnotselected(){
        return this.newpartshortage.department_id == undefined;
    }
    // Use whenever a true attribute is required in Component.html
    get returntrue() {
        return true;
    }

    @api page;
    @track shortagedb = false;
    // To show Report shortage addition Modal
    async showReportShortageAdd(event) {
        var selectedbus = `${this.busname}, ${this.buschasisnumber}`;
        this.selectedfleetonload = this.buschasisnumber;
        var ecardid = this.ecardid;
        var options = [];
        for (var i in this.departmentIdMap) {
            if (this.departmentIdMap[i].value != 'None' && this.departmentIdMap[i].label != 'ALL DEPARTMENTS' && this.departmentIdMap[i].label != 'All Departments') {
                options.push(this.departmentIdMap[i]);
            }
        }
        this.departmentoptions = options;
        this.departmentName = this.department;
        if (this.departmentName == 'ALL DEPARTMENTS') {
            this.departmentid = this.departmentoptions[0].value;
        }
        else {
            this.departmentid = this.departmentid;
        }
        var departmentId = this.departmentid;
        var ecardiddeptid = { ecard_id: ecardid, dept_id: departmentId };
        var emptylist = [];
        var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" }
        var newpartshortage = {}; 
        if (this.page == 'shortagedb') {
            this.shortagedb = true;
        }
        if (this.shortagedb) {
            this.getAllEcarddetails();
            newpartshortage = {
                'buspart_id': undefined,
                'buspart_no': undefined,
                'buspart_name': undefined,
                'quantity': undefined,
                'po_no': undefined,
                'cut_off_date': undefined,
                'selectedbus': undefined,
                'discrepancy_type': 'partshortage',
                'department_id': undefined,
                'ecard_id': undefined,
                'priority': 'Normal',
                'buildstation_id': undefined,
                'buschasisnumber': undefined,
                'date': getmoddeddate(new Date()),
                'is_b_whs_kit': false,
                'is_long_term': false,
                'is_ship_short': false,
                'remarks': undefined
            };
            this.newpartshortage = newpartshortage;
        }
        else {
            await getDepartmentOperations({ ecardiddeptid: JSON.stringify(ecardiddeptid) })
                .then(data => {
                    this.buildstationoptions = data.buildstationList;
                    this.buildstationoptions.push(bs);
                    this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                    var todaydate = new Date();  
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
                    var buildstationdetails = this.thisdepartmentbuildstations;
                    var selectedbsstation;
                    if (buildstationid != undefined) {
                        for (var item in buildstationdetails) {
                            if (buildstationid.toString() == buildstationdetails[item].buildstation_id.toString()) {
                                selectedbsstation = buildstationdetails[item];
                            }
                        }
                    }
                    newpartshortage = {
                        'buspart_id': partid,
                        'buspart_no': partno,
                        'buspart_name': partname,
                        'quantity': undefined,
                        'po_no': undefined,
                        'cut_off_date': undefined,
                        'selectedbus': selectedbus,
                        'discrepancy_type': 'partshortage',
                        'department_id': departmentId.toString(),
                        'ecard_id': ecardid,
                        'priority': 'Normal',
                        'buildstation_id': buildstationid,
                        'buschasisnumber': this.buschasisnumber,
                        'date': getmoddeddate(todaydate),
                        'is_b_whs_kit': false,
                        'is_long_term': false,
                        'is_ship_short': false
                    };
                    this.newpartshortage = newpartshortage;
                }).catch(error => {
                    this.error = error;
                    this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error','dismissible');
                });
        }
        this.partshortageaddmodal = true;
    }

    @track ecardoptions;
    @track ecardnamechasislist;
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
                    this.newpartshortage.ecard_id = this.ecardoptions[ecard].value;
                }
            }
        }
    }

    // On clearing the bus selection. added
    onclearbus(event) {
        var emptylist = [];
        this.newpartshortage.ecard_id = undefined;
        this.newpartshortage.buspart_no = undefined;
        this.newpartshortage.buspart_name = undefined;
        this.newpartshortage.department_id = undefined;
        this.newpartshortage.buildstation_id = undefined;
        this.newpartshortage.buschasisnumber = undefined;
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
    showmessage(title, message, variant,mode){
        const alertmessage = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant,
            mode : mode
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
    onpartnumberclear(event) {
        this.newpartshortage.buspart_no = undefined;
        this.newpartshortage.buspart_name = undefined;
        if (this.partnumberlist == undefined && (event != undefined && event.target.dataset.id == 'partmnumbersearch')) {
            this.getbuspartdetails(this.newpartshortage.ecard_id, this.newpartshortage.buildstation_id);
        }
    }
    
     //To update other fields on user selection
    async updatenewpartshortage(event){
        var targetvalue = event.target.value;
        var targetname = event.target.name;
        this.newpartshortage[targetname] = targetvalue;
        if(targetname == 'department_id'){
            var ecardid = this.newpartshortage.ecard_id;
            var departmentId = targetvalue;
            this.newpartshortage.department_id = departmentId;
            var bs = { label: "Unknown", value: "Unknown", workcentreId: 0, workcentreName: "0000" };
            var ecardiddeptid = {ecard_id:ecardid ,dept_id:departmentId};
            await getDepartmentOperations({ecardiddeptid:JSON.stringify(ecardiddeptid)})
            .then(data => {
                this.buildstationoptions =  data.buildstationList;
                this.buildstationoptions.push(bs);
                this.thisdepartmentbuildstations = this.getcompleteBuilstationlist(data);
                var selectedbuildstation = this.thisdepartmentbuildstations[0];
                this.newpartshortage.buildstation_id = undefined;
                this.newpartshortage.buspart_name = undefined;
                
            }).catch(error => {
                this.error = error;
                this.showmessage('Data fetch failed.','Something unexpected occured. Please contact your Administrator.','error','dismissible');
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
            this.newpartshortage.buildstation_id = this.newpartshortage.buildstation_id=='Unknown'?-1:selectedbuildstation.buildstation_id.toString();
            // Reset Part Number data
             this.onpartnumberclear();
            if(this.template.querySelector('[data-id="partmnumbersearch"]') != null){
                this.template.querySelector('[data-id="partmnumbersearch"]').clear();
            } 
            if(buildstationId!='Unknown'){
                this.getbuspartdetails(this.newpartshortage.ecard_id, this.newpartshortage.buildstation_id);
            }else{
                var partnumberlist = [];
                var partdetails = [];
                var nopartfound = {
                    "buspart_id": null,
                    "buspart_name": undefined,
                    "buspart_no": 'Part No. Not Found',
                    "product_category": null,
                    "unit_of_measure": undefined
                };
                partnumberlist.push('Part No. Not Found');
                partdetails.push(nopartfound);
                this.partnumberdetails = partdetails;
                this.partnumberlist = partnumberlist;
                this.onpartnumberselection(event);
            }
         }
    }
    
    // To hide Report shortage addition Modal
    hideReportShortageAdd(event){
        this.partshortageaddmodal = false;
        this.ismultipleshortage = false;
        this.fleetlist = [];
        this.deletetempattachments();
    }
    
    // Section for Part Shortage Actions and Operations.
    // To get the Bus Part Details
    getbuspartdetails(ecardid, buildstationid){
        // Get Bus Part Details
        var ecardidbuildstation = {
            "ecard_id" : ecardid,
            "build_station_id" : buildstationid
        };
        getBusPartdetails({ecardidbuildstationid : JSON.stringify(ecardidbuildstation)})
       .then(data => {
                  if(data.isError){
                    this.showmessage('Sorry we could not fetch the parts list.','Something unexpected occured. Please contact your Administrator.','error','dismissible');
                  }
                  else{
                      var partsdata = JSON.parse(data.responsebody).data;
                      var partnumberlist = [];
                      var partdetails = [];
                      var nopartfound = {
                        "buspart_id": null,
                        "buspart_name": undefined,
                        "buspart_no": 'Part No. Not Found',
                        "product_category": null,
                        "unit_of_measure": undefined
                      };
                     partnumberlist.push('Part No. Not Found');
                     partdetails.push(nopartfound);
                      if(partsdata.bus_parts.length != 0){
                        for(var index in partsdata.bus_parts){
                            partdetails.push(partsdata.bus_parts[index]);
                            partnumberlist.push(partsdata.bus_parts[index].buspart_no + ' ('+partsdata.bus_parts[index].buspart_name +')');
                        }
                      }
                      this.partnumberdetails = partdetails;
                      this.partnumberlist = partnumberlist;
                  }
             }).catch(error => {
              this.error = error;
              this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
     
              });
    }
    // When Selecting a partnumber filling the description accordingly.
    onpartnumberselection(event){
        if (event.detail.selectedRecord != undefined) {
            this.newpartshortage.buspart_no = event.detail.selectedRecord;
            var partnoname=event.detail.selectedRecord;
            var selectedbuspart = partnoname.substring(0,partnoname.indexOf(' '));
            for(var i in this.partnumberdetails){
                if(selectedbuspart == this.partnumberdetails[i].buspart_no){
                    this.newpartshortage.buspart_name = this.partnumberdetails[i].buspart_name;
                    this.newpartshortage.buspart_id = this.partnumberdetails[i].buspart_id;
                }
            }
        }else{
            this.newpartshortage.buspart_no = 'Part No. Not Found';
            this.newpartshortage.buspart_name = undefined;
            this.newpartshortage.buspart_id = null;
        }
    }
    @track s3tempurlfornewdiscrepancy = [];
    // Get the temporary urls from the attachmenttempComponent.
    gets3tempurls(event){
        this.s3tempurlfornewdiscrepancy = event.detail.tempurllist;
    }
    // Add New Part Shortage to Server 
    @track isLoadingAPI = false;
    addnewpartshortage(event){
        // Check Validations
        const allValid = [...this.template.querySelectorAll('.partshortagevalidation')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
            const customerValid = !this.ismultipleshortage || this.selectedCustomer.length > 0;
const fleetValid = !this.ismultipleshortage || this.selectedFleet.length > 0;
        if (allValid && customerValid && fleetValid && this.newpartshortage.buspart_no != undefined) {
         var partshortageaddmodalvalues = this.newpartshortage;
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

            part_shortage['is_b_whs_kit'] = partshortageaddmodalvalues.is_b_whs_kit == undefined ? null : partshortageaddmodalvalues.is_b_whs_kit;
         part_shortage['remarks'] = partshortageaddmodalvalues.remarks == undefined ? null : partshortageaddmodalvalues.remarks; //to-do
         var bsid= partshortageaddmodalvalues.buildstation_id==-1?null:partshortageaddmodalvalues.buildstation_id;
         var newpartshortagebody = {
                "component": null,  
                "cut_off_date": new Date(partshortageaddmodalvalues.cut_off_date),
                "dat_defect_code_id": null, //"21",
                "department_id": partshortageaddmodalvalues.department_id,
                "discrepancy": partshortageaddmodalvalues.buspart_name,
                "discrepancy_priority": partshortageaddmodalvalues.priority,
                "discrepancy_status": "open",
                "discrepancy_type": "partshortage", 
                "root_cause": null,
                "buildstation_id" : bsid,
                "part_shortage" : part_shortage
            };
            if(this.selectedFleet.length !=0){
                newpartshortagebody["ecard_id"] = [...new Set(this.selectedFleet.map(String))];
            }else{
                newpartshortagebody["ecard_id"] = partshortageaddmodalvalues.ecard_id;
            }
            if(this.s3tempurlfornewdiscrepancy.length != 0){
                newpartshortagebody["s3_file_paths"] = JSON.stringify(this.s3tempurlfornewdiscrepancy);
            }
            else{
                newpartshortagebody["s3_file_paths"] = null;
            }
           var withforemans =newpartshortagebody;
           if(this.ismultipleshortage != true){
            raisenewShortage({requestbody:JSON.stringify(withforemans)})
              .then(data => {
                  if(data.isError){
                    this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
                  }
                  else {
                      var err_msg = JSON.parse(data.operationlogresponse).data.msg;
                      if (err_msg != undefined) {
                          this.showmessage('Can\'t create a record.', `${err_msg}`, 'warning','dismissible');
                      }
                      else {
                          this.showmessage('Added new Shortage.', 'A new shortage was successfully raised.', 'success','dismissible');
                          this.partshortageaddmodal = false;
                          pubsub.fire('refreshdata', undefined);
                      }                    
                  }
                    
              }).catch(error => {
              this.error = error;
              this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
              });
            }else{
                this.isLoadingAPI = true;
                raisenewMultipleShortage({requestbody:JSON.stringify(withforemans)})
              .then(data => {
                  if(data.isError){
                    this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
                  }
                  else {
                      
                      var warning_msg=[];
                      var success_msg=[];
                      var failed_msg = JSON.parse(data.operationlogresponse).data.failed;
                      var success = JSON.parse(data.operationlogresponse).data.successful;
                      
                      for(var i=0;i<failed_msg.length;i++){
                        warning_msg.push({
                            ecard_id: failed_msg[i].ecard_id,
                            message: failed_msg[i].message
                        });
                      }
                      for(var i=0;i<success.length;i++){
                          success_msg.push(success[i].ecard_id);
                      }
                      let warningEcardIds = warning_msg.map(item => item.ecard_id);

let matchingChassisNumber = this.customerfleetlist
    .filter(item => warningEcardIds.includes(item.ecard_id))
    .map(item => {
        let warning = warning_msg.find(warn => warn.ecard_id === item.ecard_id);
        return `${item.chassis_no}\n${warning ? warning.message : "No message available"}`;
    });

var failedmsg = matchingChassisNumber.join("\n");

                      let matchingChassisNumbers = this.customerfleetlist
                          .filter(item => success_msg.includes(item.ecard_id))
                          .map(item => item.chassis_no);
                      
                          var successmsg = matchingChassisNumbers.join(", ");
                      if (failed_msg && failed_msg.length > 0) {
                          this.showmessage('Can\'t create these record.', `${failedmsg}`, 'warning','sticky');
                          this.isLoadingAPI = false;
                      }
                      if(success_msg && success_msg.length > 0) {
                          this.showmessage('These new shortage was successfully raised.',`${successmsg}`, 'success','dismissible');
                          this.partshortageaddmodal = false;
                          this.ismultipleshortage = false;
                          this.isLoadingAPI = false;
                          pubsub.fire('refreshdata', undefined);
                      }else{
                        this.isLoadingAPI = false;
                        this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
                      }                    
                  }
                    
              }).catch(error => {
              this.error = error;
              this.isLoadingAPI = false;
              this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
              });
            }
           
        }
        else{
            this.showmessage('Please fill all required fields.','Please fill required and update all blank form entries.','warning','dismissible');
        }
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
                        this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
                        
                      }
                      else{
                      }
                        
                  }).catch(error => {
                  this.error = error;
                  this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error','dismissible');
                  });
        
        }
    }
    // Update new shortage checkbox values
    updatenewpartshortagecheckbox(event) {
        var targetvalue = event.target.checked;
        var targetname = event.target.name;
        this.newpartshortage[targetname] = targetvalue;
    }
    @track ismultipleshortage= false;
    @track customerlist = [];
    @track fleetlist = [];
    @track customerfleetlist = [];
    @track selectedCustomer = [];
    @track selectedFleet = [];
    @track selectedfleetonload;
    updatemultipleshortagecheckbox(event) {   
        this.ismultipleshortage = event.target.checked;
        
    }
    connectedCallback() {
        this.loadfleetsdata();
    }
    loadfleetsdata(event) {
        var statuslist = ["WIP", "Staging", "Out of Factory"];
        var modifiedList = statuslist.map(val => val.replaceAll(" ", "%20"));
        var statusparm = { bus_status: [ ...modifiedList] };
    getEcarddataWrapper({status : JSON.stringify(statusparm)})
      .then(data => {
        let newCustomerList = [];
        let customerfleetlist = [];
        let customerSet = new Set();

        for (var index in data.ecarddata) {
            var ecard = data.ecarddata[index];       
            if (!customerSet.has(ecard.customer_name)) { 
                customerSet.add(ecard.customer_name);
                newCustomerList.push({ label: ecard.customer_name, value: ecard.customer_name });
            }
            customerfleetlist.push({ customer_name: ecard.customer_name, ecard_id: ecard.ecard_id, chassis_no: ecard.chassis_no });
        }
        this.customerlist = [...newCustomerList];
        this.customerfleetlist = [...customerfleetlist];
    })
    .catch(error => {
      });
    }
    updatecustomerselect(event) {
    let selectcustomer = event.detail;
    let selectedValues = [];
    for (let item of selectcustomer.userlist) {
        selectedValues.push(item.value);
    }
    if (!this.selectedCustomer) {
        this.selectedCustomer = [];
    }
    this.selectedCustomer = this.selectedCustomer.filter(customer => selectedValues.includes(customer));
    selectedValues.forEach(value => {
        if (!this.selectedCustomer.includes(value)) {
            this.selectedCustomer.push(value);
        }
    });
    let filteredFleets = this.customerfleetlist
        .filter(item => this.selectedCustomer.includes(item.customer_name))
        .map(item => ({ label: item.chassis_no, value: item.ecard_id }))
        .sort((a, b) => a.label.localeCompare(b.label));
    
    this.fleetlist = filteredFleets.filter(fleet => fleet.label !== this.selectedfleetonload);

    }
    updatefleetselect(event) {
        let selectfleet = event.detail;
    let selectedValues = [];
    for (let item of selectfleet.userlist) {
        selectedValues.push(item.value);
    }
    this.selectedFleet = this.selectedFleet.filter(customer => selectedValues.includes(customer));
    selectedValues.forEach(value => {
        if (!this.selectedFleet.includes(value)) {
            this.selectedFleet.push(value);
        }
    });
       if(this.ismultipleshortage == true && this.newpartshortage.ecard_id == undefined) {
       this.newpartshortage.ecard_id = this.selectedFleet[0];
       }else{
        this.selectedFleet.push(this.newpartshortage.ecard_id);
       }
    }
    //To create custome date formate 2021-07-14 to 2021-07-14 00:00:00
    modifydate(date) {
        var formatteddate = undefined;
        if (date != undefined) {
            var jsdate = new Date(date);
            return jsdate.getFullYear() + "-" + (jsdate.getMonth() + 1) + "-" + jsdate.getDate() + " " + "00:00:00";
        }
        return formatteddate;
    }
}