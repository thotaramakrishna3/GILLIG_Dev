import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllOperationCheck from "@salesforce/apex/OpCkMasterDataController.getOperationCheckList";
import getallDepartments from "@salesforce/apex/UserListingController.getallDepartments";
import getBuildStationCrewingData from "@salesforce/apex/CrewingScheduleController.getBuildStationCrewingData";
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import RECORD_ID from '@salesforce/schema/Operation_Check_Master_Data__c.Id';
import DEPARTMENT_ID from '@salesforce/schema/Operation_Check_Master_Data__c.Department_ID__c';
import BUILDSTATION_ID from '@salesforce/schema/Operation_Check_Master_Data__c.Build_Station_ID__c';
import DESCREPTION from '@salesforce/schema/Operation_Check_Master_Data__c.Operation_Description__c';
import SEQUENCE_NO from '@salesforce/schema/Operation_Check_Master_Data__c.Operation_Sequence_Number__c';
import IS_ACTIVE from '@salesforce/schema/Operation_Check_Master_Data__c.isActive__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BUSMODE_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Bus_Mode__c';
import TRANSMISSION_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Transmission__c';
import BUSTYPE_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Bus_Type__c';
import BUSLENGTH_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Bus_Length__c';
import VALUE_REQUIRED_INDICATOR from '@salesforce/schema/Operation_Check_Master_Data__c.Value_Required_Indicator__c';
import VALUE_DESCREPTION from '@salesforce/schema/Operation_Check_Master_Data__c.Value_Description__c';
import CUSTOMER_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Account__c';
import ACTIVE_DATE_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Active_Date__c';
import INACTIVE_DATE_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Inactive_Date__c';
import RECORD_TYPE from '@salesforce/schema/Operation_Check_Master_Data__c.RecordTypeId';
import getAllAccounts from '@salesforce/apex/OpCkMasterDataController.getAllAccounts';
import getAllBuslists from '@salesforce/apex/OpCkMasterDataController.getAllBuslists'
import getBuslistbyAccount from '@salesforce/apex/OpCkMasterDataController.getBuslistbyAccount';
import getRecordTypes from '@salesforce/apex/OpCkMasterDataController.getRecordTypes'; // Retrive record types from the OP-CK Object.
import getWorkInstruction from '@salesforce/apex/AddWorkInstruction.getWorkInstruction';
import linkJobsAndWorkInstructions from '@salesforce/apex/AddWorkInstruction.linkJobsAndWorkInstructions';
import getAssociatedWorkInstruction from '@salesforce/apex/AddWorkInstruction.getAssociatedWorkInstruction';
import updateordeleteWorkInstructionLink from '@salesforce/apex/AddWorkInstruction.updateordeleteWorkInstructionLink';

const columns = [
    { label: "Active", fieldName: "isActive__c", sortable: true, type: "boolean", initialWidth: 60 },
    {
        label: 'Seq Nbr',
        fieldName: 'Name',
        sortable: true,
        type: 'text',
        initialWidth: 90
    },
    {
        label: 'Operation Description',
        fieldName: 'Operation_Description__c',
        sortable: true,
        type: 'richtext',
    },
    {
        label: 'Department',
        fieldName: 'Department_ID__c',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Buildstation',
        fieldName: 'Build_Station_ID__c',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Job Seq No.',
        fieldName: 'Operation_Sequence_Number__c',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Bus Mode',
        fieldName: 'Bus_Mode__c',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Transmission',
        fieldName: 'Transmission__c',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Customer',
        fieldName: 'CustomerName',
        sortable: true,
        type: 'text',
    },
    {
        label: 'Active Date',
        fieldName: 'Active_Date__c',
        sortable: true,
        type: 'date-local',
    },
    {
        label: 'Inactive Date',
        fieldName: 'Inactive_Date__c',
        sortable: true,
        type: 'date-local',
    },
    {
        label: 'Action',
        type: 'button',
        typeAttributes: {
            label: 'Update',
            title: 'Click to Edit',
            name: 'Update',
            iconName: 'utility:edit',
            class: 'btn_next'
        }
    },

];
export default class ListoperationchecksComponent extends LightningElement {
    @track columns = columns;
    @track showSpinner;
    @track record = {};
    @track rowOffset = 0;
    @track bShowModal = false;
    @track addnewmodal = false;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track opchklist = [];
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset = 1; //Row number
    @track error;
    @track recordid;
    @track descreption = undefined;
    @track buildstation = undefined;
    @track department = undefined;
    @track sequence = undefined;
    @track isactive = false;
    @track workinstructionlist =[];
    @track selectedWorkInstructions =[];
    @track selectedWorkInstructionslink =[];
    @track updateWorkInstructions =[];
    @track deleteWorkInstructionslink =[];
    @track transmissionpicklist;
    @track busmodepicklist;
    @track isActiveDisable = true; 
    get tableHeight() {
        var height = window.innerHeight * 0.82 - 247.59;
        return `height: ${height}px;`;
    }


