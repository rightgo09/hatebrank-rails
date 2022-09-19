Rails.application.routes.draw do
  root 'main#index'
  get 'category' => 'main#category'
end
