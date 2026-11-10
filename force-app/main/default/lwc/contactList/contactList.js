import { LightningElement, wire } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Contact.FirstName';
import REVENUE_FIELD from '@salesforce/schema/Contact.LastName';
import INDUSTRY_FIELD from '@salesforce/schema/Contact.Email';
import getContacts from '@salesforce/apex/ContactController.getContacts'
import { reduceErrors } from 'c/ldsUtils';

const COLUMNS = [
    { label: 'First Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    { label: 'Last Last', fieldName: REVENUE_FIELD.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: INDUSTRY_FIELD.fieldApiName, type: 'text' }
];


export default class ContactList extends LightningElement {
    errors
    data
    COLUMNS =COLUMNS
    
    // @wire(getContacts)
    // contact({data,error}){
    //     if(error){
    //         this.errors = reduceErrors(error)
    //     }
    //     if(data){

    //     }
    // }
    // get errors() {
    //     return (this.contact.error) ?
    //         reduceErrors(this.contact.error) : [];
    // }
    getData(event){
     getContacts().then(contact =>{
        this.data = contact
        console.log(JSON.stringify(contact))
        console.log(JSON.stringify(contact.data))
     }).catch(error=>{
        this.errors = reduceErrors(error);
     })

    }
}