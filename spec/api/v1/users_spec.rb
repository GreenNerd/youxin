require 'spec_helper'

describe Youxin::API, 'users' do
  include ApiHelpers

  describe "GET /user" do
    before(:each) do
      @user = create :user
    end
    it "should return current user" do
      get api('/user', @user)
      response.status.should == 200
      json_response['email'].should == @user.email
      json_response['name'].should == @user.name
    end
    it "should return 401" do
      get api('/user')
      response.status.should == 401
    end
  end

  describe "GET /user/authorized_organizations" do
    before(:each) do
      @admin = create :user
      @organization = create :organization
      @organization_another = create :organization
      @actions_one = Action.options_array_for(:youxin)
      @actions_other = Action.options_array_for(:organization)

      @organization.authorize_cover_offspring(@admin, @actions_one)
      @organization_another.authorize_cover_offspring(@admin, @actions_other)
    end
    it "should return authorized_organizations" do
      get api('/user/authorized_organizations', @admin)
      response.status.should == 200
      json_response.should be_an Array
      json_response.to_json.should == [
        {
          id: @organization.id,
          name: @organization.name,
          parent_id: @organization.parent_id,
          avatar: @organization.avatar.url
        },
        {
          id: @organization_another.id,
          name: @organization_another.name,
          parent_id: @organization_another.parent_id,
          avatar: @organization_another.avatar.url
        }
      ].to_json
    end

    context "params[:actions]" do
      it "should return authorized actions organizations when single params[:actions]" do
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin]
        response.status.should == 200
        json_response.should be_an Array
        json_response.to_json.should == [
          {
            id: @organization.id,
            name: @organization.name,
            parent_id: @organization.parent_id,
            avatar: @organization.avatar.url
          }
        ].to_json
      end
      it "should return authorized actions organizations when multi params[:actions]" do
        get api('/user/authorized_organizations', @admin), actions: [:create_youxin, :create_organization]
        response.status.should == 200
        json_response.should be_an Array
        json_response.to_json.should == [].to_json
      end
    end
  end

  describe "GET /user/receipt_organizations" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of organizations which have sent a post to uesr (nested)" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/receipt_organizations', @user)
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @organization_1.id,
          name: @organization_1.name,
          parent_id: @organization_1.parent_id,
          avatar: @organization_1.avatar.url
        }
      ].as_json
    end
    it "should return the array of organizations which have sent a post to uesr" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_3, @organization_4].map(&:id)
      get api('/user/receipt_organizations', @user)
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @organization_1.id,
          name: @organization_1.name,
          parent_id: @organization_1.parent_id,
          avatar: @organization_1.avatar.url
        },
        {
          id: @organization_3.id,
          name: @organization_3.name,
          parent_id: @organization_3.parent_id,
          avatar: @organization_3.avatar.url
        },
        {
          id: @organization_4.id,
          name: @organization_4.name,
          parent_id: @organization_4.parent_id,
          avatar: @organization_4.avatar.url
        }
      ].as_json
    end
  end

  describe "GET /user/receipt_users" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of users who have sent a post to user" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/receipt_users', @user)
      response.status.should == 200
      json_response.should be_an Array
      json_response.should == [
        {
          id: @admin.id,
          email: @admin.email,
          name: @admin.name,
          created_at: @admin.created_at,
          avatar: @admin.avatar.url
        }
      ].as_json
    end
  end

  describe "GET /user/receipts" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/receipts', @user)
      @receipt = @user.receipts.first
      response.status.should == 200
      json_response.should == [
        {
          id: @receipt.id,
          read: @receipt.read,
          organization_ids: @receipt.organization_ids,
          origin: @receipt.origin,
          post: {
            id: @receipt.post.id,
            title: @receipt.post.title,
            body: @receipt.post.body,
            body_html: @receipt.post.body_html,
            author: {
              id: @receipt.author.id,
              email: @receipt.author.email,
              name: @receipt.author.name,
              created_at: @receipt.author.created_at,
              avatar: @receipt.author.avatar.url
            },
            attachments: []
          }
        }
      ].as_json
    end
  end
  describe "GET /user/unread_receipts" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      get api('/user/unread_receipts', @user)
      @receipt = @user.receipts.first
      response.status.should == 200
      json_response.should == [
        {
          id: @receipt.id,
          read: @receipt.read,
          organization_ids: @receipt.organization_ids,
          origin: @receipt.origin,
          post: {
            id: @receipt.post.id,
            title: @receipt.post.title,
            body: @receipt.post.body,
            body_html: @receipt.post.body_html,
            author: {
              id: @receipt.author.id,
              email: @receipt.author.email,
              name: @receipt.author.name,
              created_at: @receipt.author.created_at,
              avatar: @receipt.author.avatar.url
            },
            attachments: []
          }
        }
      ].as_json
    end
  end
  describe "GET /user/favorite_receipts" do
    before(:each) do
      @admin = create :user
      @user = create :user
      @organization_1 = create :organization
      @organization_2 = create :organization, parent: @organization_1
      @organization_3 = create :organization, parent: @organization_1
      @organization_4 = create :organization, parent: @organization_2
      @actions_youxin = Action.options_array_for(:youxin)
      @actions_organization = Action.options_array_for(:organization)

      @organization_1.authorize_cover_offspring(@admin, @actions_youxin)
      @organization_1.push_member(@user)
      @organization_2.push_member(@user)
      @organization_3.push_member(@user)
      @organization_4.push_member(@user)
    end
    it "should return the array of favorited receipts" do
      @post = create :post, author: @admin, organization_ids: [@organization_1, @organization_2, @organization_3, @organization_4].map(&:id)
      @receipt = @user.receipts.first
      @receipt.favorites.create user_id: @user.id
      get api('/user/favorite_receipts', @user)
      response.status.should == 200
      json_response.should == [
        {
          id: @receipt.id,
          read: @receipt.read,
          organization_ids: @receipt.organization_ids,
          origin: @receipt.origin,
          post: {
            id: @receipt.post.id,
            title: @receipt.post.title,
            body: @receipt.post.body,
            body_html: @receipt.post.body_html,
            author: {
              id: @receipt.author.id,
              email: @receipt.author.email,
              name: @receipt.author.name,
              created_at: @receipt.author.created_at,
              avatar: @receipt.author.avatar.url
            },
            attachments: []
          }
        }
      ].as_json
    end
  end

  describe "GET /user/:id" do
    context "/" do
      before(:each) do
        @user = create :user
      end
      it "should return the info of a single user" do
        get api("/users/#{@user.id}", @user)
        response.status.should == 200
        json_response.should == {
          id: @user.id,
          email: @user.email,
          name: @user.name,
          created_at: @user.created_at,
          avatar: @user.avatar.url
        }.as_json
      end
    end

    context "/organizations" do
      before(:each) do
        @user = create :user
        @organization = create :organization
        @organization.push_member(@user)
      end
      it "should return the array of organizations which the user is in" do
        get api("/users/#{@user.id}/organizations", @user)
        response.status.should == 200
        json_response.should == [
          {
            id: @organization.id,
            name: @organization.name,
            parent_id: @organization.parent_id,
            avatar: @organization.avatar.url
          }
        ].as_json
      end
    end

    context "/receipts" do
      before(:each) do
        @admin = create :user
        @user = create :user
        @organization = create :organization
        @actions_youxin = Action.options_array_for(:youxin)
        @actions_organization = Action.options_array_for(:organization)

        @organization.authorize_cover_offspring(@admin, @actions_youxin)
        @organization.push_member(@user)
      end
      it "should return the array of receipts which created by single user" do
        @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
        get api("/users/#{@admin.id}/receipts", @user)
        @receipt = @user.receipts.first
        response.status.should == 200
        json_response.should == [
          {
            id: @receipt.id,
            read: @receipt.read,
            organization_ids: @receipt.organization_ids,
            origin: @receipt.origin,
            post: {
              id: @receipt.post.id,
              title: @receipt.post.title,
              body: @receipt.post.body,
              body_html: @receipt.post.body_html,
              author: {
                id: @receipt.author.id,
                email: @receipt.author.email,
                name: @receipt.author.name,
                created_at: @receipt.author.created_at,
                avatar: @receipt.author.avatar.url
              },
              attachments: []
            }
          }
        ].as_json
      end
    end

    context "/unread_receipts" do
      before(:each) do
        @admin = create :user
        @user = create :user
        @organization = create :organization
        @actions_youxin = Action.options_array_for(:youxin)
        @actions_organization = Action.options_array_for(:organization)

        @organization.authorize_cover_offspring(@admin, @actions_youxin)
        @organization.push_member(@user)
      end
      it "should return the array of unread receipts from single user" do
        @post = create :post, author: @admin, organization_ids: [@organization].map(&:id)
        get api("/users/#{@admin.id}/unread_receipts", @user)
        @receipt = @user.receipts.unread.first
        response.status.should == 200
        json_response.should == [
          {
            id: @receipt.id,
            read: @receipt.read,
            organization_ids: @receipt.organization_ids,
            origin: @receipt.origin,
            post: {
              id: @receipt.post.id,
              title: @receipt.post.title,
              body: @receipt.post.body,
              body_html: @receipt.post.body_html,
              author: {
                id: @receipt.author.id,
                email: @receipt.author.email,
                name: @receipt.author.name,
                created_at: @receipt.author.created_at,
                avatar: @receipt.author.avatar.url
              },
              attachments: []
            }
          }
        ].as_json
      end
    end

  end
end