import { LightningElement } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import contactObject from '@salesforce/schema/Contact';
import FirstName from '@salesforce/schema/Contact.FirstName';
import LastName from '@salesforce/schema/Contact.LastName';
import Email from '@salesforce/schema/Contact.Email';

export default class ContactCreator extends LightningElement {

    objectAPI = contactObject
    fields = [FirstName,LastName,Email]

    handleSuccess(event){
        console.log(event.detail)
        this.dispatchEvent(new ShowToastEvent({
            title: "Record created!!",
            message: event.detail.id,
            variant: "success"
        }));
    }
}