/**
 * Confirms that user is ready to clear his or her scores for a particular module, and start over. 
 * Custom Object access is enforced by the doVerifyCtrl method. 
 * CRUD is enforced by the Factory.clearScore method. 
 * Standard objects are not accessed.
 * 
 */
public with sharing class VerifyCtrl {

    public String Module {get;set;}    
    public String Completed {get;set;}
    public String Remaining {get;set;}
    
    public VerifyCtrl() {
        Module = System.currentPagereference().getParameters().get(Factory.PARAM_MODULE);
    }

    public PageReference doVerifyCtrl() {
        String myModule = Module;
        Boolean isModule = (null!=myModule && ''!=myModule);
        if (!isModule) {
            ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,Factory.ERROR_PRIOR_NOT_SELECTED)
              );
        }

        Boolean isAccessible = Score__c.sObjectType.getDescribe().isAccessible();
        if (!isAccessible) {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,Factory.ERROR_INSUFFICIENT_ACCESS));
        }
        
        Boolean greenLight = (isAccessible && isModule);
        
        if (greenLight) {        
            Integer doneCount = Factory.doneCount(Module);      
            Integer moduleCount = Factory.moduleCount(Module);
            Remaining = String.valueOf(moduleCount - doneCount);
            Completed = String.valueOf(doneCount);         
        }

        return (greenLight) ? null : Page.Main;
    }
    
    /**
     * Navigates to main page, if user cancels. 
     */
    public PageReference doMain() {
        return Page.Main;
    }

    /** 
     * Deletes Scores recorded for the current user and selected module (only), 
     * and navigates to main page.
     */
    public PageReference doClearScore() {
        Factory.clearScore(Module);
        return Page.Main;
    }
}