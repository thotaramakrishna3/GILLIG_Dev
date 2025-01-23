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
import VALUE_REQUIRED_INDICATOR from '@salesforce/schema/Operation_Check_Master_Data__c.Value_Required_Indicator__c';
import VALUE_DESCREPTION from '@salesforce/schema/Operation_Check_Master_Data__c.Value_Description__c';
import CUSTOMER_FIELD from '@salesforce/schema/Operation_Check_Master_Data__c.Account__c';

import getAllAccounts from '@salesforce/apex/OpCkMasterDataController.getAllAccounts';
import getAllBuslists from '@salesforce/apex/OpCkMasterDataController.getAllBuslists'
import getBuslistbyAccount from '@salesforce/apex/OpCkMasterDataController.getBuslistbyAccount';

const columns = [
    { label: "Active", fieldName: "isActive__c", sortable: true, type: "boolean", initialWidth: 60 },
    {
        label: 'Seq Nbr',//Name
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
        wrapText: true 
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
        label: 'OP-CK Seq No.',
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

export default class CreatelistoperationchecksComponent extends LightningElement {
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

    @track transmissionpicklist;
    @track busmodepicklist;

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
    get tableHeight() {
        var height = window.innerHeight * 0.82 - 247.59;
        return `height: ${height}px;`;
    }

    loaddata() {
        this.showSpinner = true;
        this.showTable = false;
        getAllOperationCheck()
            .then((data) => {
                console.log(data);
                for (var item in data) {
                    data[item]['CustomerName'] = data[item].Account__c ? data[item].Account__r.Internal_Name__c : null;
                }
                this.opchklist = data;
                this.showTable = true;
                this.showSpinner = false;
                this.error = undefined;

            })
            .catch((error) => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                    title: "OP-CK Data fetch failed.",
                    message: "Something unexpected occured. Please contact your Administrator",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
    }

    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        if (this.recordsToDisplay[0] != undefined) {
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

    // Row Action event to show the details of the record

    // @track deptchangebsupdate;
    @track busmodeValue;
    // handleRowAction(event) {
    //     const actionName = event.target.name;
    //     const row = event.detail.row;
    //     this.record = row;
    //     if (actionName == 'Update') {
    //         var deprtmentId = this.getdepartmentId(this.record.Department_ID__c);
    //         if (deprtmentId != undefined) {
    //             this.record.Department_ID_value = deprtmentId;
    //             this.loadbuildstationmappingdata(deprtmentId);
    //             this.bShowModal = true; // display modal window
    //         }
    //         else {
    //             const alertmessage = new ShowToastEvent({
    //                 title: "Can't update record.",
    //                 message: "The record is not in correct format.",
    //                 variant: "warning"
    //             });
    //             this.dispatchEvent(alertmessage);
    //         }
    //     }
    // }
    handleRowAction(event) {
        const recordId = event.target.dataset.recordId;
        const selectedRecord = this.opchklist.find((record) => record.Id === recordId);
    
        if (selectedRecord) {
          this.record = { ...selectedRecord };
          this.bShowModal = true; // Display the modal window
        } else {
          const alertmessage = new ShowToastEvent({
            title: "Can't update record.",
            message: "The record is not in the correct format.",
            variant: "warning"
          });
          this.dispatchEvent(alertmessage);
        }}

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
        }
        this.newopckvalue = newopck;
        this.getbuslist();
        this.buildstationlist = [];
        this.addnewmodal = true;
    }

    //UPDATE ACTION :  To Update the Changes made 
    @track deptupdated;
    updateopcktoserver() {
        // const allValid = [...this.template.querySelectorAll('.updatevalidation')]
        //     .reduce((validSoFar, inputCmp) => {
        //         inputCmp.reportValidity();
        //         return validSoFar && inputCmp.checkValidity();
        //     }, true);
        // if (allValid) {
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
            console.log("Value Required? inside UPDATE ", this.record.Value_Required_Indicator__c);
            const recordInput = { fields: fields };
            updateRecord(recordInput).then(record => {
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
                    title: "Failed to Update OP-CK",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            });
        // } else {
        //     const alertmessage = new ShowToastEvent({
        //         title: "Failed to Update OP-CK",
        //         message: "Please fill in the required values ",
        //         variant: "warning"
        //     });
        //     this.dispatchEvent(alertmessage);
        // }
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
    }
    //"Add New OP-CK": To Update to Server on SAVE 
    @track departmentlabel;
    addnewopck() {
        var recordid;
        // const allValid = [...this.template.querySelectorAll('.newopckvalidation')]
        //     .reduce((validSoFar, inputCmp) => {
        //          inputCmp.reportValidity();
        //         return validSoFar && inputCmp.checkValidity();
        //     }, true);
        
        // if (allValid) { 
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
                'Value_Required_Indicator__c': this.newopckvalue.is_value_required,
                'Value_Description__c': this.newopckvalue.value_description,
                'Account__c': this.newopckvalue.customer_id,
            };

            console.log("Transmission Inside Save :", this.newopckvalue.transmission_id);
            const recordInput = { apiName: 'Operation_Check_Master_Data__c', fields };
            createRecord(recordInput).then(response => {
                recordid = response.id;

                const alertmessage = new ShowToastEvent({
                    title: "New OP-CK created successfully!",
                    message: `OP-CK has been created with Record Id :${recordid} `,
                    variant: "success"
                });
                this.dispatchEvent(alertmessage);

                this.addnewmodal = false;
                if (recordid) {
                    this.loaddata();
                }

            }).catch(error => {
                console.log("Inside Catch : ", error.body.message);
                const alertmessage = new ShowToastEvent({
                    title: "Failed to create new OP-CK",
                    message: "Something unexpected occured. Please contact your Administrator ",
                    variant: "error"
                });
                this.dispatchEvent(alertmessage);
            })
        // } else {
        //     const alertmessage = new ShowToastEvent({
        //         title: "Record cannot be created !",
        //         message: "Please fill the required values",
        //         variant: "warning"
        //     });
        //     this.dispatchEvent(alertmessage);
        // }
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

    //To get BS data for the selected department (in UPDATE and Add New OP-CK)
    @track selecteddepartment;
    @track buildstationlist = [];
    loadbuildstationmappingdata(selecteddeptid) {
        this.showSpinner = true;
        //var selecteddeptid = this.selecteddepartment;
        //var selecteddeptid = this.newopckvalue.department_id;
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

    // Fetching Busmode picklist
    @track bmpicklistvalue = [];
    @track hasData = false;
    //@track bmoriginaloptions=[];
    //@track optionNone={'value':'None','label':'None'};
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

    oncustomerselect(event) {
        var accountselected = event.detail.selectedRecord
        this.newopckvalue.customer_name = accountselected;
        // for (var item in this.accountlist) {
        //     if (accountselected == this.accountlist[item].Internal_Name__c) {
        //         this.newopckvalue.customer_id = this.accountlist[item].Id;
        //     }
        // }
        if (event.detail.incident != undefined && event.detail.incident == 'selection') {
            this.getbuslist(event);
        }     
    }
    @track buscustomerid;
    onclearcustomer(event) {
        this.newopckvalue.customer_name = null;
        this.newopckvalue.customer_id = null;
        // if (event.detail.incident != undefined && event.detail.incident == 'selection') {
            this.getbuslist(event);
        // }
    }

    onbusselect(event) {
        var busselected = event.detail.selectedRecord
        this.newopckvalue.bus_name = busselected;
        if (this.newopckvalue.customer_name == null) {
            for (var item in this.buslist) {
                if (busselected == this.buslist[item].Name) {
                    //this.newopckvalue.bus_id = this.buslist[item].Id;
                    //this.buscustomerid = this.buslist[item].Fleet__r.Account__r.Id;
                    this.newopckvalue.customer_name = this.buslist[item].Fleet__r.Account__r.Internal_Name__c;
                }
            }
        }
        if (event.detail.incident != undefined && event.detail.incident == 'selection') {
            //this.handlecustomerselection(event);
        }
    }

    onclearbus(){
        this.newopckvalue.bus_name = null;
        this.newopckvalue.bus_id = null;
        //this.getbuslist(event);
    }

    // @wire(getPicklistValues, {
    //     recordTypeId: '012000000000000AAA',
    //     fieldApiName: Account__c
    // })
    // picklistValues({ data, error }) {
    //     if (data) {
    //         console.log(data);
    //     } else if (error) {
    //         console.log(error);
    //     }
    // }
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
                //var buscustomername = this.newopckvalue.bus_id;
                if (this.buscustomerid == this.accountlist[item].Id) {
                    //this.newopckvalue.customer_id = this.accountlist[item].Id;
                    this.newopckvalue.customer_name = this.accountlist[item].Internal_Name__c;
                }
            }
        }
    }
}