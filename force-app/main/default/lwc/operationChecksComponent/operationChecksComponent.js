import { LightningElement, api, track } from 'lwc';
import getdepartmentopcheckDetails from "@salesforce/apex/ecardOperationsController.getdepartmentopcheckDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pubsub from 'c/pubsub';
import updateopchecks from "@salesforce/apex/ecardOperationsController.updateopchecks";

export default class OpertaionChecksComponent extends LightningElement {
  @api busname;
  @api buschasisnumber;
  @api operation;
  @api ecardid;
  @api departmentIdMap;
  @api permissionset;
  @api isverified;
  @api departmentoptions;

  @track departmentId;
  @track departmentName;
  @track showSpinner = false;
  @track opckdetails = [];
  @track alldepts = false;
  @track filterlocal;
  @track check = true;
  @track firsttime = true;
  @track handlefirst = true;
  @track source = undefined;
  @track selecteddepartmentIdlocal;
  @track departmentlocal;
  @track filterlabellocal = undefined;

  @api
  get filter() {
    return this.filterlocal;
  }
  set filter(value) {
    this.filterlocal = value;
    if (this.filterlocal != undefined) {

      if (this.filter == 'approve') {
        this.filterlabellocal = 'OK ITEMS';
      }
      else if (this.filter == 'notapprove') {
        this.filterlabellocal = 'NOT OK ITEMS';
      }
      else if (this.filter == 'open') {
        this.filterlabellocal = 'OPEN ITEMS';
      }
      else if (this.filter == 'notrequired') {
        this.filterlabellocal = 'NOT REQUIRED ITEMS';
      }
      console.log('filter is>>>'+this.filter);

      this.getopcheckdeatils();
    }
  }
  get isopckpresent() {
    return true;
  }
  @api
  get selecteddepartmentId() {
    return this.selecteddepartmentIdlocal;
  }
  set selecteddepartmentId(value) {
    this.selecteddepartmentIdlocal = value;
    this.getopcheckdeatils();
  }
  @api
  get department() {
    return this.departmentlocal;
  }
  set department(value) {
    this.departmentlocal = value;
  }

  //To check if user have new discrepancy add access or prod user
  get addrepetitionbtn() {
    return this.permissionset.dept_discrepancy_new.write;
  }

  get disablerequired() {
    return !this.permissionset.operation_check.write;
  }
  get disableuserinput(){
    return !this.permissionset.operation_check.write;
  }

  get filterapplied() {
    return this.filterlocal != undefined;
  }
  // When clearing the Bus Overview filter making filter as undefined.
  clearfilter(event) {
    this.filterlocal = undefined;
    this.filterlabellocal = undefined;
    pubsub.fire('applyfilters', undefined);
    this.getopcheckdeatils();
  }
  updateopckitem(event) {
    this.selectedopcheckid = event.target.title;
    for (var i in this.opckdetails) {
      for (var j in this.opckdetails[i].op_check)
        if (this.opckdetails[i].op_check[j].operation_check_id == this.selectedopcheckid) {
          this.selectedopchek = this.opckdetails[i].op_check[j];
          this.selectedopchek.op_check_value = event.target.value;
        }
    }
    this.uploadopchecktoserver(this.selectedopchek);
  }


