defmodule ChronoPulse.OpenAIClient do
  use Tesla

  @base_url "https://api.openai.com/v1"

  # 🔑 Hardcode your key for testing (replace with your real key)
  @api_key ""

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Headers, [
    {"Authorization", "Bearer #{@api_key}"},
    {"Content-Type", "application/json"}
  ]
  plug Tesla.Middleware.JSON

  def chat(messages) when is_list(messages) do
    body = %{
      model: "gpt-3.5-turbo",
      messages: messages
    }

    post("/chat/completions", body)
  end
end
