/**
 * Exercises 'no access' unit tests with a RunAs user 
 * when a 'PREP No Access' profile is available, 
 * and expects that profile to have no access to 
 * Point and Score custom objects.  
 */
@isTest
private class NoAccessTest {

    static testMethod void testDoVerifyCtrl_NoAccess() {

        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE);

            if (noAccess!=null) System.runAs(noAccess) {
                PageReference pageRef = Page.Verify;
                Test.setCurrentPage(pageRef);
                VerifyCtrl ctrl = new VerifyCtrl();
                
                ctrl.Module = Factory.TD;
                pageRef = ctrl.doVerifyCtrl();        
                System.assert(Factory.hasMessage(Factory.ERROR_INSUFFICIENT_ACCESS), 
                    'Expected message: ' + Factory.ERROR_INSUFFICIENT_ACCESS);
            }
    }    
    
    static testMethod void testMainCtrl_Constructor() {
        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE);
        if (noAccess!=null) System.runAs(noAccess) {
            PageReference pageRef = Page.Main;
            Test.setCurrentPage(pageRef);
            MainCtrl ctrl = new MainCtrl();
            System.assert(Factory.hasMessage(Factory.ERROR_INSUFFICIENT_ACCESS), 
                'Expected message: ' + Factory.ERROR_INSUFFICIENT_ACCESS);
        }
    }     
 
    static testMethod void testGetModules_NoAccess() {
        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE);
        if (noAccess!=null) System.runAs(noAccess) {
            List<SelectOption> options = Factory.getModules();
            System.assert(options.size()==0,
                'Expected empty options on no access');
            System.assert(Factory.hasMessage(Factory.ERROR_INSUFFICIENT_ACCESS), 
                'Expected message: ' + Factory.ERROR_INSUFFICIENT_ACCESS);
        }
    }

    static testMethod void testLogComplete_NoAccess() {
        List<Point__c> data = Factory.newModuleTest(Factory.TM);
        insert data;   
        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE);
        if (noAccess!=null) System.runAs(noAccess) {
            Factory.logComplete(data[0].Id,1);
            System.assert(Factory.hasMessage(Factory.ERROR_INSUFFICIENT_ACCESS), 
                'Expected message: ' + Factory.ERROR_INSUFFICIENT_ACCESS);
        }
    }

    static testMethod void testClearScore_NoAccess() {
        List<Point__c> data = Factory.newModuleTest(Factory.TM);
        insert data;   
        Factory.logComplete(data[0].Id,1);
        Id accessId = UserInfo.getUserId();
        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE);
        if (noAccess!=null) System.runAs(noAccess) {
            Factory.ClearScore(accessId,Factory.TM);
            System.assert(Factory.hasMessage(Factory.ERROR_INSUFFICIENT_ACCESS), 
                'Expected message: ' + Factory.ERROR_INSUFFICIENT_ACCESS);
        }
    }
    
    static testMethod void testProfile_NoAccess() {
        User noAccess = Factory.getTestUser(
            Factory.NO_ACCESS_NAME, Factory.NO_ACCESS_PROFILE + '.oops');
        System.assert(null==noAccess,
            'Expected null user for non-existant profile.');
    }    
}