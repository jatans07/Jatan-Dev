import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import COUNT_UPDATED_CHANNEL from '@salesforce/messageChannel/Count_Updated__c';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import OWNER_NAME_FIELD from "@salesforce/schema/Account.Owner.Name";
import PHONE_FIELD from "@salesforce/schema/Account.Phone";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";
export default class Counts extends LightningElement {
  subscription = null;
  priorCount = 0;
  counter = 0;
  boatId 
  @wire(getRecord, {
    recordId: "$boatId",
    fields: [NAME_FIELD, INDUSTRY_FIELD],
    optionalFields: [PHONE_FIELD, OWNER_NAME_FIELD],
  })
  account;

  get name() {
    console.log('get Value '+getFieldValue(this.account.data, NAME_FIELD))
    return getFieldValue(this.account.data, NAME_FIELD);
  }
  
  @wire(MessageContext)
  messageContext;
  subscribeToMessageChannel() {
    console.log('Inside subscribe method')
    if(!this.subscription)
    {
    console.log('Inside subscribtion')

    this.subscription = subscribe(
      this.messageContext,
      COUNT_UPDATED_CHANNEL,
      (message) => this.handleMessage(message)
    );
  }
  }
  handleMessage(message) {
    console.log('Inside handleMessage method')
    this.boatId ='0015i000018pShuAAE'
    console.log(' this.boatId '+ this.boatId)

    this.priorCount = this.counter;
    if(message.operator === 'add') {
      this.counter += message.constant;
    }else if(message.operator === 'subtract') {
      this.counter -= message.constant;
    } else {
      this.counter *= message.constant;
    }
  }
  connectedCallback() {
    this.subscribeToMessageChannel();
  }
}