  @track tmpopckdetails = [];
  @track defaultjobType = ["Standard Job", "Customer Job"];
  async getopcheckdeatils() {
    // to get Operations Check details from server	
    console.log('Inside getopcheckdeatils method');
    this.showSpinner = true;
    var departentid = this.selecteddepartmentId;
    this.alldepts = false;
    if (departentid == 0) {
      departentid = null;
      this.alldepts = true;
    }
    var finaljobparam = this.finalJobTypeList;
    var defaultjobTypes = this.defaultjobType.map(str => encodeURIComponent(str));
    var ecarddepartmentid = {
      ecard_id: this.ecardid,
      department_id: departentid,
      job_type: this.jobtypemodifed ? finaljobparam : defaultjobTypes
    };
    console.log('ID is>>>'+JSON.stringify(ecarddepartmentid));

    await getdepartmentopcheckDetails({ ecarddepartmentid: JSON.stringify(ecarddepartmentid) })
      .then(data => {
        if (data.isError) {
          const alertmessage = new ShowToastEvent({
            title: 'Sorry we could not fetch Operations Check details.',
            message: 'Something unexpected occured. Please contact your Administrator',
            variant: 'error'
          });
          this.dispatchEvent(alertmessage);
        }
        else {
          var deptopchks = JSON.parse(data.responsebody).data;
          if (departentid == null) {
            this.tmpopckdetails = deptopchks.departments;
          }
          else {
            var modifiedopcklist = [];
            var opchecks = deptopchks.op_check;
            var modifiedopckdetails = {
              department_id: departentid,
              department_name: this.department,
              op_check: opchecks
            }
            modifiedopcklist.push(modifiedopckdetails);
            this.tmpopckdetails = modifiedopcklist;

          }

          if (this.filter != undefined) {
            var status;
            var is_required;
            if (this.filter == 'approve') {
              status = true;
            }
            else if (this.filter == 'notapprove') {
              status = false;
            }
            else if (this.filter == 'open') {
              status = null;
            }
            else if (this.filter == 'notrequired') {
              is_required = false;
            }
            this.opckdetails = this.filterrecords(status, this.tmpopckdetails, is_required);
            console.log('opckdetails:::' , Json.stringify(opckdetails));
            if (this.opckdetails != 0) {
              this.opckdetails.forEach(dep => {
                dep.op_check.forEach(opck => {
                  if (opck.verifiedby_id != null && opck.verifiedby_id.first_name != null && opck.verifiedby_id.last_name != null) {
                    const firstName = opck.verifiedby_id.first_name;
                    const lastName = opck.verifiedby_id.last_name;
                    const initials = `${firstName.charAt(0).toUpperCase()}${lastName.charAt(0).toUpperCase()}`;
                    opck.initials = initials;
                  }
                }
                );
              });
            }

            // newky added

            this.opckdetails.forEach(dep => {
              dep.op_check.forEach(opck => {
                if (opck.job_type != null && opck.job_type == "Standard Job" && !dep.department_name.includes('100')) {
                  const stanjob = true;
                  opck.stanjob = stanjob;
                } else if (opck.job_type != null && opck.job_type == "Customer Job" && !dep.department_name.includes('100')) {
                  const custjob = true;
                  opck.custjob = custjob;
                } else if (opck.job_type != null && opck.job_type == "QA Check" && !dep.department_name.includes('100')) {
                  const qacheckjob = true;
                  opck.qacheckjob = qacheckjob;
                }
                else if(opck.job_type != null && dep.department_name.includes('100')){
                  const ciJobs = true;
                  opck.ciJobs = ciJobs;               
                }

              }
              );
            });

            // end
          }
          else {
            console.log('else::');
            this.opckdetails = this.tmpopckdetails;
            if (this.opckdetails != 0) {
              this.opckdetails.forEach(dept => {
                dept.op_check.forEach(opck => {
                  if (opck.verifiedby_id != null && opck.verifiedby_id.first_name != null && opck.verifiedby_id.last_name != null) {
                    const firstName = opck.verifiedby_id.first_name;
                    const lastName = opck.verifiedby_id.last_name;
                    const initials = `${firstName.charAt(0).toUpperCase()}${lastName.charAt(0).toUpperCase()}`;
                    opck.initials = initials;
                  }
                }
                );
              });
            }
            // newly added
            this.opckdetails.forEach(dep => {
              dep.op_check.forEach(opck => {
                if (opck.job_type != null && opck.job_type == "Standard Job" && !dep.department_name.includes('100')) {
                  const stanjob = true;
                  opck.stanjob = stanjob;
                } else if (opck.job_type != null && opck.job_type == "Customer Job" && !dep.department_name.includes('100')) {
                  const custjob = true;
                  opck.custjob = custjob;
                } else if (opck.job_type != null && opck.job_type == "QA Check" && !dep.department_name.includes('100')) {
                  const qacheckjob = true;
                  opck.qacheckjob = qacheckjob;
                }
                else if(opck.job_type != null && dep.department_name.includes('100')){
                  const ciJobs = true;
                  opck.ciJobs = ciJobs;               
                }

               }
              );
            });
            // end
          }
          this.processInstructionsWithIcons();
          this.opckdetails = this.processedDetails;
          this.showSpinner = false;
        }

      }).catch(error => {
        this.error = error;
        const alertmessage = new ShowToastEvent({
          title: 'Sorry we could not fetch Operations Check details.',
          message: 'Something unexpected occured. Please contact your Administrator',
          variant: 'error'
        });
        this.dispatchEvent(alertmessage);

      });
  }
  @track processedDetails = [];
  processInstructionsWithIcons() {
    if (!this.opckdetails || !Array.isArray(this.opckdetails)) {
      console.error('opckdetails is not defined or is not an array');
      return [];
    }
  
    this.processedDetails = this.opckdetails.map((dept) => {
      const processedOpChecks = dept.op_check.map((opck) => {
        const processedInstructions = (opck.workinstructions || []).map((instruction) => {
          // Check if URL exists, otherwise leave the record as it is
          if (instruction.work_instruction_url) {
            return {
              ...instruction,
              icon: this.getIconByExtension(instruction.work_instruction_url),
            };
          } else {
            return instruction;
          }
        });
  
        return { ...opck, workinstructions: processedInstructions };
      });
  
      return { ...dept, op_check: processedOpChecks };
    });
  }
  getIconByExtension(fileUrl) {
    if (!fileUrl) return 'doctype:unknown';

    const extension = fileUrl.split('.').pop().toLowerCase().split('?').shift(); // Extract file extension

    const extensionToIconMap = {
      pdf: 'doctype:pdf',
      doc: 'doctype:word',
      docx: 'doctype:word',
      txt: 'doctype:txt',
      xls: 'doctype:excel',
      xlsx: 'doctype:excel',
      ppt: 'doctype:ppt',
      pptx: 'doctype:ppt',
      jpg: 'doctype:image',
      jpeg: 'doctype:image',
      png: 'doctype:image',
      zip: 'doctype:zip',
      csv: 'doctype:csv',
      html: 'doctype:html',  
      json: 'doctype:json',  
      xml: 'doctype:xml',    
      mp3: 'doctype:audio',  
      mp4: 'doctype:video',  
      mov: 'doctype:video',  
      wav: 'doctype:audio',   
      rtf: 'doctype:txt',   
      psd: 'doctype:image',  
      ai: 'doctype:image',   
      ind: 'doctype:image',
    };

    return extensionToIconMap[extension] || 'doctype:link'; // Default to 'file' icon
  }
  @track selectedopchek = [];
  @track selectedopcheckid;
  existingrowstatuschange(event) {
    this.selectedopcheckid = event.target.name == 'applicable' ? event.target.dataset.id : event.detail.uniqueid;
    for (var i in this.opckdetails) {
      for (var j in this.opckdetails[i].op_check) {
        if (this.opckdetails[i].op_check[j].operation_check_id == this.selectedopcheckid) {
          this.selectedopchek = this.opckdetails[i].op_check[j];
          if (event.target.type != "checkbox") {
            this.selectedopchek.op_check_status = event.detail.status;
            this.selectedopchek.is_required = event.detail.is_required;
           }
        }
      }
    }

    if (this.selectedopchek.value_required &&
      (this.selectedopchek.op_check_value == null || this.selectedopchek.op_check_value == "") &&
      this.selectedopchek.op_check_status) {
      const alertmessage = new ShowToastEvent({
        title: 'Value Required.',
        message: 'Value required to update status, Please enter a value',
        variant: 'warning'
      });
      this.dispatchEvent(alertmessage);
      this.getopcheckdeatils(this.ecardid, this.departmentId, this.filterlocal);

    } else {
      this.uploadopchecktoserver(this.selectedopchek);
    }
  }

