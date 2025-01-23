import { LightningElement, api, track } from 'lwc';
//import EcardLogin from "@salesforce/apex/userAuthentication.EcardLogin";

export default class AtpActionsForOpcks extends LightningElement {
  @api permitteduser;
  @api disableuser;
  @track isoklocal;
  @track qcuserlistlocal;
  @api name;

  test;
  @api uniqueid;

  @api
  get isok() {
    return this.isoklocal;
  }
  set isok(value) {
    this.isoklocal = value;
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

  //newly added by sathish
  // @track disableNullbutton = false;
  // connectedCallback(){
  //   this.getloggedinuser();
  // }
  // getloggedinuser(){
  //   EcardLogin()
  //   .then((result) => {
  //       this.loggedinuser=result.data.user;
  //       if(this.loggedinuser.approle_id==1){
  //           this.disableNullbutton=true;
  //       }else{
  //           this.disableNullbutton=false;
  //       }
  //   })
  //   .catch((error) => {
  //   });
  // }
//added end
  actiontriggered(event) {

  //   if(event.target.name=='ok'){
  //     this.isoklocal=true;
  // }else if (event.target.name == 'notok') {
  //      this.isoklocal = false;
  // }
  // else {
  //      this.isoklocal = null;
  // }
    let status;
    if (event.target.name == 'ok') {
      this.isoklocal = true;
      status = true;
    } else if (event.target.name == 'notok') {
      this.isoklocal = false;
      status = false;
    } else if (event.target.name == 'cancel'){
      this.isoklocal = null;
      status = null;
    }
    else {
      this.isoklocal = null;
      status = null;
    }

    const statuschange = new CustomEvent(
      "statuschange",
      {
          detail : {
              "uniqueid":this.uniqueid,
              "status":this.isoklocal
          } 
      }
  );
    this.dispatchEvent(statuschange);
  }

  get okButtonVariant() {
    return this.isoklocal === true ? 'success' : 'neutral';
  }

  get notOkButtonVariant() {
    return this.isoklocal === false ? 'destructive' : 'neutral';
  }

  get cancelButton(){
    //return this.isoklocal == false && this.disableNullbutton == true || this.isoklocal == true && this.disableNullbutton == true;
    return this.isoklocal == false || this.isoklocal == true;
  }
}