import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDataLibraries from '@salesforce/apex/PS2RagStatus.getDataLibraries';
import getFileCounts from '@salesforce/apex/PS2RagStatus.getFileCounts';
import checkDMOs from '@salesforce/apex/PS2RagStatus.checkDMOs';
import COLORS from '@salesforce/resourceUrl/PS2RagStatusCSS';

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Size', fieldName: 'size', type: 'number' },
    {
        label: 'Count', fieldName: 'count', type: 'number', cellAttributes: {
            class: { fieldName: 'countClass' },
        },
        typeAttributes: { tooltip: 'test' }
    },
    {
        label: 'Index Count', fieldName: 'indexCount', type: 'number', cellAttributes: {
            class: { fieldName: 'indexClass' },
        }
    },
    {
        label: 'Chunk Count', fieldName: 'chunkCount', type: 'number', cellAttributes: {
            class: { fieldName: 'chunkClass' }
        }
    },
];

export default class Ps2RagStatus extends LightningElement {
    title = 'RAG Data Library Status';
    iconName = 'standard:choice';
    isCssLoaded = false;

    dLibOptions = [];
    dLibSelection = null;
    dFiles = [];

    isLoading = false;
    errors = null;

    columns = columns;

    connectedCallback() {
        checkDMOs()
            .then(result => {
                this.loadDataLibraries();
            })
            .catch(error => {
               console.log('ERROR!!!!');
               console.log(error);
               var err = JSON.parse(error.body.message);

               this.dispatchEvent(
                new ShowToastEvent({
                  title: "RAG DMO ERROR",
                  message: err.message,
                  variant: "error",
                  mode: "sticky"
                }));
            });
    }

    loadDataLibraries() {
        getDataLibraries()
            .then(result => {
                console.log('dataLib=' + result);

                this.dLibOptions = JSON.parse(result);
            });
    }

    handleLibChange(evt) {
        console.log('handleLibChange');
        this.dLibSelection = evt.detail.value;

        this.loadFiles();
    }

    loadFiles() {
        this.isLoading = true;
        getFileCounts({ dataLibraryId: this.dLibSelection })
            .then(result => {
                this.isLoading = false;



                this.dFiles = JSON.parse(result);

                this.dFiles.forEach(ele => {
                    if (ele.count == 0) {
                        ele.countClass = 'red-background';
                    }
                    else if (ele.count > 1) {
                        ele.countClass = 'yellow-background';
                    }

                    if (ele.indexCount == 0) {
                        ele.indexClass = 'red-background';
                    }

                    if (ele.chunkCount == 0) {
                        ele.chunkClass = 'red-background';
                    }

                    if (ele.indexCount < ele.count) {
                        ele.indexClass = 'red-background';
                    }

                    if (ele.indexCount != ele.chunkCount) {
                        ele.indexClass = 'red-background';
                    }

                    if (ele.chunkCount < ele.count) {
                        ele.chunkClass = 'red-background';
                    }
                });

                console.log('dFiles=' + JSON.stringify(this.dFiles));
            })
            .catch(error => {
                this.isLoading = false;
            });
    }

    handleRefresh(evt) {
        console.log('handleRefresh');

        if (this.dLibSelection != null) {
            this.loadFiles();
        }
    }

    renderedCallback() {
        if (this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(() => {
            console.log("Loaded Successfully");
        }).catch(error => {
            console.error("Error in loading the colors");
        })
    }
}