class HomeController < ApplicationController
  skip_before_filter :authenticate_user!, except: [:index]

  def index
  end
  def privacy
    render layout: 'features'
  end
  def terms
    render layout: 'features'
  end

  def app
    render layout: 'mobile'
  end
end
