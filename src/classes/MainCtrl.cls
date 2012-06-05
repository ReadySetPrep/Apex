/**
 * Provides access to Review Exercises and Study Guides. 
 * Custom Object access is enforced by the getModuleItems method. 
 * CRUD is enforced by the Factory.clearScore method. 
 * Standard objects are not accessed.
 * 
 */
public with sharing class MainCtrl {

    public MainCtrl() {
        if (!Point__c.sObjectType.getDescribe().isAccessible()) {
          ApexPages.addMessage(
              new ApexPages.Message(
                  ApexPages.Severity.FATAL,Factory.ERROR_INSUFFICIENT_ACCESS));
        }    
    }

    // -- Pending Panel --
    
    /**
     * Pending field used with doPending or doGuidePending actions.
     * May be the Active module, or an module to become Active. 
     */
    public String Pending {get; set;}
 
    /**
     * Fetches the Active study session as a menu option.
     * Only one session can be active, and the single item is pre-seleted. 
     * If there are no sessions (for a new user), the item is disabled. 
     */
    public List<SelectOption> getPendingItem() {
        List<SelectOption> options = new List<SelectOption>();
        Active__c a = Factory.getActive();
        if (null==a) {
            options.add(new SelectOption(Factory.NO_PENDING,Factory.NO_PENDING,true));
        } else {
            options.add(new SelectOption(a.Module__c,a.Module__c));
            Pending = a.Module__c;
        }
        return options;    
    }

    /**
     * Navigates to Exercise page, with Pending module selected. 
     * Queues a message without navigation if Pending value is not valid. 
     */
    public PageReference doPending() {
        String myPending = Pending;
        if ((null==myPending) || (''==myPending) || (Factory.NO_PENDING==myPending)) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Factory.ERROR_PENDING_NOT_SELECTED));
            return null;
        } else {
            return Page.Exercise;
        }    
    }
    
    /**
     * Navigates to the Guide page, with the Pending module selected. 
     * Queues a message without navigation if Pending value is not valid. 
     */
    public PageReference doGuidePending() {
        String myPending = Pending;
        if ((null!=myPending) && (''!=myPending) && (Factory.NO_PENDING!=myPending)) { 
            PageReference guide = Page.Guide;
            guide.getParameters().put(Factory.PARAM_MODULE,myPending);        
            return guide;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Factory.ERROR_PENDING_NOT_SELECTED));
            return null;
        }    
    }
        
    // -- Module Panel --

    /**
     * Module field used with doModule action.
     */
    public String Module {get; set;}
 
    /** 
     * Fetches list of current modules available in this org.
     */
    public List<SelectOption> getModuleItems() {
        List<SelectOption> options = Factory.getModules();
        // Will return zero if access denied or no modules installed
        if (0==options.size()) {
            options.add(new SelectOption(Factory.NO_MODULES,Factory.NO_MODULES));
        }
        return options; 
    }

    /** 
     * Navigates to Exercise page, setting the selected Module as Active.
     */
    public PageReference doModule() {
        Active__c a = Factory.setActive(Module);
        return Page.Exercise;
    }
    
    // -- Prior Panel --

    /**
     * Prior field used with doPrior or doClearScore actions
     */    
    public String Prior {get; set;}
 
    /**
     * Fetches the Prior study sessions as menu options.
     * Prior sessions have logged one or more completed Study Points. 
     */
    public List<SelectOption> getPriorItems() {
        List<SelectOption> options = Factory.getPriors();
        if (0==options.size()) {
            options.add(new SelectOption(Factory.NO_PRIORS,Factory.NO_PRIORS,true));
        }
        return options; 
    }

    /**
     * Navigates to Study Guide page, with a Prior session selected. 
     * Queues a message without navigation if Prior value is not valid. 
     */
    public PageReference doGuide() {
        String myPrior = Prior; 
        if (null==myPrior || Factory.NO_PRIORS==myPrior) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Factory.ERROR_PENDING_NOT_SELECTED));
            return null;        
        }
        PageReference guide = Page.Guide;
        guide.getParameters().put('module',myPrior);        
        return guide;
    }
    
    /**
     * Navigates to Verify page, passing Pending as a parameter. 
     * If prior not selected, raises an error message. 
     */
    public PageReference doVerify() {
        String myPrior = Prior;
        if ((null!=myPrior) && (''!=myPrior) && (Factory.NO_PRIORS!=myPrior)) { 
            PageReference verify = Page.Verify;
            verify.getParameters().put(Factory.PARAM_MODULE,myPrior);        
            return verify;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                Factory.ERROR_PRIOR_NOT_SELECTED));
            return null;
        }
    }
}