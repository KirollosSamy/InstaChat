Rails.application.routes.draw do
  # Unfortunately, it's not possible to use resources here
  
  get '/applications', to: 'applications#index'
  post '/applications', to: 'applications#create'
  put '/applications/:app_token', to: 'applications#update'

  get '/applications/:app_token/chats', to: 'chats#index'
  put '/applications/:app_token/chats/:chat_num', to: 'chats#update'

  get '/applications/:app_token/chats/:chat_num/messages', to: 'messages#index'
  put '/applications/:app_token/chats/:chat_num/messages/:message_num', to: 'messages#update'

  get '/applications/:app_token/chats/:chat_num/messages/search', to: 'messages#search'
end