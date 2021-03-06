module Youxin
  module APIHelpers
    def current_user
      @current_user ||= User.where(authentication_token: params[:private_token] || env["HTTP_PRIVATE_TOKEN"]).first
    end

    def current_namespace
      begin
        current_user.namespace
      rescue
        unauthorized!
      end
    end

    def warden
      env['warden']
    end

    def authenticate!
      unauthorized! unless current_user
    end
    def authorize! action, subject
      unless abilities.allowed?(current_user, action, subject)
        forbidden!
      end
    end
    def bulk_authorize! action, subjects
      subjects.each do |subject|
        authorize!(action, subject)
      end
    end
    def authenticated_as_attachmentable
      if current_user.authorized_organizations([:create_youxin]).blank?
        forbidden!
      end
    end
    def can?(object, action, subject)
      abilities.allowed?(object, action, subject)
    end
    def current_user_can?(action, subject)
      abilities.allowed?(current_user, action, subject)
    end

    def paginate(objects)
      per_page = (params[:per_page] || Kaminari.config.default_per_page).to_i
      page = (params[:page] || 1).to_i
      since_id = params[:since_id]
      max_id = params[:max_id]
      objects = objects.gt(_id: since_id) if since_id
      objects = objects.lt(_id: max_id) if max_id
      objects.page(page).per(per_page)
    end

    # Checks the occurrences of required attributes, each attribute must be present in the params hash
    # or a Bad Request error is invoked.
    #
    # Parameters:
    #   keys (required) - A hash consisting of keys that must be present
    def required_attributes!(keys)
      keys.each do |key|
        bad_request!(key) unless params[key].present?
      end
    end

    def attributes_for_keys(keys)
      attrs = {}
      keys.each do |key|
        attrs[key] = params[key] if params[key].present?
      end
      attrs
    end

    # errors
    def forbidden!
      render_api_error!('403 Forbidden', 403)
    end
    def render_api_error!(message, status)
      error!({'message' => message}, status)
    end
    def unauthorized!
      render_api_error!('401 Unauthorized', 401)
    end
    def bad_request!(attribute)
      message = ["400 (Bad request)"]
      message << "\"" + attribute.to_s + "\" not given"
      render_api_error!(message.join(' '), 400)
    end
    def not_found!(resource = nil)
      message = ["404"]
      message << resource if resource
      message << "Not Found"
      render_api_error!(message.join(' '), 404)
    end
    def fail!(errors = nil)
      if errors
        messages = errors.messages
      else
        messages = { message: 'failure' }
      end
      error!(messages, 400)
    end

    private

    def abilities
      @abilities ||= begin
                       abilities = Six.new
                       abilities << UserActionsOrganizationRelationship
                       abilities << Post
                       abilities << Attachment::Base
                       abilities << Conversation
                       abilities << Form
                       abilities << Namespace
                       abilities << User
                       abilities
                     end
    end
  end
end
