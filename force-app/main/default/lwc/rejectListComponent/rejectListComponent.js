import { LightningElement,api,track,wire } from 'lwc';
import getRejectList from '@salesforce/apex/GetRejectList.getRejectData';
import getRejectImageFiles from "@salesforce/apex/ecardOperationsController.getRejectImageFiles";
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDetails from '@salesforce/apex/GetRejectList.getUpdateRecord';
import updateReject from '@salesforce/apex/GetRejectList.updateReject';
import {getmoddeddate,permissions}  from 'c/userPermissionsComponent';
import getallUsers from "@salesforce/apex/UserListingController.getallUsers";
import getPermissions from "@salesforce/apex/userAuthentication.getPermissions";
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
export default class RejectListComponent extends LightningElement {
@api ecardid;
@api departmentIdMap;

@api busname;
@api buschasisnumber;


@api operation; 
@track filterlocal;
@track filterlabelfordisplay;
@track filterapplied = false;
@track showSpinner = true;
@track selecteddepartmentIdlocal;
@track departmentlocal;
@api isload;
@track loaded = this.isload;
@api
get filter(){

  return this.filterlocal;
}
set filter(value){
  this.filterlocal = value;

  if(this.filterlocal != undefined){
      this.filterapplied = false;
      if(this.isload == true){
      this.loadRejectList();
      } 
  }
  
  
}
@api
get selecteddepartmentId() {
return this.selecteddepartmentIdlocal;
}
set selecteddepartmentId(value) {
this.selecteddepartmentIdlocal = value;

}
@api
get department() {
  return this.departmentlocal;
}
set department(value) {
  this.departmentlocal = value;
  if(this.isload==true){


  this.loadRejectList();
  }
}

@track rejectItems = [];
@track error;
connectedCallback() {
    this.getCode();
    this.getLocationCode();
if(this.isload == true){
    this.getuserdata();
}
this.getPermissionsfromserver();
}
loadRejectList() {
getRejectList({ ecardId: this.ecardid, dept: this.department })
    .then(data => {      
            if (data) {
                // Create a copy of the data with added UserName property
                this.rejectItems = data.map(item => {
                    let userId = item.Rejected_By_Employee_Id;
                    let userName = this.userdata.get(userId) || 'Unknown'; // Provide a fallback value if userName is not found
        
                    // Create a new object with all properties of item and add UserName
                    return { ...item, UserName: userName };
                });
        
                // Copy filteredrejects to nosearchdata
                this.showSpinner = false;
            } else if (results.error) {
                // Proper error handling
                console.error('Error loading data:', results.error);
            }
    })
    .catch(error => {
        this.error = error;
        this.rejectItems = undefined;
        this.showSpinner = false;
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

  showmessage(title, message, variant){
    const alertmessage = new ShowToastEvent({
        title : title,
        message : message,
        variant : variant
    });
    this.dispatchEvent(alertmessage);
}
@track userdata = new Map();
@track isImageLoading;
@track IsupdateDisable = true;
  @track attachmentsize=0;
  @track isrejectpresent;
  @track rejectedby = USER_ID;
  @track employeeId;
  @track ShowRejectModal = false;
    @track refreshRejectData;
    @track showtable = false;
    userId = USER_ID;
    @track fullName;
    async getuserdata(){
        this.showSpinner = true;
         await getallUsers()
        .then(data => {
            var dataa = JSON.parse(data.responsebody).data.user
            dataa.forEach(user => {
                this.userdata.set(user.employee_number,user.first_name+' '+user.last_name);
            });
            this.loadRejectList();
        })
        .catch(error => {
            console.error('Error retrieving user data: ', error);
        });
    }
    
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    user({ error, data }) {
        if (error) {
            console.error('Error retrieving user data: ', error);
        } else if (data) {
            this.fullName = `${data.fields.FirstName.value} ${data.fields.LastName.value}`;
            this.employeeId = data.fields.EmployeeNumber.value;
        }
    }

  closeModal(){
    this.ShowRejectModal = false;
    this.viewdetails = false;
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
          this.loadRejectList();
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
        console.log('data is>>>'+error);
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
}