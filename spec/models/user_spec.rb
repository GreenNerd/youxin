# encoding: utf-8

require 'spec_helper'

describe User do
  let(:user) { build :user }
  subject { user }

  describe "Association" do
    it { should have_many(:user_organization_position_relationships) }
    it { should have_many(:user_actions_organization_relationships) }
    it { should have_many(:applications) }
    it { should have_many(:treated_applications) }
    it { should have_many(:posts) }
    it { should have_many(:receipts) }
    it { should have_many(:attachments) }
    it { should have_many(:forms) }
    it { should have_many(:collections) }
    it { should have_many(:comments) }
    it { should have_many(:favorites) }
    it { should have_many(:notifications) }
    it { should have_many(:comment_notifications) }
    it { should have_many(:organization_notifications) }
    it { should have_many(:mention_notifications) }
    it { should have_many(:communication_records) }
    it { should have_many(:sms_communication_records) }
    it { should have_many(:call_communication_records) }
    it { should have_and_belong_to_many(:conversations) }
    it { should have_many(:messages) }
    it { should have_many(:message_notifications) }
    it { should have_many(:schedulers) }
    it { should have_many(:sms_schedulers) }
    it { should have_many(:call_schedulers) }
    it { should have_many(:user_role_organization_relationships) }
    it { should belong_to(:namespace) }
    it { should belong_to(:creator) }
    it { should have_many(:binds) }
    it { should have_many(:feedbacks) }
  end

  describe "Respond to" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:organization_ids) }
    it { should respond_to(:organizations) }
    it { should respond_to(:position_in_organization) }
    it { should respond_to(:human_position_in_organization) }
    it { should respond_to(:authorized_organizations) }
    it { should respond_to(:apply_for_organization) }
    it { should respond_to(:applied_for_organization?) }
    it { should respond_to(:accepted_by_organization?) }
    it { should respond_to(:operate_application) }
    it { should respond_to(:receipt_organizations) }
    it { should respond_to(:receipt_users) }
    it { should respond_to(:notification_channel) }
    it { should respond_to(:ensure_notification_channel!) }
    it { should respond_to(:ios_device_tokens) }
    it { should respond_to(:phone) }
    it { should respond_to(:send_message_to) }
    it { should respond_to(:reset_sms_token) }
    it { should respond_to(:reset_sms_sent_at) }
    it { should respond_to(:push_ios_device_token) }
    it { should respond_to(:add_ios_device_token) }
    it { should respond_to(:pull_ios_device_token) }
    it { should respond_to(:remove_ios_device_token) }
    it { should respond_to(:tags) }
  end

  it "should create a new instance given a valid attributes" do
    expect(build :user).to be_valid
  end

  describe "#organizations" do
    before do
      @organization = create :organization
      @user = create :user
    end
    it "should return correctly" do
      @organization.push_member(@user)
      @user.organizations.include?(@organization).should be_true
    end
  end
  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#apply_for_organization" do
    before(:each) do
      @user = create :user
      @organization = create :organization
    end
    it "should create a new applications for organization" do
      @user.apply_for_organization(@organization)
      @user.applications.should_not be_blank
    end
    it "should create a new applications for organization with id" do
      @user.apply_for_organization(@organization.id)
      @user.applications.should_not be_blank
    end
    it "should do nothing organization not exist" do
      @user.apply_for_organization('not_exist')
      @user.applications.should be_blank
    end
  end
  describe "#applied_for_organization?" do
    before(:each) do
      @user = create :user
      @organization = create :organization
    end
    it "should return true if user have applied for the organization" do
      @user.apply_for_organization(@organization)
      @user.applied_for_organization?(@organization).should be_true
    end
    it "should return false if user have not applied for the organization" do
      @user.applied_for_organization?(@organization).should be_false
    end
    it "should return true if user have applied for the organization with id" do
      @user.apply_for_organization(@organization.id)
      @user.applied_for_organization?(@organization).should be_true
    end
    it "should return false if user have not applied for the organization with id" do
      @user.applied_for_organization?(@organization.id).should be_false
    end
  end
  describe "#accepted_by_organization?" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @operator = create :user
    end
    it "should accepted by organization" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
    end
    it "should not accepted by organization" do
      @user.apply_for_organization(@organization)
      @user.accepted_by_organization?(@organization).should be_false
    end
    it "should accepted by organization with id" do
      application = @user.apply_for_organization(@organization.id)
      @operator.operate_application(application, :accepted)
      @user.reload.accepted_by_organization?(@organization.id).should be_true
    end
    it "should not accepted by organization with id" do
      @user.apply_for_organization(@organization)
      @user.accepted_by_organization?(@organization.id).should be_false
    end
  end
  describe "#operate_application" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @operator = create :user
    end
    it "should accept user" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @user.accepted_by_organization?(@organization).should be_true
    end
    it "should not accept user" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :rejected)
      @user.accepted_by_organization?(@organization).should be_false
    end
    it "should be the member of organization" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @organization.members.should include(@user)
    end
    it "should have a operator" do
      application = @user.apply_for_organization(@organization)
      @operator.operate_application(application, :accepted)
      @operator.treated_applications.should include(application)
    end
  end

  describe "#authorized_organizations" do
    before(:each) do
      @organization1 = create :organization
      @organization2 = create :organization
      @organization3 = create :organization
      @user = create :user
      @actions1 = Action.options_array_for(:organization)
      @actions2 = Action.options_array_for(:youxin)
      @organization1.authorize(@user, @actions1)
      @organization2.authorize(@user, @actions2)
      @organization3.authorize(@user, @actions1 + @actions2)
    end
    it "should return the array of authorized organizations" do
      @user.authorized_organizations.should include(@organization1)
      @user.authorized_organizations.should include(@organization2)
      @user.authorized_organizations.should include(@organization3)
    end
    it "should return the array of authorized organizations with actions" do
      @user.authorized_organizations([:create_organization]).should include(@organization1)
      @user.authorized_organizations([:create_organization]).should include(@organization3)
      @user.authorized_organizations([:create_youxin]).should include(@organization2)
      @user.authorized_organizations([:create_youxin]).should include(@organization3)
      @user.authorized_organizations([:create_youxin, :create_organization]).should include(@organization3)
    end
  end

  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return a position if set" do
      @organization.add_member(@user, @position)
      @user.position_in_organization(@organization).should be_kind_of Position
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.position_in_organization(@organization).should be_nil
    end
  end
  describe "#human_position_in_organization" do
    before do
      @organization = create :organization
      @user = create :user
      @position = create :position
    end
    it "should return human position if set" do
      @organization.add_member(@user, @position)
      @user.human_position_in_organization(@organization).should == @position.name
    end
    it "should return nil if not_set" do
      @organization.add_member(@user)
      @user.human_position_in_organization(@organization).should be_nil
    end
  end

  describe "#destroy" do
    before do
      @organization = create :organization
      @user = create :user
      @organization.push_member(@user)
    end
    it "should remove organizations" do
      @user.destroy
      @user.organizations.should be_blank
    end
    it "should remove user from organization" do
      @user.destroy
      @organization.reload.member_ids.include?(@user.id).should be_false
    end
  end

  describe "attributes" do
    context 'email' do
      before { user.email = '' }
      its(:valid?) { should be_true }
    end

    context 'creator_id' do
      before(:each) do
        @admin = create :user
      end

      it 'should be valid with creator_id' do
        user.creator_id = @admin.id
        user.should be_valid
      end

      it 'should set creator to the admin' do
        user.creator = @admin.id
        user.save
        user.reload
        user.creator.should == @admin
      end

      it 'should be valid with nil creator_id' do
        user.creator_id = nil
        user.should be_valid
      end

      it 'should have one error on creator_id' do
        user.creator_id = 'not_found'
        user.save
        user.should have(1).errors_on(:creator_id)
      end
    end
  end

  describe "invalid attributes" do
    context "name" do
      context "is blank" do
        before { user.name = '' }
        its(:valid?) { should be_false }
      end
    end

    context "avatar" do
      it "return url of avatar" do
        avatar_path = Rails.root.join("spec/factories/images/avatar.png")
        user = create :user, avatar: Rack::Test::UploadedFile.new(avatar_path)
        user.avatar.file.should_not be_blank
        user.avatar.url.should_not be_blank
      end
    end

    context "phone" do
      it "should create with blank phone" do
        user.save.should be_true
      end
      it "should have error when blank" do
        user.phone = ''
        user.save
        user.should have_at_least(1).errors_on(:phone)
      end
      it "should have error on length" do
        user.phone = '123456789'
        user.save
        user.should have(1).errors_on(:phone)
      end
      it "should have error on format" do
        user.phone = '28600000000'
        user.save
        user.should have(1).errors_on(:phone)
      end
      it "should have one error on format" do
        user.phone = '186000000000'
        user.save
        user.should have(1).errors_on(:phone)
      end
      it "should have no error on format" do
        user.phone = '18600000000'
        user.save
        user.should have(0).errors_on(:phone)
      end
    end

    context "qq" do
      it "should have an error on format" do
        user.qq = 'abcdefg'
        user.save
        user.should have(1).errors_on(:qq)
      end
      it "should have an error on format when length less than 5" do
        user.qq = '1234'
        user.save
        user.should have(1).errors_on(:qq)
      end
      it "should have an error on format when length more than 11" do
        user.qq = '012345678901'
        user.save
        user.should have(1).errors_on(:qq)
      end
      it "should have no error on format" do
        user.qq = '123456789'
        user.save
        user.should have(0).errors_on(:qq)
      end
      it 'should be valid if blank' do
        user.qq = '123456789'
        user.save
        user.qq = ''
        user.should be_valid
      end
    end
    context "gender" do
      it "should have an error when gender not inclusion" do
        user.gender = 'male'
        user.save
        user.should have(1).errors_on(:gender)
      end
      it "should have no error on gender" do
        user.gender = '男'
        user.save
        user.should have(0).errors_on(:gender)
      end
    end
  end

  describe "#update_with_password" do
    context "without password" do
      before do
        user.save
        user.update_with_password name: 'name-new'
        user.reload
      end
      its(:name) { should == 'name-new' }
    end

    context "with password" do
      before do
        user.save
        user.update_with_password name: 'name-new', password: 'invalid_password'
        user.reload
      end
      its(:name) { should_not == 'name-new' }
    end
  end

  describe "#receipts" do
    before(:each) do
      @organization = create :organization
      @organization_another = create :organization
      @user = create :user
      @author = create :user
      @author_another = create :user
      @organization.push_member(@user)
      @organization_another.push_member(@user)
      @post = create(:post, author: @author,
                      organization_ids: [@organization.id])
      @post_another = create(:post, author: @author_another,
                              organization_ids: [@organization_another.id])
    end
    context "from_user(:user_id)" do
      it "should return receipts which from single user" do
        @user.receipts.from_user(@author.id).map(&:id).should include(@user.receipts.last.id)
      end
      it "should not include receipts which not from single user" do
        @user.receipts.from_user(@author.id).map(&:id).should_not include(@user.receipts.first.id)
        @user.receipts.from_user(@author_another.id).map(&:id).should_not include(@user.receipts.last.id)
      end
    end
    context "from_organization(:organization_id)" do
      it "should return receipts from single organization" do
        @user.receipts.from_organization(@organization.id).map(&:id).should include(@user.receipts.last.id)
      end
      it "should not include receipts which not from single organization" do
        @user.receipts.from_organization(@organization.id).map(&:id).should_not include(@user.receipts.first.id)
      end
    end
    context "read" do
      it "should create" do
        @author.receipts.read.first.post.should == @post
      end
    end
    context "unread" do
      it "should not create" do
        @author.receipts.unread.should be_blank
      end
    end
  end

  describe "#comments" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should create comment" do
      @comment = @post.comments.create attributes_for(:comment).merge({ user_id: @user.id })
      @comment.should be_valid
    end
  end
  describe "#receipt_organizations" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should return the array of organizations which have send post to user" do
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @user.reload
      ([@organization] - @user.receipt_organizations).should be_blank
    end
  end
  describe "#receipt_users" do
    before(:each) do
      @organization = create :organization
      @user = create :user
      @author = create :user
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
    end
    it "should return the array of users which have send post to user" do
      @post = create :post, author: @author, organization_ids: [@organization.id]
      @user.reload
      ([@author] - @user.receipt_users).should be_blank
    end
  end

  describe "#favorites" do
    before(:each) do
      namespace = create :namespace
      @organization = create :organization, namespace: namespace
      @user = create :user, namespace: namespace
      @user_another = create :user, namespace: namespace
      @author = create :user, namespace: namespace
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                           organization_ids: [@organization.id],
                           body_html: '<div>test</div>')
      @receipt = @user.receipts.first
    end
    it "should create favorite receipt" do
      @receipt.favorites.create user_id: @user.id
      @user.favorites.count.should == 1
      @user.favorites.receipts.pluck(:favoriteable_id).should include(@receipt.id)
    end
    it "should create favorite user" do
      @user.favorites.create favoriteable: @user_another
      @user.favorites.count.should == 1
      @user.favorites.users.pluck(:favoriteable_id).should include(@user_another.id)
    end
  end

  describe "#ensure_notification_channel!" do
    before(:each) do
      @user = create :user
    end
    it "should generate notification_channel to user" do
      @user.notification_channel.should_not be_blank
    end
  end

  describe "#send_message_to" do
    it "should return a conversation" do
      user = create :user
      user_another = create :user
      body = 'body'
      conversation = user.send_message_to(user_another, body)
      conversation.should be_a_kind_of Conversation

    end
    context "direct message" do
      before(:each) do
        @user_one = create :user
        @user_another = create :user
        @body = 'body'
      end
      it "should make a conversation to author" do
        @user_one.send_message_to(@user_another, @body)
        @user_one.conversations.count.should == 1
      end
      it "should make a conversation to recipant" do
        @user_one.send_message_to(@user_another, @body)
        @user_another.conversations.count.should == 1
      end
      it "should append author as originator to conversation" do
        conversation = @user_one.send_message_to(@user_another, @body)
        conversation.originator.should == @user_one
      end
      it "should append participants to conversation" do
        conversation = @user_one.send_message_to(@user_another, @body)
        conversation.participants.should include(@user_one)
        conversation.participants.should include(@user_another)
      end
      it "should not create a new conversation if conversation exists" do
        @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(@user_another, @body)
        end.to change { Conversation.count }.by(0)
      end
      it "should not create a new conversation if conversation exists but not create by user" do
        @user_one.send_message_to(@user_another, @body)
        expect do
          @user_another.send_message_to(@user_one, @body)
        end.to change { Conversation.count }.by(0)
      end
      it "should not create a new conversation if participant is user" do
        expect do
          @user_one.send_message_to(@user_one, @body)
        end.to change { Conversation.count }.by(0)
      end

      it "should create a new message" do
        expect do
          @user_one.send_message_to(@user_another, @body)
        end.to change { @user_one.messages.count }.by(1)
      end
      it "should also create a new messages if conversation exists" do
        @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(@user_another, @body)
        end.to change { @user_one.messages.count }.by(1)
      end

      it "should update the update_at of conversation" do
        conversation = @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(@user_another, @body)
          conversation.reload
        end.to change { conversation.updated_at }
      end
      it "should create last_message" do
        conversation = @user_one.send_message_to(@user_another, @body)
        conversation.last_message.should == @user_one.messages.first
      end
      it "should update last_message" do
        conversation = @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(@user_another, @body)
          conversation.reload
        end.to change { conversation.last_message }
      end
    end

    context "obj is_a Conversation" do
      before(:each) do
        @user_one = create :user
        @user_another = create :user
        @body = 'body'
      end
      it "should create a new message" do
        conversation = @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(conversation, @body)
        end.to change { @user_one.messages.count }.by(1)
      end
      it "should update the update_at of conversation" do
        conversation = @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(conversation, @body)
        end.to change { conversation.updated_at }
      end
      it "should create last_message" do
        conversation = @user_one.send_message_to(@user_another, @body)
        conversation.last_message.should_not be_blank
      end
      it "should update last_message" do
        conversation = @user_one.send_message_to(@user_another, @body)
        expect do
          @user_one.send_message_to(conversation, @body)
        end.to change { conversation.last_message }
      end
    end

    context "group chat(obj is_a Array)" do
      before(:each) do
        @user = create :user
        @user_one = create :user
        @user_another = create :user
        @body = 'body'
      end
      it "should create a conversation" do
        @user.send_message_to([@user_one, @user_another], @body)
        @user.conversations.count.should == 1
        @user_one.conversations.count.should == 1
        @user_another.conversations.count.should == 1
      end
      it "should create a conversation with uniq participants" do
        @user.send_message_to([@user_one, @user_another, @user_one], @body)
        Conversation.first.participants.count.should == 3
      end
      it "should create another conversation" do
        @user.send_message_to([@user_one, @user_another], @body)
        expect do
          @user.send_message_to(@user_one, @body)
        end.to change { Conversation.count }.by(1)
      end
    end
  end

  describe "namespace" do
    before(:each) do
      @namespace = create :namespace
      @user = create :user, namespace: @namespace
    end
    it { @user.namespace.should == @namespace }
    it { @namespace.users.should == [@user] }
  end

  describe '#push_ios_device_token' do
    before(:each) do
      user.save
      @valid_token = 'a' * 64
    end
    it 'should add ios_device_token to user' do
      user.push_ios_device_token @valid_token
      user.ios_device_tokens.should include(@valid_token)
    end
    it 'should not add ios_device_token to user if exist' do
      user.push_ios_device_token @valid_token
      user.push_ios_device_token @valid_token
      user.ios_device_tokens.size.should == 1
    end
    it 'should not add ios_device_token if too short' do
      token = 'a'
      user.push_ios_device_token token
      user.should have(1).error
    end
    it 'should not add ios_device_token if too long' do
      token = @valid_token * 2
      user.push_ios_device_token token
      user.should have(1).error
    end
    it 'should unique the ios_device_token' do
      user_another = create :user
      user.push_ios_device_token @valid_token
      user_another.push_ios_device_token @valid_token
      user.reload
      user_another.reload
      user.ios_device_tokens.should_not include(@valid_token)
      user_another.ios_device_tokens.should include(@valid_token)
    end
  end
  describe '#pull_ios_device_token' do
    before(:each) do
      user.save
      @valid_token = 'a' * 64
      user.ios_device_tokens = [@valid_token]
      user.save
    end
    it 'should remove ios_device_token from user' do
      user.pull_ios_device_token @valid_token
      user.reload
      user.ios_device_tokens.should_not include(@valid_token)
    end
    it 'should not add ios_device_token to user if exist' do
      user.pull_ios_device_token @valid_token
      user.reload
      user.ios_device_tokens.size.should == 0
    end
    it 'should not add ios_device_token if too short' do
      token = 'a'
      user.pull_ios_device_token token
      user.should have(1).errors
    end
    it 'should not add ios_device_token if too long' do
      token = @valid_token * 2
      user.pull_ios_device_token token
      user.should have(1).errors
    end
  end

  describe '#send_welcome_receipt' do
    before(:each) do
      @namespace = create :namespace
      @organization = create :organization, namespace: @namespace
      @user = create :user, namespace: @namespace
      @author = create :user, namespace: @namespace
      @organization.push_member(@user)
      @post = create(:post, author: @author,
                            organization_ids: [@organization.id],
                            body_html: '<div>test</div>')
      Youxin.config['welcome_post_id'] = @post.id
    end
    it 'should create welcome receipt to user' do
      user.namespace = @namespace
      user.save
      user.send_welcome_receipt
      user.receipts.unread.count.should == 1
      user.receipts.first.post.should == @post
    end
    it 'should create welcome receipt though diffrent namespaces' do
      ns = create :namespace
      user.save
      user.send_welcome_receipt
      user.receipts.unread.count.should == 1
      user.receipts.first.post.should == @post
    end
  end

  describe '#push_tag' do
    before(:each) do
      @namespace = create :namespace
      @user = create :user, namespace: @namespace
      @tag = 'tag'
    end

    it 'should add tag' do
      @user.push_tag(@tag)

      @user.tags.count.should == 1
      @user.tags.should include(@tag)
    end

    it 'should not add the same tag' do
      @user.push_tag(@tag)
      @user.push_tag(@tag)

      @user.tags.count.should == 1
    end
  end
  describe '#pull_tag' do
    before(:each) do
      @namespace = create :namespace
      @user = create :user, namespace: @namespace
      @tag = 'tag'

      @user.push_tag(@tag)
    end
    it 'should add tag' do
      @user.pull_tag(@tag)
      @user.tags.count.should == 0
    end
    it 'should do nothing' do
      @user.pull_tag(@tag)
      @user.pull_tag(@tag)
    end

  end
  describe '#set_up_tags' do
    before(:each) do
      @namespace = create :namespace
      @user = create :user, namespace: @namespace

      @organization = create :organization, namespace: @namespace
      @organization.push_member @user

      @user_another = create :user, namespace: @namespace
      @user.send_message_to([@user_another], 'body')
      @user.reload
      @conversation = @user.conversations.first

      @user.tags = []
      @user.save


      stub_request(:any, /.*channel\.api\.duapp\.com.*/)
        .to_return(status: 200, body: 'aa', headers: { 'Content-Type' => 'application/json;charset=utf-8' })
    end
    it 'should set tags' do
      @user.set_up_tags
      @user.tags.count.should == 2
    end
    it 'should set organization tags' do
      @user.set_up_tags
      @user.tags.should include(@organization.tag)
    end
    it 'should set conversation tags' do
      @user.set_up_tags
      @user.tags.should include(@conversation.tag)
    end
    it 'should remove and add tags' do
      old_tag = @conversation.tag
      @conversation.reset_tag!
      @user.set_up_tags
      @user.tags.should_not include(old_tag)
      @user.tags.should include(@conversation.tag)
    end
  end
end