  uploadopchecktoserver(opck) {
    var opcheckrecord = {
      "ecard_id": this.ecardid,
      "buildstation_id": opck.buildstation_id,
      "operation_check_id": opck.operation_check_id,
      "op_check_value": opck.op_check_value,
      "op_check_status": opck.op_check_status,
      "is_required": opck.is_required
    };
    this.showSpinner = true;
    updateopchecks({ requestbody: JSON.stringify(opcheckrecord) })
      .then(data => {
        if (data.isError) {
          const alertmessage = new ShowToastEvent({
            title: 'Sorry we could not complete the operation.',
            message: 'Something unexpected occured. Please contact your Administrator',
            variant: 'error'
          });
          this.dispatchEvent(alertmessage);
          this.showSpinner = false;
        }
        else {
          const alertmessage = new ShowToastEvent({
            title: 'Successfully updated',
            message: 'JOB successfully updated.',
            variant: 'success'
          });
          this.getopcheckdeatils();
          this.dispatchEvent(alertmessage);
          this.showSpinner = false;
          this.refreshtheoperationlist();
          this.showpicvalmodal = false;
        }

      }).catch(error => {
        this.error = error;
      });
  }
  filterrecords(opckstatus, opcklist, opcknotreq) {
    var moddeptopcklist = [];
    for (var i in opcklist) {
      var modopcklist = [];
      for (var j in opcklist[i].op_check) {
        var opck = opcklist[i].op_check[j];
        if (opcknotreq != false) {
          if (opck.op_check_status == opckstatus && opck.is_required) {
            modopcklist.push(opck);
          }
        }
        if (opcknotreq == false) {
          if (opck.is_required == opcknotreq) {
            modopcklist.push(opck);
          }
        }
      }
      if (modopcklist.length != 0) {
        var modifiedopckdetails = {
          department_code: opcklist[i].department_code,
          department_id: opcklist[i].department_id,
          department_name: opcklist[i].department_name,
          op_check: modopcklist
        }
        moddeptopcklist.push(modifiedopckdetails);
      }
    }
    return moddeptopcklist;
  }

