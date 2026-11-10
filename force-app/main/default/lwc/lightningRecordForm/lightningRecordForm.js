import { LightningElement,api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';

export default class LightningRecordForm extends LightningElement {

    // object =ACCOUNT_OBJECT
    // fields = [NAME_FIELD,REVENUE_FIELD,INDUSTRY_FIELD]
     @api recordId

    // handleSuccess(event){
    //     console.log('Event data '+ JSON.stringify(event.detail))
    //     const toastEvent = new ShowToastEvent({
    //         title: "Account created",
    //         message: "Record ID: " + event.detail.id + "\n Name: "+event.detail.fields.CreatedBy.displayValue,
    //         variant: "success"
    //     });
    //     this.dispatchEvent(toastEvent);
    // }

    @wire (getRecord,{recordId:'$recordId' ,fields:[ NAME_FIELD ]})
    account;

    get Name(){
        return getFieldValue(this.account.data, NAME_FIELD)
    }

}