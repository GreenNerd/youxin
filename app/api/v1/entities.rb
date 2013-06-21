module Youxin
  module Entities
    class UserBasic < Grape::Entity
      expose :id, :email, :name, :created_at
      expose :avatar do |user|
        user.avatar.url
      end
    end

    class User < UserBasic
    end

    class UserSafe < Grape::Entity
      expose :name
    end

    class UserLogin < UserBasic
      expose :private_token
    end

    class Attachment < Grape::Entity
      expose :id, :file_name
      expose :file_size
      expose :image
      expose :url do |attachment|
        attachment.storage.url
      end
    end

    class Post < Grape::Entity
      expose :id, :title, :body, :body_html, :created_at
      expose :author, using: Entities::UserBasic
      expose :attachments, using: Entities::Attachment
    end

    class OrganizationBasic < Grape::Entity
      expose :id, :name, :parent_id, :created_at
      expose :avatar do |organization|
        organization.avatar.url
      end
    end

    class ReceiptBasic < Grape::Entity
      expose :id, :read
      expose :favorited do |receipt, options|
        receipt.user.favorites.where(favoriteable_type: 'Receipt',
                                     favoriteable_id: receipt.id).exists? ? true : false
      end
    end
    class ReceiptAdmin < ReceiptBasic
      expose :read_at
      expose :user, using: Entities::UserBasic
    end
    class Receipt < ReceiptBasic
      expose :origin
      expose :organizations, using: Entities::OrganizationBasic
      expose :post, using: Entities::Post
    end

    class Comment < Grape::Entity
      expose :id, :body, :created_at
      expose :user, using: Entities::UserBasic
    end

    class Favorite < Grape::Entity
      expose :id, :created_at, :favoriteable_type, :favoriteable_id
      expose :user, using: Entities::UserBasic
    end

    class Input < Grape::Entity
      expose :id, :_type, :label, :help_text, :required, :identifier, :position
      # text_field
      # text_area
      # number_field
      expose :default_value
      # radio_button
      # check_box
      expose :options
    end

    class Form < Grape::Entity
      expose :id, :title, :created_at
      expose :inputs, using: Entities::Input
    end

  end
end
