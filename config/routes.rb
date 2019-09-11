Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "graphql#execute"
  end

  post "/graphql", to: "graphql#execute"
  post '/chatkit_auth', to: 'chatkit_auth#create'
  get '/chatkit_auth', to: 'chatkit_auth#show'
end
