defmodule Homeview.GenerateImage do
  use Oban.Worker, queue: :events, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id} = _args}) do
    alternative = Homeview.Polls.get_poll_alternative(id)

    try do
      case alternative.status do
        "generating" ->
          %{data: image_data, prompt: prompt} = Homeview.OpenAI.generate_image(alternative.text)

          Homeview.Polls.update_poll_alternative(alternative, %{
            image_url: image_data,
            prompt: prompt,
            status: "success",
            is_ready: true
          })

        "success" ->
          IO.inspect(alternative)

        "failed" ->
          IO.inspect(alternative)
      end
    rescue
      e ->
        # Set model to taailed
        dbg(e)
        Homeview.Polls.update_poll_alternative(alternative, %{status: "failed"})
    after
      Homeview.GeneratePubsub.broadcast_updated()
      :ok
    end
  end
end
