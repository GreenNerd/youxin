class Posts < Grape::API
  before { authenticate! }

  resource :posts do
    desc "Create a post."
    post do
      bulk_authorize! :create_youxin, Organization.where(:id.in => params[:organization_ids])
      required_attributes! [:body_html, :organization_ids]

      attrs = attributes_for_keys [:title, :body_html, :organization_ids, :attachment_ids]
      attachment_ids = attrs.delete(:attachment_ids)
      post = current_user.posts.new attrs

      attachments = []
      attachment_ids.each do |attachment_id|
        attachment = Attachment::Base.find(attachment_id)

        not_found!("attachment") unless attachment
        authorize! :manage, attachment

        if attachment.post_id.present?
          post.errors.add :attachment_ids, :inclusion
          fail!(post.errors)
        end
        attachments |= [attachment]
      end if attachment_ids
      if post.save
        attachments.map { |attachment| post.attachments << attachment } if attachments.present?
        present post, with: Youxin::Entities::Post
      else
        fail!(post.errors)
      end
    end

    segment '/:id' do
      resource :forms do
        get do
          post = current_user.receipts.find_by(post_id: params[:id]).try(:post)
          if post
            present post.forms, with: Youxin::Entities::Form
          else
            not_found!
          end
        end
      end
    end

    route_param :id do
      before do
        @post = Post.find(params[:id])
        not_found!("post") unless @post
        authorize! :read, @post
      end
      get do
        present @post, with: Youxin::Entities::Post
      end
      get 'receipts' do
        authorize! :read_receipts, @post
        receipts = paginate @post.receipts.all
        present receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'unread_receipts' do
        authorize! :read_receipts, @post
        unread_receipts = paginate @post.receipts.unread
        present unread_receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'read_receipts' do
        authorize! :read_receipts, @post
        read_receipts = paginate @post.receipts.read
        present read_receipts, with: Youxin::Entities::ReceiptAdmin
      end
      get 'comments' do
        authorize! :read, @post
        comments = paginate @post.comments
        present comments, with: Youxin::Entities::Comment
      end
      post 'comments' do
        authorize! :read, @post
        required_attributes! [:body]
        attrs = attributes_for_keys [:body]
        attrs.merge!({ user_id: current_user.id })
        comment = @post.comments.new attrs
        if comment.save
          present comment, with: Youxin::Entities::Comment
        else
          fail!(comment.errors)
        end
      end
    end

  end
end