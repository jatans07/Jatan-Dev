import { LightningElement,wire, api } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class InfiniteLoopingLWC extends LightningElement {

    columns =[
    {label: 'DataID', fieldName: 'Id', type: 'text', editable: true},
    {label: 'Name', fieldName: 'Name', type: 'text',  editable: true}]
    @api accountData;
    offset = 0;
    maxRecord = 40;
    currentData
    loadMoreStatus
    enableInfiniteLoading
    error
    draftValues
    selectedRows

        handleSave(event){
            event.detail.draftValues.forEach(row => {
                console.log(row);
            });
        }
    ValidateInput(event){
        console.log(event.detail.draftValues)
        console.log(event.detail.draftValues.length)
        for(let i = 0; i < event.detail.draftValues.length; i++){
            console.log(event.detail.draftValues[i].Name)
            console.log(event.detail.draftValues[i].hasOwnProperty)
            console.log(event.detail.draftValues[i].DataID)
        }
        this.error = 'Your data is incorrect'
    }
    @wire(getAccounts, {limitSize:10,offset:0})
    fetchAccounts ({error, data}) {
        console.log('Callout JS');
        console.log(data);
        if (error) {
            console.log(error)
            // TODO: Error handling
        } else if (data) {
            this.accountData = data;
            this.enableInfiniteLoading = this.accountData.length > this.maxRecord ? false:true;
            console.log(JSON.stringify(this.accountData));
            // TODO: Data handling
        }
    }

    loadMoreData(event){
        console.log(event.target)
        if(event.target){
            console.log('Enabling Loading')
            event.target.isLoading = true;
        }
        this.loadMoreStatus = 'Loading';
        this.offset = this.offset + 10;
        console.log('accountData length '+this.accountData.length)
        getAccounts({limitSize:10,offset:this.accountData.length}).then(result => {
        this.accountData = this.accountData.concat(result)
        
        if(this.accountData.length > this.maxRecord){
            console.log('ENDDDDD')
                this.loadMoreStatus = 'Load All';
                this.enableInfiniteLoading = false;
        }
    })
    if(event.target){
    event.target.isLoading = false;
    }

};
}