    get returntrue() {
        return true;
    }

    connectedCallback() {
        this.loaddata();
        this.getdepartmentvalues();
        this.getAccountlist();
        this.getWorkInstructionCode();
    }

    get bsdisabled() {
        return this.newopckvalue.department_id == undefined;
    }

    get returnfalse() {
        return false;
    }

    get returntrue() {
        return true;
    }

    get disablecustomer() {
        return this.newopckvalue.bus_name != null;
    }

    get disablebusfield() {
        return this.newopckvalue.customer_name == null;
    }

    get transmissiondisabled() {
        return this.newopckvalue.busmodule_id == 'Electric';
    }
getWorkInstructionCode(){
getWorkInstruction()
.then((result) => {
    let workinstructionlist = [];
    for(let i=0;i<result.length;i++){
        this.workinstructionlist.push({
                "label":result[i].Work_Instruction_Title__c,
                "value":result[i].Id.toString()
            });        
    }
})
.catch((error) => {
});

}

    loaddata() {
        this.showSpinner = true;
        this.showTable = false;
        getAllOperationCheck()
            .then((data) => {
                console.log(data);
                for (var item in data) {
                    data[item]['CustomerName'] = data[item].Account__c ? data[item].Account__r.Internal_Name__c : null;
                    data[item]['BusName'] = data[item].Bus__c ? data[item].Bus__r.Name : null;
                }
                this.opchklist = data;
                this.showTable = true;
                this.showSpinner = false;
                this.error = undefined;

            })
            .catch((error) => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                    title: "Jobs Data fetch failed.",
                    message: "Something unexpected occured. Please contact your Administrator",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        if (this.recordsToDisplay[0] != undefined && !isNaN(this.recordsToDisplay[0])) {
    
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
            
        }
    }

    // Used to sort the columns
    sortBy(field, reverse, primer) {
        const key = primer ?
            function (x) {
                return primer(x[field]);
            } :
            function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.recordsToDisplay];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    @track searchValue;
    handleSearchChange(event) {
      this.searchValue = event.detail;
  }
    getAssociateWorkInstruction(jobid){
        getAssociatedWorkInstruction({
            "jobId": jobid
        }).then(result => {
            let data = [];
            for(let i=0;i<result.length;i++){
               data.push({
                "label":result[i].Work_Instruction_Title__c,
                "value":result[i].Id
               });
            }
            this.selectedWorkInstructions = data;
    }).catch(error => {
        const alertmessage = new ShowToastEvent({
            title: "Failed to fetch JobAndWorkInstructionLink",
            message: "Something unexpected occured. Please contact your Administrator ",
            variant: "error"
        });
        this.dispatchEvent(alertmessage);
   });
    }

    // Row Action event to show the details of the record
    @track busmodeValue;
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.record = row;
        console.log('this.record = row;'+JSON.parse(JSON.stringify(this.record)));
       if(this.record.Account__c){
        this.disblejobtype = true;
       }else{
        this.disblejobtype = false;
       }
        if (actionName == 'Update') {
            this.getAssociateWorkInstruction(this.record.Id);
            var deprtmentId = this.getdepartmentId(this.record.Department_ID__c);
        var activeDate = this.record.Active_Date__c;
            if(activeDate == new Date().toISOString().slice(0, 10)) {
                this.isActiveDisable = false; 
            }  
            else if(activeDate > new Date().toISOString().slice(0, 10)) {
            this.isActiveDisable = true;
            } 
            else{
                    this.isActiveDisable = false; 
            }
            if (deprtmentId != undefined) {
                this.record.Department_ID_value = deprtmentId;
                this.loadbuildstationmappingdata(deprtmentId);
                this.bShowModal = true; // display modal window
            }
            else {
                const alertmessage = new ShowToastEvent({
                    title: "Can't update record.",
                    message: "The record is not in correct format.",
                    variant: "warning"
                });
                this.dispatchEvent(alertmessage);
            }
        }
    }

