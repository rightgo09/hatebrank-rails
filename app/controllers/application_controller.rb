class ApplicationController < ActionController::Base
  before_action do |controller|
    $is_from_smartphone = request.from_smartphone?
  end
end
