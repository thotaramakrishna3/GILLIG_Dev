import { LightningElement, api, track } from 'lwc';

export default class AtpActionsForOpcks extends LightningElement {
  @api permitteduser;
  @api disableuser;
  @track isoklocal;
  @track qcuserlistlocal;
  @api name;
  @track disableuserChanged = false;
  @track disableuserok = false;
  @track disableusernotok = false;
  @track disableusernotrequired = false;
  @track notrequired;
  @track valuerequiredlocal;
  @track opcheckvaluelocal;
  connectedCallback() {
    if(this.disabledlocal == false){
      this.disableuserok = true;
      this.disableusernotok = true;
      this.disableusernotrequired = false;
    }else if(this.isok == true || this.isok == false){
      this.disableuserok = this.isok === true ? false : true;
        this.disableusernotok = this.isok === false ? false : true;
        this.disableusernotrequired = true;
    }
    if(this.disableuser == true){
    this.disableuserok = this.disableuser;
    this.disableusernotok = this.disableuser;
    this.disableusernotrequired = this.disableuser;
    }
    if(this.disabledlocal == false && this.isok != null){
      this.isoklocal = null;
      }
  }

  test;
  @api uniqueid;

  @api
  get isok() {
    return this.isoklocal;
  }
  set isok(value) {
    this.isoklocal = value;
    this.resetButtons(this.isoklocal);
  }

  @api
  get qcuserlist() {
    return this.qcuserlistlocal;
  }
  set qcuserlist(value) {
    this.qcuserlistlocal = value;
  }

  get isqcselected() {
    this.test=JSON.stringify(this.qcuserlistlocal);
    return this.qcuserlistlocal.length === 0;
  }

  @track disabledlocal;
  @api
  get disabled() {
    return !this.disabledlocal;
  }
  set disabled(value) {
    this.disabledlocal = value;
  }
  @api
  get valuerequired() {
    return this.valuerequiredlocal;
  }
  set valuerequired(value) {
    this.valuerequiredlocal = value;
  }
  @api
  get opcheckvalue() {
    return this.opcheckvaluelocal;
  }
  set opcheckvalue(value) {
    this.opcheckvaluelocal = value;
  }
//added end
  actiontriggered(event) {
    let status;
    if (event.target.name == 'ok') {
      this.isoklocal = true;
      status = true;
      this.notrequired = true;
      this.disableuserok = false;
      this.disableusernotok = true;
      this.disableusernotrequired = true;
    } else if (event.target.name == 'notok') {
      this.isoklocal = false;
      status = false;
      this.notrequired = true; 
      this.disableuserok = true;
      this.disableusernotok = false;
      this.disableusernotrequired = true;
    }else if (event.target.name == 'notrequired') {
      this.notrequired = false;
      this.isoklocal = null;
      status = null;  
      this.disableuserok = true;
      this.disableusernotok = true;
      this.disableusernotrequired = false;
    } else if (event.target.name == 'cancel'){
      this.isoklocal = null;
      this.notrequired = true;
      status = null;
      this.disableuserok = false;
      this.disableusernotok = false;
      this.disableusernotrequired = false;
    }
    else {
      this.isoklocal = null;
      status = null;
      this.notrequired = true;
    }

    const statuschange = new CustomEvent(
      "statuschange",
      {
          detail : {
              "uniqueid":this.uniqueid,
              "status":this.isoklocal,
              "is_required":this.notrequired
          } 
      }
  );
    this.dispatchEvent(statuschange);
  }

  get okButtonVariant() {
    if(this.isoklocal == true){
      this.disableuserok = false;
      this.disableusernotok = true;
      this.disableusernotrequired = true;
      return 'success';
    }else{
      return 'neutral';
    }
  }

  get notOkButtonVariant() {
    if(this.isoklocal == false){
      this.disableuserok = true;
      this.disableusernotok = false;
      this.disableusernotrequired = true;
      return 'destructive';
    }else{
      return 'neutral';
    }
  }
  get notrequiredButtonVariant() {
    if(this.disabledlocal == false){
      this.disableuserok = true;
      this.disableusernotok = true;
      this.disableusernotrequired = false;
      return 'brand';
    }else{
      return 'neutral';
    }
  }
  get cancelButton(){
    return this.isoklocal == false || this.isoklocal == true || this.disabledlocal == false;
  }
  resetButtons(value){
    if(value == null && this.disabledlocal == true && this.valuerequiredlocal == true && (this.opcheckvaluelocal == null || this.opcheckvaluelocal == "")){
      this.disableuserok = false;
      this.disableusernotok = false;
      this.disableusernotrequired = false;     

    }
  }
}