    getdepartmentId(department_name) {
        var department_id;
        for (var item in this.departmentlistoptions) {
            if (this.departmentlistoptions[item].label == department_name) {
                department_id = this.departmentlistoptions[item].value;
            }
        }
        return department_id;
    }

    getdepartmentName(department_id) {
        var department_name;
        for (var item in this.departmentlistoptions) {
            if (this.departmentlistoptions[item].value == department_id) {
                department_name = this.departmentlistoptions[item].label;
            }
        }
        return department_name;
    }

    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }

    closeAddModal() {
        this.addnewmodal = false;
        this.disblejobtype =  false; 
    }
    @track selectedWorkInstructionIds=[];
    addworkinstructionselect(event){
        var detail = event.detail;
        var selectids=[];
        this.selectedWorkInstructionIds = [];
        for (let i = 0; i < detail.userlist.length; i++) {
            selectids.push(detail.userlist[i].value); 
        }
        this.selectedWorkInstructionIds = selectids;
    }
    deleteworkinstructionselect(event){
        const detail = event.detail;
        const index = this.deleteWorkInstructionslink.indexOf(detail);
        if(index == -1){
            this.deleteWorkInstructionslink.push(detail);
        }
    }
    updateworkinstructionselect(event){
        const detail = event.detail;
        let updateworkInstructionId;
            updateworkInstructionId = detail.value;
    const index = this.updateWorkInstructions.indexOf(updateworkInstructionId);
        if(index == -1){
            this.updateWorkInstructions.push(updateworkInstructionId);
        }
    }

    @track newopckvalue;
    addnewopckmodal(event) {        
        var newopck = {
            "department_id": undefined,
            "buildstation_id": undefined,
            "busmodule_id": undefined,
            "transmission_id": undefined,
            "description": undefined,
            "is_value_required": false,
            "value_description": undefined,
            "sequence_no": undefined,
            "is_active": false,
            "customer_id": null,
            "customer_name": null,
            "bus_name": null,
            "active_date" : null,
            "inactive_date" : null
        }
        this.newopckvalue = newopck;
        this.getbuslist();
        this.buildstationlist = [];
        this.addnewmodal = true;
        this.isActiveDisable = false; 
        this.disblejobtype =  false; 
        this.setDefaultRecordType(); 
    }

    //UPDATE ACTION :  To Update the Changes made 
    @track deptupdated;
    updateopcktoserver() {
        const allValid = [...this.template.querySelectorAll('.updatevalidation')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            const descriptionWithoutTags = this.record.Operation_Description__c ? this.record.Operation_Description__c.replace(/(<([^>]+)>)/gi, '') : '';
            if (!this.record.Operation_Description__c || descriptionWithoutTags.trim().length === 0) {
                const alertmessage = new ShowToastEvent({
                    title: "Failed to Update Job, Please fill the operation description.",
                    message: "Please fill in the required values",
                    variant: "warning"
                });
                this.dispatchEvent(alertmessage);
                return;
            }
            if (allValid) {
            const fields = {};
            fields[RECORD_ID.fieldApiName] = this.record.Id;
            fields[DEPARTMENT_ID.fieldApiName] = this.getdepartmentName(this.record.Department_ID_value);
            fields[BUILDSTATION_ID.fieldApiName] = this.record.Build_Station_ID__c;
            fields[DESCREPTION.fieldApiName] = this.record.Operation_Description__c;
            fields[SEQUENCE_NO.fieldApiName] = this.record.Operation_Sequence_Number__c;
            fields[IS_ACTIVE.fieldApiName] = this.record.isActive__c;
            fields[BUSMODE_FIELD.fieldApiName] = this.record.Bus_Mode__c == 'None' ? undefined : this.record.Bus_Mode__c;
            fields[TRANSMISSION_FIELD.fieldApiName] = this.record.Bus_Mode__c == 'Electric' ? null : this.record.Transmission__c;
            fields[VALUE_REQUIRED_INDICATOR.fieldApiName] = this.record.Value_Required_Indicator__c;
            fields[VALUE_DESCREPTION.fieldApiName] = this.record.Value_Description__c;
            fields[CUSTOMER_FIELD.fieldApiName] = this.record.Account__c;
            fields[ACTIVE_DATE_FIELD.fieldApiName] = this.record.Active_Date__c;
            fields[INACTIVE_DATE_FIELD.fieldApiName] = this.record.Inactive_Date__c;
            fields[RECORD_TYPE.fieldApiName] = this.disblejobtype ? this.customerJobRecordTypeId : this.selectedRecordType; 

            console.log("Value Required? inside UPDATE ", this.record.Value_Required_Indicator__c);
            const recordInput = { fields: fields };
            updateRecord(recordInput).then(record => {
                if(this.updateWorkInstructions.length>0 || this.deleteWorkInstructionslink.length>0){
                    this.updateordeleteWorkInstructionLink(this.record.Id);
                }    
                const alertmessage = new ShowToastEvent({
                    title: "Record Updated",
                    message: "Record successfully updated! ",
                    variant: "success"
                });
                this.dispatchEvent(alertmessage);
                this.loaddata();
                this.bShowModal = false;
            }).catch(error => {
                const alertmessage = new ShowToastEvent({
                    title: "Failed to Update Job",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
        } else {
            const alertmessage = new ShowToastEvent({
                title: "Failed to Update Job",
                message: "Please fill in the required values ",
                variant: "warning"
            });
            this.dispatchEvent(alertmessage);
        }
    }
    updateordeleteWorkInstructionLink(jobId){
        for(let i=0;i<this.selectedWorkInstructionIds.length;i++){
                const index = this.deleteWorkInstructionslink.indexOf(this.selectedWorkInstructionIds[i]);
                if (index !== -1) {
                    this.deleteWorkInstructionslink.splice(index,1);
            }
        }
        for(let k=0;k<this.selectedWorkInstructions.length;k++){
            const index = this.updateWorkInstructions.indexOf(this.selectedWorkInstructions[k]);
                if (index !== -1) {
                    this.updateWorkInstructions.splice(index,1);
            }
        }
        for (let j = this.updateWorkInstructions.length - 1; j >= 0; j--) {
            if (!this.selectedWorkInstructionIds.includes(this.updateWorkInstructions[j])) {
                this.updateWorkInstructions.splice(j, 1);
            }
        }
        updateordeleteWorkInstructionLink({
            "jobId": jobId,
            "updatelist": this.updateWorkInstructions,
            "deletelist": this.deleteWorkInstructionslink
        }).then(result => {
            if(result == 'Success'){
this.deleteWorkInstructionslink = [];
this.updateWorkInstructions = [];
this.selectedWorkInstructionIds = [];

            }else if(result == 'Failed'){
                this.deleteWorkInstructionslink = [];
this.updateWorkInstructions = [];
this.selectedWorkInstructionIds = [];
                const alertmessage = new ShowToastEvent({
                    title: "Failed to update or delete WorkInstructionLink",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            }
    }).catch(error => {
        const alertmessage = new ShowToastEvent({
            title: "Failed to update or delete WorkInstructionLink",
            message: "Something unexpected occured. Please contact your Administrator ",
            variant: "error"
        });
        this.dispatchEvent(alertmessage);
   });
}
    // UPDATE ACTION : To get the Changes in Input on UPDATE Action.
    @track bmNoneUpdate;
    updateopck(event) {
        var name = event.target.name;
        var value;
        if (event.target.type == 'checkbox' || event.target.type == 'toggle') {
            value = event.target.checked;
        } else {
            value = event.detail.value;
        }
        this.record[name] = value;
        if (name == 'Department_ID_value') {
            this.record.Build_Station_ID__c = undefined
            this.loadbuildstationmappingdata(value);
        }  
        if(this.record.Bus_Mode__c == 'Electric'){
            this.record.Transmission__c = undefined
        } 
        if (name === 'Active_Date__c'){
            if(value == new Date().toISOString().slice(0, 10)) {
            this.record.isActive__c = true;
            this.isActiveDisable = true; 
        }  
        else if(value > new Date().toISOString().slice(0, 10)) {
            this.record.isActive__c = false;
            this.isActiveDisable = true; 
        } 
        else{
            this.record.isActive__c = false;
            this.isActiveDisable = false; 
        }
    }
  }

    get dstransmission(){
        return this.record.Bus_Mode__c == 'Electric';
    }

    get isvaluedescrequired() {
        return this.newopckvalue.is_value_required;
    }

    updatenewopck(event) {
        var name = event.target.name;
        var value;
        if (event.target.type == 'checkbox' || event.target.type == 'toggle') {
            value = event.target.checked;
        } else {
            value = event.detail.value;
        }
        this.newopckvalue[name] = value;
        if (name == 'department_id') {
            this.newopckvalue.buildstation_id = undefined
            this.loadbuildstationmappingdata(value);
        }

        //if  bus mode electric means transmission id will rest to undefined
        if(this.newopckvalue.busmodule_id == 'Electric'){
            this.newopckvalue.transmission_id = undefined
        }
        if (name === 'active_date'){
            if(value == new Date().toISOString().slice(0, 10)) {
                this.newopckvalue.is_active = true; 
                this.isActiveDisable = true; 
        }  
        else if(value > new Date().toISOString().slice(0, 10)) {
            this.newopckvalue.is_active = false;
            this.isActiveDisable = true; 
        } 
        else{
            this.newopckvalue.is_active = false;
            this.isActiveDisable = false; 
        }
    }
}

    //"Add New JOB": To Update to Server on SAVE 
    @track departmentlabel;
    addnewopck() {
        var recordid;
        const allValid = [...this.template.querySelectorAll('.newopckvalidation')]
            .reduce((validSoFar, inputCmp) => {
                 inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            const descriptionWithoutTags = this.newopckvalue.description ? this.newopckvalue.description.replace(/(<([^>]+)>)/gi, '') : '';
            if(!this.newopckvalue.description || descriptionWithoutTags.trim().length === 0){
            const alertmessage = new ShowToastEvent({
                title: "Failed to Create Job, Please fill the operation description.",
                message: "Please fill in the required values",
                variant: "warning"
            });
            this.dispatchEvent(alertmessage);
            return;
        }

        if (allValid) { 
            if(this.newopckvalue.customer_name != null){
                for(var item in this.accountlist){
                    if(this.newopckvalue.customer_name == this.accountlist[item].Internal_Name__c){
                        this.newopckvalue.customer_id = this.accountlist[item].Id
                    }
                }
            }
            if(this.newopckvalue.bus_name != null){
                for(var item in this.buslist){
                    if(this.newopckvalue.bus_name == this.buslist[item].Name){
                        this.newopckvalue.bus_id = this.buslist[item].Id
                    }
                }
            }
            const fields = {
                'Department_ID__c': this.getdepartmentName(this.newopckvalue.department_id),
                'Build_Station_ID__c': this.newopckvalue.buildstation_id,
                'Operation_Description__c': this.newopckvalue.description,
                'Operation_Sequence_Number__c': this.newopckvalue.sequence_no,
                'isActive__c': this.newopckvalue.is_active,
                'Bus_Mode__c': this.newopckvalue.busmodule_id == 'None' ? undefined : this.newopckvalue.busmodule_id,
                'Transmission__c': this.newopckvalue.transmission_id,
                'Bus_Type__c': this.newopckvalue.bustype_id,
                'Bus_Length__c': this.newopckvalue.buslength_id,
                'Value_Required_Indicator__c': this.newopckvalue.is_value_required,
                'Value_Description__c': this.newopckvalue.value_description,
                'Account__c': this.newopckvalue.customer_id,
                'Bus__c': this.newopckvalue.bus_id,
                'Active_Date__c' : this.newopckvalue.active_date,
                'Inactive_Date__c' : this.newopckvalue.inactive_date,
                'RecordTypeId' : this.disblejobtype ? this.customerJobRecordTypeId : this.selectedRecordType, 
            };

            const recordInput = { apiName: 'Operation_Check_Master_Data__c', fields };
            createRecord(recordInput).then(response => {
                recordid = response.id;
             if(this.selectedWorkInstructionIds.length > 0){
                    this.createJobsAndWorkInstruction(recordid);
                }else{
                const alertmessage = new ShowToastEvent({
                    title: "New Job created successfully!",
                    message: `Job has been created with Record Id :${recordid} `,
                    variant: "success"
                });
                this.dispatchEvent(alertmessage);
                this.disblejobtype =  false; 
                this.addnewmodal = false;
                if (recordid) {
                    this.loaddata();
                }
            }

            }).catch(error => {
                console.log("Inside Catch : ", error.body.message);
                const alertmessage = new ShowToastEvent({
                    title: "Failed to create new Job",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            })
        } else {
            const alertmessage = new ShowToastEvent({
                title: "Record cannot be created !",
                message: "Please fill the required values",
                variant: "warning"
            });
            this.dispatchEvent(alertmessage);
        }
    }
    createJobsAndWorkInstruction(jobId){
        linkJobsAndWorkInstructions({
            "jobId": jobId,
            "workinstructionIds": this.selectedWorkInstructionIds
        }).then(result => {
            if(result == 'Success'){
            const alertmessage = new ShowToastEvent({
                title: "New Job created successfully!",
                message: `Job has been created with Record Id :${jobId} `,
                variant: "success"
            });
            this.dispatchEvent(alertmessage);
            this.disblejobtype =  false; 
                this.addnewmodal = false;
                if (jobId) {
                    this.loaddata();
                }
            }else if(result == 'Failed'){
                const alertmessage = new ShowToastEvent({
                    title: "Failed to create new JobAndWorkInstructionLink",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            }
    }).catch(error => {
        const alertmessage = new ShowToastEvent({
            title: "Failed to create new JobAndWorkInstructionLink",
            message: "Something unexpected occured. Please contact your Administrator ",
            variant: "error"
        });
        this.dispatchEvent(alertmessage);
   });
  }

    //To get Department data to provide the Department options(in UPDATE and Add New OP-CK)
    @track departmentlistoptions;

    getdepartmentvalues(event) {
        getallDepartments()
            .then((result) => {
                var departmentlistvaluesnonassembly = [];
                var departmentlistvaluesassembly = [];
                var departmentsvalues = JSON.parse(result.responsebody).data.departments;

                for (var i in departmentsvalues) {
                    var option = {
                        'value': departmentsvalues[i].department_id.toString(),
                        'label': departmentsvalues[i].department_name,
                    };
                    if (departmentsvalues[i].is_assembly_line) {
                        departmentlistvaluesassembly.push(option);
                    }
                    else {
                        departmentlistvaluesnonassembly.push(option)
                    }
                }
                this.departmentlistoptions = departmentlistvaluesassembly;
            })
            .catch((error) => {
                const alertmessage = new ShowToastEvent({
                    title: "Department data fetch failed.",
                    message: "Something unexpected occured. Please contact your Administrator",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
    }

    //To get BS data for the selected department (in UPDATE and Add New JOB)
    @track selecteddepartment;
    @track buildstationlist = [];
    loadbuildstationmappingdata(selecteddeptid) {
        this.showSpinner = true;
        getBuildStationCrewingData({ deptid: selecteddeptid.toString() })
            .then((result) => {
                if (result.isError) {
                    const alertmessage = new ShowToastEvent({
                        title: "Failed to get Build Station Crew data.",
                        message: JSON.parse(result.responsebody).data.validation_message,
                        variant: "error"
                    });
                    this.dispatchEvent(alertmessage);
                    this.showSpinner = false;
                }
                else {
                    var buildstationdata = JSON.parse(result.responsebody).data.buildstations;
                    console.log("buildstationdata :", buildstationdata);
                    var bsidlist = [];
                    for (var i in buildstationdata) {
                        var bsid = {
                            'value': buildstationdata[i].buildstation_code.toString(),
                            'label': buildstationdata[i].buildstation_code.toString()
                        };
                        bsidlist.push(bsid);
                    }
                    this.buildstationlist = bsidlist;
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                const alertmessage = new ShowToastEvent({
                    title: "Failed to get Build Station data.",
                    message: "Something unexpected occured. Please contact your Administrator",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
                this.showSpinner = false;
            });

    }

    // Fetching Transmission picklist
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: TRANSMISSION_FIELD
    })
    trasmissionlistValues;
        // Fetching Bus Type picklist
        @wire(getPicklistValues, {
            recordTypeId: '012000000000000AAA',
            fieldApiName: BUSTYPE_FIELD
        })
        bustypelistValues;
            // Fetching Bus Length picklist
    // @wire(getPicklistValues, {
    //     recordTypeId: '012000000000000AAA',
    //     fieldApiName: BUSLENGTH_FIELD
    // })
    // buslengthlistValues;

    buslengthlistValues = [];
@track isbuslengthlistValues  = false;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: BUSLENGTH_FIELD
    })
    wiredBusTypes({ data, error }) {
        if (data) {
            const allowedValues = ['29', '35', '40'];
            this.buslengthlistValues = data.values.filter(item =>
                allowedValues.includes(item.value)
            );
            this.isbuslengthlistValues = true;
        } else if (error) {
            console.error('Error loading Bus Type picklist: ', error);
            this.isbuslengthlistValues = false;
        }
    }

    // Fetching Busmode picklist
    @track bmpicklistvalue = [];
    @track hasData = false;
    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: BUSMODE_FIELD
    })
    picklistValues({ data, error }) {
        if (data) {
            var bs = { label: "None", value: "None" };
            this.bmpicklistvalue = JSON.parse(JSON.stringify(data.values));
            this.hasData = true;
            this.bmpicklistvalue.push(bs);
            console.log(this.bmpicklistvalue)
        } else if (error) {
            console.log(error);
            console.log('busmodelist error' + JSON.parse(this.bmpicklistvalue));
        }
    }

    @track disblejobtype = false;
    oncustomerselect(event) {
        var accountselected = event.detail.selectedRecord
        this.newopckvalue.customer_name = accountselected;
        if (event.detail.incident != undefined && event.detail.incident == 'selection') {
            this.getbuslist(event);
        }     
        if (this.newopckvalue.customer_name !== null) {
            this.setDefaultRecordType(); 
            this.disblejobtype =  true; 
        } else {
            this.disblejobtype = false;
        }
    }
    @track buscustomerid;
    onclearcustomer(event) {
        this.newopckvalue.customer_name = null;
        this.newopckvalue.customer_id = null;
            this.getbuslist(event);

            if (this.newopckvalue.customer_name == null || this.newopckvalue.customer_id == null) {
                this.setDefaultRecordType();
                this.disblejobtype =  false; 
            } else {
                this.disblejobtype = true; 
            }
    }

    onbusselect(event) {
        var busselected = event.detail.selectedRecord
        this.newopckvalue.bus_name = busselected;
        if (this.newopckvalue.customer_name == null) {
            for (var item in this.buslist) {
                if (busselected == this.buslist[item].Name) {
                    this.newopckvalue.customer_name = this.buslist[item].Fleet__r.Account__r.Internal_Name__c;
                }
            }
        }
        if (event.detail.incident != undefined && event.detail.incident == 'selection') {
        }
    }

    onclearbus(){
        this.newopckvalue.bus_name = null;
        this.newopckvalue.bus_id = null;
    }

    @track accountlist;
    @track accountnamelist;
    getAccountlist() {
        getAllAccounts()
            .then((data) => {
                this.error = undefined;
                this.accountlist = data;
                var accountnamelist = [];
                for (var item in this.accountlist) {
                    var accountname = this.accountlist[item].Internal_Name__c;
                    if (accountname != null && accountname != '') {
                        accountnamelist.push(accountname);
                    }
                }
                this.accountnamelist = accountnamelist;
            })
            .catch((error) => {
                this.error = error;
            })
    }
    @track buslist;
    @track busnamelist;
    getbuslist(event) {
        if (this.newopckvalue.customer_name != null) {
            getBuslistbyAccount({ customer_internal_name: this.newopckvalue.customer_name })
                .then((data) => {
                    this.error = undefined;
                    this.buslist = data;
                    var busnamelist = [];
                    for (var item in this.buslist) {
                        var busname = this.buslist[item].Name;
                        if (busname != null && busname != '') {
                            busnamelist.push(busname);
                        }
                    }
                    this.busnamelist = busnamelist;
                })
                .catch((error) => {
                    this.error = error;
                })
        }
        else {
            getAllBuslists()
                .then((data) => {
                    this.error = undefined;
                    this.buslist = data;
                    var busnamelist = [];
                    for (var item in this.buslist) {
                        var busname = this.buslist[item].Name;
                        if (busname != null && busname != '') {
                            busnamelist.push(busname);
                        }
                    }
                    this.busnamelist = busnamelist;
                })
                .catch((error) => {
                    this.error = error;
                })
        }

    }

    handlecustomerselection(event){
        if (this.newopckvalue.customer_name == null) {
            for (var item in this.accountlist) {
                if (this.buscustomerid == this.accountlist[item].Id) {
                    this.newopckvalue.customer_name = this.accountlist[item].Internal_Name__c;
                }
            }
        }
    }

    @track selectedRecordType;
    @track recordTypeOptions = [];
    @wire(getRecordTypes)
    wiredRecordTypes({ error, data }) {
        if (data) {
            this.recordTypeOptions = data.filter(recordType => recordType.Name !== 'Customer Job').map(recordType => ({
                label: recordType.Name,
                value: recordType.Id,
            }));
            const standardJobRecordType = data.find(recordType => recordType.Name === 'Standard Job');
            if (standardJobRecordType) {
                this.selectedRecordType = standardJobRecordType.Id;
            }
            const customerJobRecordType = data.find(recordType => recordType.Name === 'Customer Job');
            if (customerJobRecordType) {
                this.customerJobRecordTypeId = customerJobRecordType.Id;
            }
            else{
                this.handleRecordTypeChange();
            }
        } else if (error) {
            console.log('Error' +error)
        }
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
   }

    setDefaultRecordType() {
        const defaultRecordType = this.recordTypeOptions.find(option => option.label === 'Standard Job');
        if (defaultRecordType) {
            this.selectedRecordType = defaultRecordType.value;
        }
     }

    // end 
}