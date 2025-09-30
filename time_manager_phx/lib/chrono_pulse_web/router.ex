defmodule ChronoPulseWeb.Router do
  use ChronoPulseWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ChronoPulseWeb do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
    # WorkingTime routes per PDF
    get "/workingtime/:user_id", WorkingTimeController, :index
    get "/workingtime/:user_id/:id", WorkingTimeController, :show
    post "/workingtime/:user_id", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete
    # Clocks as per PDF
    get "/clocks/:user_id", ClockController, :index
    post "/clocks/:user_id", ClockController, :create

    # Charts
    get "/charts/hours", ChartsController, :total_hours
    get "/charts/user/:user_id/hours", ChartsController, :user_hours
    get "/charts/user/:user_id/sessions", ChartsController, :user_sessions
    get "/charts/user/:user_id/breaks", ChartsController, :user_breaks
    post "/complaints", UserComplaintController, :create
    post "/chat", ChatController, :create
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:chrono_pulse, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
