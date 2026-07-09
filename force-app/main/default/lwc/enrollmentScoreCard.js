import { LightningElement, api, wire } from 'lwc';
 
import getLatestEnrollmentScore
    from '@salesforce/apex/EnrollmentScoreController.getLatestEnrollmentScore';
 
export default class EnrollmentScoreCard extends LightningElement {
 
    @api recordId;
 
    score;
    recommendedAction;
    sourceSystem;
    scoredAt;
    priority;
 
    hasScore = false;
 
    error;
 
    @wire(getLatestEnrollmentScore, { contactId: '$recordId' })
    wiredScore({ error, data }) {
 
        if (data) {
 
            this.hasScore = data.hasScore;
 
            this.score = data.score;
            this.recommendedAction = data.recommendedAction;
            this.sourceSystem = data.sourceSystem;
            this.scoredAt = data.scoredAt;
            this.priority = data.priority;
 
            this.error = undefined;
 
        }
        else if (error) {
 
            this.error = error;
 
            this.hasScore = false;
 
        }
 
    }
 
    get badgeClass() {
 
        if (this.priority === 'Hot') {
 
            return 'badge hot';
 
        }
 
        if (this.priority === 'Warm') {
 
            return 'badge warm';
 
        }
 
        return 'badge cold';
 
    }
 
}