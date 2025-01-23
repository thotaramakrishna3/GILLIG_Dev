import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getDepartmentChangeCodes from "@salesforce/apex/ecardOperationsController.getAllDepartmentChangeCodes";
import addnewDeptchangereasoncode from "@salesforce/apex/ecardOperationsController.addnewDeptchangereasoncode"; 
import updateReasoncode from "@salesforce/apex/ecardOperationsController.updateDeptchangereasoncode"; 
import updateDefectstatus from "@salesforce/apex/ecardOperationsController.updateDefectstatus"; 

const columns = [
    { label: 'Active', fieldName: 'is_active',sortable: true, type: 'boolean', },
    { label: 'Reason Code', fieldName: 'reason_code',sortable: true, type: 'text', },
    { label: 'Reason Title', fieldName: 'reason_name',sortable: true, type : 'text',},
    {
        label: "Created Date",
        fieldName: "created_date",
        type: "date",
        sortable: true,
        typeAttributes:{
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {label: 'Action', type: 'button', typeAttributes:
    { label: 'Update', title: 'Click to Edit', name: 'Update', iconName: 'utility:edit', class: 'btn_next'}},
    
];


export default class ListdeptChangeReasonCodeComponent extends LightningElement {
    @track columns = columns;
    @track showSpinner;
    @track record = {};
    @track rowOffset = 0;
    @track bShowModal = false;
    @track addmodal = false;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track reasonslist = [];
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track error;
    get tableHeight() {
      var height = window.innerHeight * 0.82 - 247.59;
      return `height: ${height}px;`;
    }

    newdefect;

    defecttypeoperations = [{'label':'Other Department', 'value':'department'}, {'label':'Paint Department', 'value':'paint'}];
    
    connectedCallback(){
        this.loaddata();
      }

    loaddata(){
      this.showSpinner = true;
      this.showTable = false;
      getDepartmentChangeCodes()
      .then((data) => {
         var allreasons = JSON.parse(data.responsebody).data.reasons;
         var modifieddefectdata = [];
         for(var i in allreasons){
            var defect = allreasons[i];
            modifieddefectdata.push(defect);
         }
         this.reasonslist = modifieddefectdata;
         this.showTable = true;
         this.showSpinner = false;
         this.error = undefined;
        
      })
      .catch((error) => {
        this.error = error;
        const alertmessage = new ShowToastEvent({
          title: "Defect Data fetch failed.",
          message:
            "Something unexpected occured. Please contact your Administrator",
          variant: "error"
        });
        this.dispatchEvent(alertmessage);
      });
    }
    
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
      

    // Used to sort the columns
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
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

    // Row Action event to show the details of the record
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.record = row;
        this.bShowModal = true; // display modal window
    }
 
    // to close modal window set 'bShowModal' tarck value as false
    closeModal() {
        this.bShowModal = false;
    }

    closeAddModal() {
        this.addmodal = false;
    }

    addnew(){
        this.newdefect = {
          "reason_code": undefined,
          "reason_name": undefined
        };
        this.addmodal = true;
    }

    tracknewdefectvalue(event){
      this.newdefect[event.target.name] = event.target.value;
    }

    adddefecttoserver(event){
        // Check Validations
  const allValid = [...this.template.querySelectorAll('.newdefectvalidation')]
  .reduce((validSoFar, inputCmp) => {
              inputCmp.reportValidity();
              return validSoFar && inputCmp.checkValidity();
  }, true);
  if (allValid) {
    addnewDeptchangereasoncode({ requestbody: JSON.stringify(this.newdefect) })
              .then((data) => {
                if (data.isError) {
                  if(data.errorMessage == 202){
                      const alertmessage = new ShowToastEvent({
                          title: "Sorry we could not complete the operation.",
                          //message: JSON.parse(data.responsebody).data.validation_message,
                          message: 'Data type mismatch for one of the field.' ,
                          variant: "warning"
                        });
                        this.dispatchEvent(alertmessage);
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title: "Sorry we could not complete the operation.",
                          message: 'Please contact the System Administrator.' ,
                          variant: "error"
                        });
                        this.dispatchEvent(alertmessage);
                  }
                } else {
                  const alertmessage = new ShowToastEvent({
                    title: " Success",
                    message: "Dept. change reason code added successfully.",
                    variant: "success"
                  });
                  this.dispatchEvent(alertmessage);
                  this.addmodal = false;
                  this.showSpinner = false;
                  this.loaddata();
                  
                }
              })
              .catch((error) => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                  title: "Sorry we could not complete the operation.",
                  message:
                    "Something unexpected occured. Please contact your Administrator",
                  variant: "error"
                });
                this.dispatchEvent(alertmessage);
                this.showSpinner = false;
              });

  }
  else{
      const alertmessage = new ShowToastEvent({
          title: "Please fill in all the required fields.",
          message:
            "Please fill in all the required fields.",
          variant: "warning"
        });
        this.dispatchEvent(alertmessage);
  }
  }
    updatechangesfordefect(event){
      if(event.target.name == 'is_active'){
        this.record[event.target.name] = event.target.checked;
      }
      else{
      this.record[event.target.name] = event.target.value;
      }
    }

    updatedefecttoserver(event){
      // Check Validations
  const allValid = [...this.template.querySelectorAll('.newdefectvalidation')]
  .reduce((validSoFar, inputCmp) => {
              inputCmp.reportValidity();
              return validSoFar && inputCmp.checkValidity();
  }, true);
  if (allValid) {
      var requestbody = {
          "dept_reason_code_id": this.record.dept_reason_code_id,
          "reason_code": this.record.reason_code,
          "reason_name": this.record.reason_name,
          "is_active": this.record.is_active
      };
      updateReasoncode({ requestbody: JSON.stringify(requestbody) })
              .then((data) => {
                if (data.isError) {
                  if(data.errorMessage == 202){
                      const alertmessage = new ShowToastEvent({
                          title: "Sorry we could not complete the operation.",
                          message: JSON.parse(data.responsebody).data.validation_message,
                          variant: "warning"
                        });
                        this.dispatchEvent(alertmessage);
                  }
                  else{
                      const alertmessage = new ShowToastEvent({
                          title: "Sorry we could not complete the operation.",
                          message: 'Please contact the System Administrator.' ,
                          variant: "error"
                        });
                        this.dispatchEvent(alertmessage);
                  }
                } else {
                  const alertmessage = new ShowToastEvent({
                    title: " Success",
                    message: "Defect successfully updated.",
                    variant: "success"
                  });
                  this.dispatchEvent(alertmessage);
                  this.bShowModal = false;
                  this.showSpinner = false;
                  this.loaddata();
                  
                }
              })
              .catch((error) => {
                this.error = error;
                const alertmessage = new ShowToastEvent({
                  title: "Sorry we could not complete the operation.",
                  message:
                    "Something unexpected occured. Please contact your Administrator",
                  variant: "error"
                });
                this.dispatchEvent(alertmessage);
                this.showSpinner = false;
              });

  }
  else{
      const alertmessage = new ShowToastEvent({
          title: "Please fill in all the required fields.",
          message:
            "Please fill in all the required fields.",
          variant: "warning"
        });
        this.dispatchEvent(alertmessage);
  }
    }

   
}