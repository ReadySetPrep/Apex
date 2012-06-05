@isTest
private class MainCtrlTest {

    static MainCtrl initTest() {
        PageReference pageRef = Page.Main;
        Test.setCurrentPage(pageRef);
        MainCtrl ctrl = new MainCtrl();
        return ctrl;
    }
    
    static testMethod void testGetPendingItem_None() {
        MainCtrl ctrl = initTest();
        List<SelectOption> options = ctrl.getPendingItem();
        System.assert(options!=null);
        SelectOption option = options.get(0);
        System.assertEquals(Factory.NO_PENDING,option.getValue(),
            'Expected no option identifier.');
    }

    static testMethod void testGetPendingItem_One() {
        MainCtrl ctrl = initTest();
        Active__c a = Factory.setActive(Factory.TM);
        List<SelectOption> options = ctrl.getPendingItem();
        System.assert(options!=null);
        SelectOption option = options.get(0);
        System.assertEquals(Factory.TM,option.getLabel(),
            'Expected pending option.');
    }

    static testMethod void testGetPendingItem_NextUrl() {
        MainCtrl ctrl = initTest();
        Active__c a = Factory.setActive(Factory.TM);
        List<SelectOption> options = ctrl.getPendingItem();
        String myPending = options.get(0).getValue();
        System.assert((null!=myPending) && (''!=myPending) && (Factory.NO_PENDING!=myPending), 
            'Expected module not ['+ myPending + ']' );
 
        PageReference nextPage = ctrl.doPending();
        System.assert(null!=nextPage, 
            'Expected page navigation.');

        myPending = ctrl.Pending;
        System.assert(null!=myPending, 
            'Expected pending item to be set.');
        
        String nextPath = nextPage.getUrl();
        System.assertEquals(Factory.URL_EXERCISE,nextPath, 
            'Expected navigation to Exercise.');
    }
 
    static testMethod void testDoPending_None() {
         MainCtrl ctrl = initTest();
         ctrl.Pending = null;
         PageReference pageRef = ctrl.doPending();
         System.assert(null==pageRef, 
             'Expected no redirect if no pending.');
             
        System.assert(Factory.hasMessage(Factory.ERROR_PENDING_NOT_SELECTED),
            'Expected messsage.');                                               
   }
   
    static testMethod void testDoGuidePending() {
         MainCtrl ctrl = initTest();
         ctrl.Pending = Factory.TM;
         PageReference page = ctrl.doGuidePending();
         System.assert((null!=page) && 
            (Factory.URL_GUIDE + '?module=TM+-+Test+Module'==page.getUrl()),
            'Expected navigation to guide page, not ' + page.getUrl() + '.');                   
    }
        
    static testMethod void testDoGuidePending_None() {
         MainCtrl ctrl = initTest();
         ctrl.Pending = null;
         PageReference page = ctrl.doGuidePending();
         System.assert(null==page, 
             'Expected no redirect if no prior.');
             
         System.assert(Factory.hasMessage(Factory.ERROR_PENDING_NOT_SELECTED),
             'Expected message.');    
    }

    static testMethod void testGetModuleItems_None() {
        MainCtrl ctrl = initTest();
        List<SelectOption> options = ctrl.getModuleItems();
        System.assert(options!=null);
        SelectOption option = options.get(0);
        System.assertEquals(Factory.NO_MODULES,option.getValue(),
            'Expected no option identifier.');
    }

    static testMethod void testGetModuleIems_Two() {
        MainCtrl ctrl = initTest();
        List<Point__c> a = Factory.newModuleTest(Factory.TA);
            insert(a);
        List<Point__c> d = Factory.newModuleTest(Factory.TD);
            insert(d);
        List<SelectOption> options = ctrl.getModuleItems();
        System.assert(null!=options, 
            'Expected module item options.');
        boolean success = false;
        for (SelectOption o : options) {
            success = success || o.getLabel()==Factory.TA || o.getLabel()==Factory.TD;
        }
        System.assert(success,
            'Expected module options.');
    }
    
    static testMethod void testDoModule_NextUrl() {
        MainCtrl ctrl = initTest();        
        List<Point__c> a = Factory.newModuleTest(Factory.TM);
            insert(a);
        ctrl.Module = Factory.TM;
        PageReference page = ctrl.doModule();
        System.assert((null!=page) && (Factory.URL_EXERCISE==page.getUrl()),
            'Expected navigation to Exercise page.');
                 
        List<SelectOption> options = ctrl.getPendingItem();      
        System.assert(0!=options.size(),
            'Expected pending item.');
        
        boolean success = false;
        for (SelectOption o : options) {
            success = success || o.getLabel()==Factory.TM;
        }
        System.assert(success,
            'Expected test module to be pending.');
    }
    
    static testMethod void testGetPriorItems() {
        MainCtrl ctrl = initTest();
        
        List<Point__c> d = Factory.newModuleTest(Factory.TD);
            insert(d);  
        Point__c q = d[0];                  
        Factory.logComplete(q.Id,2);
        
        Active__c a = Factory.setActive(Factory.TM);
                
        List<Point__c> m = Factory.newModuleTest(Factory.TM);
            insert(m);        
        Point__c p = m[0];
        Factory.logComplete(p.Id,1);
        
        List<SelectOption> options = ctrl.getPriorItems();
        
        System.assert(null!=options && Factory.NO_PRIORS!=options[0].getValue(),
            'Expected actual prior items, not ' + options[0].getValue() + '.');        
        
        System.assert(2==options.size(),
            'Expected both prior item options.');        
    }
    
    static testMethod void testGetPriorItems_None() {
        MainCtrl ctrl = initTest();        
        List<SelectOption> options = ctrl.getPriorItems();
        
        System.assert(null==options || 0==options.size() || Factory.NO_PRIORS==options[0].getValue(),
            'Expected no prior items, not ' + options[0].getValue() + '.');                 
    }
    
    static testMethod void testDoGuide() {
         MainCtrl ctrl = initTest();
         ctrl.Prior = Factory.TM;
         PageReference pageRef = ctrl.doGuide();
         System.assert((null!=pageRef) && 
            (Factory.URL_GUIDE + '?module=TM+-+Test+Module'==pageRef.getUrl()),
            'Expected navigation to guide page, not ' + pageRef.getUrl() + '.');       
    }
        
    static testMethod void testDoGuide_None() {
         MainCtrl ctrl = initTest();
         ctrl.Prior = null;
         PageReference pageRef = ctrl.doGuide();
         System.assert(null==pageRef, 
             'Expected no redirect if no prior.');
    }
    
    static testMethod void testDoVerify() {
        MainCtrl ctrl = initTest();        
        ctrl.Prior = Factory.TD;
        PageReference pageRef = ctrl.doVerify();  
        System.assert(null!=pageRef, 
            'Expected navigation');
            
        String url = Factory.URL_VERIFY + '?module=TD+-+Test+Developer';     
        System.assert(url==pageRef.getUrl(),
            'Expected navigation to Verify page, not ' + PageRef.getUrl() + '.');
    }    
    
    static testMethod void testDoVerify_NoPrior() {
        MainCtrl ctrl = initTest();        
        ctrl.Prior = null;
        PageReference pageRef = ctrl.doVerify();  
        System.assert(Factory.hasMessage(Factory.ERROR_PRIOR_NOT_SELECTED), 
            'Expected message: ' + Factory.ERROR_PRIOR_NOT_SELECTED);        
    }
}