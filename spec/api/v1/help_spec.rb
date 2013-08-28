require 'spec_helper'

describe Youxin::API, 'help' do
  include ApiHelpers
  describe "GET /help/avatar_versions" do
    it "should return the array of avatar_versions" do
      get api('/help/avatar_versions')
      response.status.should == 200
      json_response.should == Version.avatars.as_json
    end
  end
  describe "GET /help/header_versions" do
    it "should return the array of header_versions" do
      get api('/help/header_versions')
      response.status.should == 200
      json_response.should == Version.headers.as_json
    end
  end
  describe "GET /help/contact_email" do
    it "should return the contact_email" do
      get api('/help/contact_email')
      response.status.should == 200
      json_response.should == {
        contact_email: Youxin.config.help.contact_email
      }.as_json
    end
  end
  describe "GET /help/terms" do
    it "should return the terms" do
      get api('/help/terms')
      response.status.should == 200
      json_response.should == {
        terms: Youxin.config.help.terms
      }.as_json
    end
  end
  describe "GET /help/about_us" do
    it "should return the about_us" do
      get api('/help/about_us')
      response.status.should == 200
      json_response.should == {
        about_us: Youxin.config.help.about_us
      }.as_json
    end
  end
  describe "GET /help/privacy" do
    it "should return the privacy" do
      get api('/help/privacy')
      response.status.should == 200
      json_response.should == {
        privacy: Youxin.config.help.privacy
      }.as_json
    end
  end
end