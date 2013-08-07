class UserController < ApplicationController
  def organizations
    organizations = current_user.organizations
    render json: organizations, each_serializer: AuthorizedOrganizationSerializer, root: :organizations    
  end

  def update
    if current_user.update_attributes params[:user]
      render json: current_user, serializer: UserSerializer, root: :user
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end
  
  def show
    render json: current_user, serializer: UserSerializer, root: :user
  end
  
  def created_receipts
    created_receipts = current_user.receipts.where(origin: true)
    render json: created_receipts, serialize: ReceiptSerializer, root: :created_receipts
  end
  def favorited_receipts
    favorited_receipts = current_user.favorites.receipts.map(&:favoriteable)
    render json: favorited_receipts, serialize: ReceiptSerializer, root: :favorited_receipts
  end
end