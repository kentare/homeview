defmodule Homeview.OpenAI do
  # Import the configuration
  # Get the OpenAI API key from the configuration
  @openai_api_key Application.compile_env!(:homeview, :openai_api_key)

  @system_prompt "This GPT generates prompts that will be used with DALL-E based on user-provided movie plots or descriptive text. It focuses on creating the most relevant and impactful visual representation possible while adhering to OpenAI'\''s content policies. If the provided plot contains restricted content, the GPT will automatically filter those parts and generate an image based on the allowable details. The goal is to ensure that users receive a visually accurate and engaging image without unnecessary restrictions. The returned image should be directly aligned with the allowable aspects of the provided description. Write your output in json with a single key called \"prompt\"."

  #   curl https://api.openai.com/v1/chat/completions \
  #   -H "Content-Type: application/json" \
  #   -H "Authorization: Bearer $OPENAI_API_KEY" \
  #   -d '{
  #   "model": "gpt-4o-mini",
  #   "messages": [
  #     {
  #       "role": "system",
  #       "content": [
  #         {
  #           "type": "text",
  #           "text": "This GPT generates prompts that will be used with DALL-E based on user-provided movie plots or descriptive text. It focuses on creating the most relevant and impactful visual representation possible while adhering to OpenAI'\''s content policies. If the provided plot contains restricted content, the GPT will automatically filter those parts and generate an image based on the allowable details. The goal is to ensure that users receive a visually accurate and engaging image without unnecessary restrictions. The returned image should be directly aligned with the allowable aspects of the provided description. Write your output in json with a single key called \"prompt\"."
  #         }
  #       ]
  #     }
  #   ],
  #   "temperature": 0.82,
  #   "max_tokens": 386,
  #   "top_p": 1,
  #   "frequency_penalty": 0,
  #   "presence_penalty": 0,
  #   "response_format": {
  #     "type": "json_object"
  #   }
  # }'

  # returns
  # %Req.Response{
  #   status: 200,
  #   headers: [
  #     {"date", "Fri, 30 Aug 2024 14:07:44 GMT"},
  #     {"content-type", "application/json"},
  #     {"transfer-encoding", "chunked"},
  #     {"connection", "keep-alive"},
  #     {"access-control-expose-headers", "X-Request-ID"},
  #     {"openai-organization", "user-eqonb2yjzm4skpg6zinqemuf"},
  #     {"openai-processing-ms", "821"},
  #     {"openai-version", "2020-10-01"},
  #     {"strict-transport-security",
  #      "max-age=15552000; includeSubDomains; preload"},
  #     {"x-ratelimit-limit-requests", "10000"},
  #     {"x-ratelimit-limit-tokens", "200000"},
  #     {"x-ratelimit-remaining-requests", "9999"},
  #     {"x-ratelimit-remaining-tokens", "199381"},
  #     {"x-ratelimit-reset-requests", "8.64s"},
  #     {"x-ratelimit-reset-tokens", "185ms"},
  #     {"x-request-id", "req_f474d9ab0b8f65c20a0cc2ec28e38ae8"},
  #     {"cf-cache-status", "DYNAMIC"},
  #     {"set-cookie",
  #      "__cf_bm=vET7XDxOR2SPYDL.5NPrRmgtHtETtchgyPbEMV6aeQ8-1725026864-1.0.1.1-PFbDgUqabYWGe.c.cUWdyayPXnC5F6bJsbEXYAiAdZmMphiJ3sHmnTyy5FegyC1ih.2ocFn441c.9VHxmefbhQ; path=/; expires=Fri, 30-Aug-24 14:37:44 GMT; domain=.api.openai.com; HttpOnly; Secure; SameSite=None"},
  #     {"x-content-type-options", "nosniff"},
  #     {"set-cookie",
  #      "_cfuvid=y_B6jhVcYCfZ.U9gPP.OEyHY1SzjHFrIcdXfL3CWqQk-1725026864202-0.0.1.1-604800000; path=/; domain=.api.openai.com; HttpOnly; Secure; SameSite=None"},
  #     {"server", "cloudflare"},
  #     {"cf-ray", "8bb559447d91569a-OSL"},
  #     {"content-encoding", "gzip"},
  #     {"alt-svc", "h3=\":443\"; ma=86400"}
  #   ],
  #   body: %{
  #     "choices" => [
  #       %{
  #         "finish_reason" => "stop",
  #         "index" => 0,
  #         "logprobs" => nil,
  #         "message" => %{
  #           "content" => "{\n  \"prompt\": \"A group of diverse friends gathered around an old wooden table in a dimly lit room, with an embalmed hand placed in the center, surrounded by candles casting flickering shadows. The atmosphere is tense and mysterious, with ghostly wisps emanating from the hand, hinting at the connection to the spirit world. Each friend's expression ranges from excitement to fear, showcasing the thrill and danger of their discovery.\"\n}",
  #           "refusal" => nil,
  #           "role" => "assistant"
  #         }
  #       }
  #     ],
  #     "created" => 1725026863,
  #     "id" => "chatcmpl-A1wZrNFP1cx1h6VCvDyox75nJBYk2",
  #     "model" => "gpt-4o-mini-2024-07-18",
  #     "object" => "chat.completion",
  #     "system_fingerprint" => "fp_f33667828e",
  #     "usage" => %{
  #       "completion_tokens" => 89,
  #       "prompt_tokens" => 182,
  #       "total_tokens" => 271
  #     }
  #   },
  #   private: %{}
  # }
  defp generate_image_prompt(base_prompt) do
    response =
      Req.post!("https://api.openai.com/v1/chat/completions",
        json: %{
          model: "gpt-4o-mini",
          messages: [
            %{
              role: "system",
              content: @system_prompt
            },
            %{
              role: "user",
              content: base_prompt
            }
          ],
          temperature: 0.82,
          max_tokens: 1500,
          top_p: 1,
          frequency_penalty: 0,
          presence_penalty: 0,
          response_format: %{
            type: "json_object"
          }
        },
        headers: [{"Authorization", "Bearer #{@openai_api_key}"}]
      )

    dbg(response)

    extract_prompt(response)
  end

  defp extract_prompt(response) do
    response.body
    |> Map.get("choices")
    |> List.first()
    |> Map.get("message")
    |> Map.get("content")
    |> Jason.decode!()
    |> Map.get("prompt")
  end

  # body: %{
  #   "created" => 1725027258,
  #   "data" => [
  #     %{
  #       "b64_json" => "iVBORw0KGgoAAAANSUhEUgAABAAAAAQACAIAAADwf7zUAAA552NhQlgAADnnanVtYgAAAB5qdW1kYzJwYQARABCAAACqADibcQNjMnBhAAAAOcFqdW1iAAAAR2p1bWRjMm1hABEAEIAAAKoAOJtxA3Vybjp1dWlkOjUwYmI1ZDViLWM2MTktNDI5MS1iM2MwLTI0MTgxZjc2NzEzMwAAAAGhanVtYgAAAClqdW1kYzJhcwARABCAAACqADibcQNjMnBhLmFzc2VydGlvbnMAAAAAxWp1bWIAAAAmanVtZGNib3IAEQAQgAAAqgA4m3EDYzJwYS5hY3Rpb25zAAAAAJdjYm9yoWdhY3Rpb25zgaNmYWN0aW9ubGMycGEuY3JlYXRlZG1zb2Z0d2FyZUFnZW50Z0RBTEzCt0VxZGlnaXRhbFNvdXJjZVR5cGV4Rmh0dHA6Ly9jdi5pcHRjLm9yZy9uZXdzY29kZXMvZGlnaXRhbHNvdXJjZXR5cGUvdHJhaW5lZEFsZ29yaXRobWljTWVkaWEAAACranVtYgAAAChqdW1kY2JvcgARABCAAACqADibcQNjMnBhLmhhc2guZGF0YQAAAAB7Y2JvcqVqZXhjbHVzaW9uc4GiZXN0YXJ0GCFmbGVuZ3RoGTnzZG5hbWVuanVtYmYgbWFuaWZlc3RjYWxnZnNoYTI1NmRoYXNoWCAju6Xez0vjbDKiyfwdfxw31/GoIgrBOjk8rrvntfA5SGNwYWRIAAAAAAAAAAAAAAG4anVtYgAAACRqdW1kYzJjbAARABCAAACqADibcQNjMnBhLmNsYWltAAAAAYxjYm9yqGhkYzp0aXRsZWlpbWFnZS5wbmdpZGM6Zm9ybWF0Y3BuZ2ppbnN0YW5jZUlEeCx4bXA6aWlkOjk1ZGIyNzNmLWUzZTQtNGUwZi04MmQ0LWQ2YWMyMGFhOTg2ZW9jbGFpbV9nZW5lcmF0b3J4GU9wZW5BSS1BUEkgYzJwYS1ycy8wLjMxLjN0Y2xhaW1fZ2VuZXJhdG9yX2luZm/2aXNpZ25hdHVyZXgZc2VsZiNqdW1iZj1jMnBhLnNpZ25hdHVyZWphc3NlcnRpb25zgqJjdXJseCdzZWxmI2p1bWJmPWMycGEuYXNzZXJ0aW9ucy9jMnBhLmFjdGlvbnNkaGFzaFggz2QVQL7UdSqOcHabj50Z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" <> ...,
  #       "revised_prompt" => "A diverse group of friends, each of varying descents such as Caucasian, Hispanic, Black, Middle-Eastern, and South Asian, are gathered around a table situated in a dimly lit room. Their focus is deeply concentrated on an embalmed hand placed in the heart of the table. The room is filled with eerie shadows that play tricks on the wall, indicative of uncanny elements. The friends display a mix of reactions - some bubble with excitement, while others wear expressions of apprehension, together building a tense ambience. Suggestive traces of spirits, like ethereal wisps of light or vague silhouettes, grace the background, acting as a critical symbol of the thin line dividing the world of the living and the departed."
  #     }
  #   ]
  # },
  # private: %{}
  defp generate_image_data(prompt) do
    Req.post!("https://api.openai.com/v1/images/generations",
      json: %{
        model: "dall-e-3",
        prompt: prompt,
        n: 1,
        size: "1024x1024",
        response_format: "b64_json"
      },
      headers: [{"Authorization", "Bearer #{@openai_api_key}"}],
      receive_timeout: 60000
    )
  end

  @spec extract_image_data(Req.Response.t()) :: %{data: String.t(), prompt: String.t()}
  defp extract_image_data(response) do
    data =
      response.body
      |> Map.get("data")
      |> List.first()
      |> Map.get("b64_json")

    %{
      data: "data:image/jpeg;charset=utf-8;base64," <> data,
      prompt: response.body |> Map.get("revised_prompt")
    }
  end

  @spec generate_image(String.t()) :: %{data: String.t(), prompt: String.t()}
  def generate_image(prompt) do
    prompt
    |> generate_image_prompt()
    |> generate_image_data()
    |> extract_image_data()
  end
end