  @track jobtypelist = [
    { label: "Standard Job", value: "Standard Job" },
    { label: "Customer Job", value: "Customer Job" },
    { label: "QA Check", value: "QA Check" },
  ];

  @track allJobTypeValues = ["Standard and Customer Job"];
  @track allSelectedJobType = [];
  @track finalJobTypeList = [];
  @track listOfJobTypes;
  @track latestJobTypeValue;
  @track jobtypemodifed = false;
  handleJobTypeChange(event) {
    this.jobtypemodifed = true;
    this.allSelectedJobType = event.target.value;
    if (this.allSelectedJobType === "Standard and Customer Job") {
      this.allJobTypeValues = ["Standard and Customer Job"];
     
    } else {
     

      if (!this.allJobTypeValues.includes(this.allSelectedJobType)) {
        this.allJobTypeValues.push(this.allSelectedJobType);
      }
      const allJobTypeIndex = this.allJobTypeValues.indexOf("Standard and Customer Job");
      if (allJobTypeIndex !== -1) {
        this.allJobTypeValues.splice(allJobTypeIndex, 1);
      }
    }
    this.allSelectedJobType = JSON.stringify(this.allJobTypeValues);
    this.listOfJobTypes = this.allJobTypeValues;
    this.finalJobTypeList = this.listOfJobTypes.map(str => encodeURIComponent(str));
    this.latestJobTypeValue = this.allJobTypeValues[this.allJobTypeValues.length - 1];
    this.getJobTitle();
    console.log('Called get opck 4th');
    this.getopcheckdeatils();

  }

  handleJobTypeRemove(event) {
    const valueRemoved = event.target.name;
    this.allJobTypeValues.splice(this.allJobTypeValues.indexOf(valueRemoved), 1);
    if (this.allJobTypeValues.length === 0) {
      this.allJobTypeValues = ["Standard and Customer Job"];
    
      this.jobtypemodifed = false;
    }
    this.getJobTitle();
    this.latestJobTypeValue = this.allJobTypeValues[this.allJobTypeValues.length - 1];
    this.finalJobTypeList = this.allJobTypeValues.map(str => encodeURIComponent(str));
    console.log('Called get opck 5th');
    this.getopcheckdeatils();
  }

  @track jobTitle = 'STANDARD AND CUSTOMER JOBS';
  getJobTitle() {
    const selectedTypes = this.allJobTypeValues;
    if (selectedTypes.length === 2 && selectedTypes.includes("Standard Job") && selectedTypes.includes("Customer Job")) {
      this.jobTitle = 'STANDARD AND CUSTOMER JOBS';
    } else if (selectedTypes.length === 2 && selectedTypes.includes("Standard Job") && selectedTypes.includes("QA Check")) {
      this.jobTitle = 'STANDARD AND QA CHECK JOBS';
    } else if (selectedTypes.length === 2 && selectedTypes.includes("Customer Job") && selectedTypes.includes("QA Check")) {
      this.jobTitle = 'CUSTOMER AND QA CHECK JOBS';
    } else if (selectedTypes.length === 3) {
      this.jobTitle = 'STANDARD, CUSTOMER AND QA CHECK JOBS';
    } else if (selectedTypes.length === 1 && selectedTypes.includes("Standard Job")) {
      this.jobTitle = 'STANDARD JOBS';
    } else if (selectedTypes.length === 1 && selectedTypes.includes("Customer Job")) {
      this.jobTitle = 'CUSTOMER JOBS';
    } else if (selectedTypes.length === 1 && selectedTypes.includes("QA Check")) {
      this.jobTitle = 'QA CHECK';
    } else if (selectedTypes.length === 1 && selectedTypes.includes("Standard and Customer Job")) {
      this.jobTitle = 'STANDARD AND CUSTOMER JOBS';
    }
  }
  // @track jobTitle = 'STANDARD AND CUSTOMER JOBS';

