import { LightningElement,track,wire,api } from 'lwc';
import getReject from '@salesforce/apex/GetRejectList.getData';
import getRecordDetails from '@salesforce/apex/GetRejectList.getUpdateRecord';
import updateReject from '@salesforce/apex/GetRejectList.updateReject';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import {refreshApex} from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import {getmoddeddate,permissions}  from 'c/userPermissionsComponent';
import getRejectImageFiles from "@salesforce/apex/ecardOperationsController.getRejectImageFiles";
import getallUsers from "@salesforce/apex/UserListingController.getallUsers";
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
import getDepartmentdata from "@salesforce/apex/masterDataController.getDepartmentdata";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_NAME from '@salesforce/schema/Reject__c';
import PICKLIST_FIELD from '@salesforce/schema/Reject__c.Status__c';
import REASON_OBJECT_NAME from '@salesforce/schema/Reason_Code__c';
import getSupplyChaincode from "@salesforce/apex/ecardOperationsController.getReasoncode";
import getlocationcode from "@salesforce/apex/ecardOperationsController.getLocationcode";
const FIELDS = [
    'User.FirstName',
    'User.LastName',
    'User.EmployeeNumber'
];
export default class RejectDbComponent extends LightningElement {
    @track filteredrejects=[];
    @track attachmentsize=0;
    @track isrejectpresent;
    @track rejectimagelist = [];
    @track rejectedby = USER_ID;
    @track nosearchdata=[];
    @track employeeId;
    @track customernamechasislist = [];
    @track rowNumberOffset = 1;
    @track refreshKey = 0;
    @track ShowRejectModal = false;
    @track refreshRejectData;
    @track isImageLoading;
    @track showtable = false;
    @track IsupdateDisable = true;
    userId = USER_ID;
    @track fullName;
    @track showSpinner;
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    user({ error, data }) {
        if (error) {
            console.error('Error retrieving user data: ', error);
        } else if (data) {
            this.fullName = `${data.fields.FirstName.value} ${data.fields.LastName.value}`;
            this.employeeId = data.fields.EmployeeNumber.value;
        }
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
      @track supplyChainPicklistOptions = [];
      @track rejectRecordTypeId;
      @wire(getObjectInfo, { objectApiName: REASON_OBJECT_NAME })
      rejectObjectInfo({ data, error }) {
        if (data) {
            // Find the RecordTypeId for the "Reject" record type
            const recordTypes = data.recordTypeInfos;
            this.rejectRecordTypeId = Object.keys(recordTypes).find(
                (recordTypeId) => recordTypes[recordTypeId].name === 'Reject'
            );
        } else if (error) {
            console.error('Error fetching reject object info:', error);
        }
    }
    getCode(){
        getSupplyChaincode()
        .then((result) => {
            this.reasoncode = result;
            for(let i=0;i<=result.length;i++){
                if(result[i].RecordType.Name == 'Reject'){
                    this.supplyChainPicklistOptions.push({
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
@track userdata = new Map();
connectedCallback(){
    this.getuserdata();
    this.getPermissionsfromserver();
    this.setdepartmentidmap();
    this.getCode();
    this.getLocationCode();
}
 async getuserdata(){
    this.showSpinner = true;
     await getallUsers()
    .then(data => {
        var dataa = JSON.parse(data.responsebody).data.user
        dataa.forEach(user => {
            this.userdata.set(user.employee_number,user.first_name+' '+user.last_name);
        });
    })
    .catch(error => {
        console.error('Error retrieving user data: ', error);
    });
}
wiredPermissions;
permissionset;
getPermissionsfromserver(event) {
  getPermissions()
    .then((data) => {
      this.wiredPermissions = JSON.parse(data.responsebody);
      this.permissionset = permissions(this.wiredPermissions);
      this.error = undefined;
    })
    .catch((error) => {
      this.error = error;
      this.wiredPermissions = undefined;
    });
}
    @wire(getReject)
loaddata(results) {
    setTimeout(() => {       
    this.refreshRejectData = results;
    if (results.data) {
        // Create a copy of the data with added UserName property
        this.filteredrejects = results.data.map(item => {
            let userId = item.Rejected_By_Employee_Id;
            let userName = this.userdata.get(userId) || 'Unknown'; // Provide a fallback value if userName is not found

            // Create a new object with all properties of item and add UserName
            return { ...item, UserName: userName };
        });

        // Copy filteredrejects to nosearchdata
        this.nosearchdata = [...this.filteredrejects];
        this.showSpinner = false;
        this.showtable = true;
    } else if (results.error) {
        // Proper error handling
        console.error('Error loading data:', results.error);
    }
}, 3000);
}
    handlePaginatorChange(event) {        
        this.filteredrejects = event.detail;
        if (this.filteredrejects[0] != undefined && !isNaN(this.filteredrejects[0])) {    
            this.rowNumberOffset = this.filteredrejects[0].rowNumber - 1;           
        }
    }
    closeModal(){
        this.ShowRejectModal = false;
        this.viewdetails = false;
    }
    showmessage(title, message, variant){
        const alertmessage = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(alertmessage);
    }
    @track viewdetails = false;
    showrejectdetail(event){
        this.viewdetails = true;
this.handleUpdate(event);
    }
    @track isupdated = false;
    @track updateRecord;
    handleUpdate(event){ 
        this.IsupdateDisable = true;      
        var recid = event.target.dataset.id;
        getRecordDetails({ids:recid})
        .then(results => {
            console.log(JSON.stringify(results));
            for(let i=0;i<results.length;i++){
            this.updateRecord={
                'Id':results[i].Id,
                'Ecard_Id':results[i].Ecard_Id,
                'Name' : results[i].Name,
                'Department__c' : results[i].Department,
                'Buildstation__c' : results[i].Buildstation,
                'Bus_Part_Number__c' : results[i].Bus_Part_Number,
                'Reject_Description__c' : results[i].Reject_Description,
                'Quantity_Rejected__c' : results[i].Quantity_Rejected,
                'Reason_Code__c': results[i].Reason_Code,
                'Remarks__c' : results[i].Remark,
                'Status__c' : results[i].Status,
                'Supply_Chain__c' : results[i].Supply_Chain,
                'createddate':getmoddeddate(results[i].CreatedDate),
                'Rejected_by':this.userdata.get(results[i].Rejected_By_Employee_Id),
                'location__c':results[i].Location,
                'partremove':results[i].partremove
            }
            if(results[i].partremove == true){
                this.isLocationRequired = true;
            }
        }
        this.getFilesfromserver(event);
        this.isupdated = this.permissionset.reject_update.write;
        if(this.viewdetails){
            this.isupdated = false;
        }
        this.ShowRejectModal = true;
        }).catch(error => {
            this.error = error;
            this.showmessage('Data fetch failed.', 'Something unexpected occured. Please contact your Administrator.', 'error');
        })
    }
    @track searchValue;
    handleSearchChange(event) {
      this.searchValue = event.detail;
  }
    @track isLocationRequired = false;
    updatenewreject(event){
        this.IsupdateDisable = false;
        var targetvalue = event.target.value;
        var targetname = event.target.name;
        if(targetname == 'quantity_rejected'){
            this.updateRecord.Quantity_Rejected__c = targetvalue;
        }else if(targetname == 'remarks'){
            this.updateRecord.Remarks__c = targetvalue;
        }
        else if(targetname == 'status' ){
            this.updateRecord.Status__c = targetvalue;
        }else if(targetname == 'supply_chain' ){
            this.updateRecord.Supply_Chain__c = targetvalue;
        }else if(targetname == 'location__c'){
            let selectedLocation = this.locationvaluecode.find(loc => loc.label === event.target.value);   
            if (selectedLocation) {
                this.updateRecord.location__c = targetvalue;
                this.updateRecord.location_id__c = selectedLocation.value;
            }
        }else if(targetname == 'partremove'){
            if(event.target.checked == true){
                this.isLocationRequired = true;
            }else{
                this.isLocationRequired = false;
                this.updateRecord.location__c = undefined;
                this.updateRecord.location_id__c = undefined;
            }
                this.updateRecord.partremove = event.target.checked;
        }
    }
    updaterejecttoserver(){
        this.updateRecord.LastModifiedEmployeeId = this.employeeId;
        const allValid = [...this.template.querySelectorAll('.partshortagevalidationreject')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
    if (allValid && this.updateRecord.Quantity_Rejected__c != undefined) {
        updateReject({recid:this.updateRecord.Id,remarks :this.updateRecord.Remarks__c,quantity:this.updateRecord.Quantity_Rejected__c,empId:this.employeeId,status:this.updateRecord.Status__c,supplychain:this.updateRecord.Supply_Chain__c,location:this.updateRecord.location__c,partremove:this.updateRecord.partremove,location_id:this.updateRecord.location_id__c})
        .then(data=>{
            this.showmessage('Updated Sucessfully.','Reject Record updated successfully.','success');
            this.closeModal();
           this.showSpinner = true;
            return refreshApex(this.refreshRejectData);
        }).catch(error => {
            this.error = error;
            this.showmessage('Sorry we could not complete the operation.','Something unexpected occured. Please try again or contact your Administrator.','error');
        });
    }else{
        this.showmessage('Please fill all required fields.','Please fill required and update all blank form entries.','warning');
    }
    }
   async getFilesfromserver(event){
    this.isImageLoading = true;
                var requestbody={
                     "Id" : null,
                     "sfid":this.updateRecord.Id,
                }
           await getRejectImageFiles({req:requestbody})
            .then(data => {
                if(data.isError){
                    const alertmessage = new ShowToastEvent({
                    title : 'Failed to fetch the Attachments.',
                    message : 'Something unexpected occured. Please contact your Administrator',
                    variant : 'error'
                });
                this.dispatchEvent(alertmessage);
                this.isImageLoading = false;
                this.isrejectpresent = false;
             }
            else{
                var attachments = JSON.parse(data.responsebody).data.RejectAttachment;
                this.attachmentsize = attachments.length;
                var attachmentlist = [];
                for(var i in attachments){
                    var updateBy = attachments[i].updatedby_id.first_name +' '+ attachments[i].updatedby_id.last_name;
                    var datetime = attachments[i].created_date;
                    var attachmentmodded = {
                        "Id" : attachments[i].ecard_reject_log_attachment_id,
                        "url" : attachments[i].s3_image_uri,
                         "name" : '',
                         "Updatedbyandtimestamp":updateBy +', '+ getmoddeddate(datetime)
                    };
                    attachmentlist.push(attachmentmodded);
                }
                this.rejectimagelist = attachmentlist;
                this.isImageLoading = false;
                this.isrejectpresent = true;
            }
    
            }).catch(error => {
            this.error = error;
            const alertmessage = new ShowToastEvent({
                title : 'Failed to fetch the Attachments.',
                message : 'Something unexpected occured. Please contact your Administrator',
                variant : 'error'
            });
            this.dispatchEvent(alertmessage);
            this.isImageLoading = false;
            this.isrejectpresent = false;
        });
    }
@track departmentIdMap = [];
    setdepartmentidmap() {
        getDepartmentdata({ authdata: '' })
          .then(result => {
            for (var dept in result.departmentPickList) {
              var deprtmentopt = result.departmentPickList[dept];
              if (deprtmentopt.value != 'None') {
                this.departmentIdMap.push(deprtmentopt);
              }
            }
          })
          .catch(error => {
            const alertmessage = new ShowToastEvent({
              title: 'Department data fetch failed.',
              message: 'Something unexpected occured. Please contact your Administrator',
              variant: 'error'
            });
            this.dispatchEvent(alertmessage);
          });
      }
      loaddatatable(){
        return refreshApex(this.refreshRejectData);
      }
    
}