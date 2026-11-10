import { LightningElement, api } from 'lwc';

export default class Button extends LightningElement {

    @api label;
    @api icon;
    handleButton(event) {
        const factor = event.target.dataset.factor;

        console.log('From Bubble comp ' +factor)
      this.dispatchEvent(new CustomEvent('buttonclick',{
         bubbles: true
      }));
    }
}