  // getJobTitle() {
  //   const selectedTypes = this.allJobTypeValues;
  
  //   if (selectedTypes.length === 4 && selectedTypes.includes("Standard Job") && selectedTypes.includes("Customer Job") && selectedTypes.includes("QA Check") && selectedTypes.includes("Customer Inspector")) {
  //     this.jobTitle = 'STANDARD, CUSTOMER, QA CHECK AND CUSTOMER INSPECTOR JOBS';
  //   } else if (selectedTypes.length === 3 && selectedTypes.includes("Standard Job") && selectedTypes.includes("Customer Job") && selectedTypes.includes("QA Check")) {
  //     this.jobTitle = 'STANDARD, CUSTOMER AND QA CHECK JOBS';
  //   } else if (selectedTypes.length === 3 && selectedTypes.includes("Standard Job") && selectedTypes.includes("Customer Job") && selectedTypes.includes("Customer Inspector")) {
  //     this.jobTitle = 'STANDARD, CUSTOMER AND CUSTOMER INSPECTOR JOBS';
  //   } else if (selectedTypes.length === 3 && selectedTypes.includes("Customer Job") && selectedTypes.includes("QA Check") && selectedTypes.includes("Customer Inspector")) {
  //     this.jobTitle = 'CUSTOMER, QA CHECK AND CUSTOMER INSPECTOR JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("Standard Job") &&
  //     selectedTypes.includes("Customer Job")
  //   ) {
  //     this.jobTitle = 'STANDARD AND CUSTOMER JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("Standard Job") &&
  //     selectedTypes.includes("QA Check")
  //   ) {
  //     this.jobTitle = 'STANDARD AND QA CHECK JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("Customer Job") &&
  //     selectedTypes.includes("QA Check")
  //   ) {
  //     this.jobTitle = 'CUSTOMER AND QA CHECK JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("Customer Job") &&
  //     selectedTypes.includes("Customer Inspector")
  //   ) {
  //     this.jobTitle = 'CUSTOMER AND CUSTOMER INSPECTOR JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("QA Check") &&
  //     selectedTypes.includes("Customer Inspector")
  //   ) {
  //     this.jobTitle = 'QA CHECK AND CUSTOMER INSPECTOR JOBS';
  //   } else if (
  //     selectedTypes.length === 2 &&
  //     selectedTypes.includes("Standard Job") &&
  //     selectedTypes.includes("Customer Inspector")
  //   ) {
  //     this.jobTitle = 'STANDARD AND CUSTOMER INSPECTOR JOBS';
  //   } else if (
  //     selectedTypes.length === 1 &&
  //     selectedTypes.includes("Standard Job")
  //   ) {
  //     this.jobTitle = 'STANDARD JOBS';
  //   } else if (
  //     selectedTypes.length === 1 &&
  //     selectedTypes.includes("Customer Job")
  //   ) {
  //     this.jobTitle = 'CUSTOMER JOBS';
  //   } else if (
  //     selectedTypes.length === 1 &&
  //     selectedTypes.includes("QA Check")
  //   ) {
  //     this.jobTitle = 'QA CHECK JOBS';
  //   } else if (
  //     selectedTypes.length === 1 &&
  //     selectedTypes.includes("Customer Inspector")
  //   ) {
  //     this.jobTitle = 'CUSTOMER INSPECTOR JOBS';
  //   } else if (
  //     selectedTypes.length === 1 &&
  //     selectedTypes.includes("Standard and Customer Job")
  //   ) {
  //     this.jobTitle = 'STANDARD AND CUSTOMER JOBS';
  //   }
  // }  

}