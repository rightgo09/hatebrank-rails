class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # protect_from_forgery with: :exception

  before_action do |controller|
    $is_from_smartphone = request.from_smartphone?
  end
end
