require 'spec_helper'

describe Session do

  it "should log in to ASI when created" do
    s = Session.create
    resp = s.check
    resp["entry"]["app_id"].should_not be_nil
    s.destroy
  end
  
  it "should start an app_only session, when created without user credentials" do
    s = Session.create
    resp = s.check
    resp["entry"]["app_id"].should_not be_nil
    resp["entry"]["user_id"].should be_nil
    s.destroy
  end

  it "should start a user-specific session, when created with valid user credentials" do
    s = Session.create( {:username => "kassi_testperson1", :password => "testi"})
    # FIXME get rid of the expectation that kassi_testperson1 already exists in ASI
    resp = s.check
    resp["entry"]["app_id"].should_not be_nil
    resp["entry"]["user_id"].should_not be_nil
    s.destroy
  end
  
  it "should raise an error if created with false user credentials" do
    begin
      s = Session.create( {:username => "kassi_testperson1", :password => "wrongpass"})
      s.should_not be_valid
    rescue ActiveResource::UnauthorizedAccess => e
      e.class.should == ActiveResource::UnauthorizedAccess
    end
  end
  
  it "should raise an error if created with false application credentials" do
    begin
      s = Session.create({:app_name => "wrongname", :app_password => "wrong"})
      s.should_not be_valid
    rescue ActiveResource::UnauthorizedAccess => e
      e.class.should == ActiveResource::UnauthorizedAccess
    end
  end
  
  it "should keep session open and make further calls to ASI possible" do
    s = Session.create
    # Just try that the check call will go through twice.
    # Not the best way to test, but shall be ok for unit testing
    resp = s.check
    resp["entry"]["app_id"].should_not be_nil
    resp = s.check
    resp["entry"]["app_id"].should_not be_nil
    s.destroy
  end
  
  it "should log out from ASI when destroyed" do
    s = Session.create
    cookie = s.cookie
    resp = s.destroy
    resp.class.should == Net::HTTPOK

    #test that the cookie is no more valid  
    #do another session
    s2 = Session.create
    s2.check.should_not be_nil
    cookie2 = s2.cookie
    #use old cookie for s2
    s2.cookie = cookie
    s2.check.should be_nil
    #log out s2
    s2.cookie = cookie2
    s2.destroy
  end

end