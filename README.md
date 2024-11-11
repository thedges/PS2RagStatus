# PS2RagStatus
THIS SOFTWARE IS COVERED BY [THIS DISCLAIMER](https://raw.githubusercontent.com/thedges/Disclaimer/master/disclaimer.txt).

Simple LWC to help debug RAG issues. The component will first determine if the core DMO objects (RagFileUDMO__dlm or AiGroundingFileRefCustom__dlm) were created and throw an error if so. If those core objects exist, it will present a list of Data Libraries that you can review the files that exists in the library, count of files, indexes and chunks. Color coding of the cells is provided to help easily find issues.


# Sample Images
![alt text](https://github.com/thedges/PS2RagStatus/blob/main/PS2RagStatus.jpg "Sample Photo")

![alt text](https://github.com/thedges/PS2RagStatus/blob/main/PS2RagStatus-2.jpg "Sample Photo")

# Errors
If the component detects any issues with the creation of the core DMO objects (RagFileUDMO__dlm or AiGroundingFileRefCustom__dlm), an error message like the following will be displayed:

![alt text](https://github.com/thedges/PS2RagStatus/blob/main/PS2RagStatus-Error.jpg "Error")

# Configuration Parameters

| Parameter  | Type | Definition |
| ------------- | ------------- |------------- |
| Card Title | Text | A name to be displayed at top of component |
| Icon Name | Text | The SLDS icon name to be displayed at top of component. Refer to [SLDS Icons](https://www.lightningdesignsystem.com/icons/) |

# Cell Color Coding

* Count > 1 - Yellow
* Count = 0 - Red
* Index Count or Chunk Count = 0 - Red
* Index Count < Count - Red
* Chunk count < Count - Red
* Index count != Chunk Count - Red


# Installation Instructions

<b>Here are steps to use this component:</b>
  1. Install this package per the **Deploy to Salesforce** button below
  2. Assign the "PS2RagStatus" permission set to the users that need access to this component
  3. Two options to use this component:
     * Use the pre-installed "RAG Status" application that already has a page setup under the "Status" tab
     * Or drop the "ps2RagStatus" LWC component on any page or home page
  4. [Optional] Can configure the component properties:
     * Card Title
     * Card Icon

     
<a href="https://githubsfdeploy.herokuapp.com?owner=thedges&repo=PS2RagStatus&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
