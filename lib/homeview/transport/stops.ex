defmodule Homeview.Transport.SingleStop do
  defstruct [
    :number,
    :platformNumber,
    :displayName,
    :aimedDepartureTime,
    :expectedDepartureTime,
    :cancelled,
    :mode
  ]
end

defmodule Homeview.Transport.Stops do
  alias Homeview.Transport.SingleStop
  use Timex
  # I want this structure:
  # number, platformNumber, displayName, aimedDepartureTime, expectedDepartureTime, cancelled, mode

  # This is the data I get:
  # %{
  #        "actualDepartureTime" => nil,
  #        "aimedDepartureTime" => "2023-05-12T08:53:00+02:00",
  #        "cancellation" => false,
  #        "destinationDisplay" => %{"frontText" => "Mortensrud"},
  #        "expectedDepartureTime" => "2023-05-12T08:53:00+02:00",
  #        "quay" => %{
  #          "id" => "NSR:Quay:6824",
  #          "publicCode" => "1",
  #          "stopPlace" => %{
  #            "id" => "NSR:StopPlace:3808",
  #            "parent" => %{"id" => "NSR:StopPlace:58281"}
  #          }
  #        },
  #        "realtime" => true,
  #        "serviceJourney" => %{
  #          "id" => "RUT:ServiceJourney:3-173790-25022732",
  #          "line" => %{
  #            "id" => "RUT:Line:3",
  #            "publicCode" => "3",
  #            "transportMode" => "metro"
  #          }
  #        }
  #      },

  def fetch_data() do
    req =
      Req.post!("https://api.entur.io/journey-planner/v3/graphql",
        json: %{
          query:
            "fragment estimatedCallsParts on EstimatedCall {\n      realtime\n      cancellation\n      serviceJourney {\n        id\n      }\n      destinationDisplay {\n        frontText\n      }\n      quay {\n        publicCode\n        id\n        stopPlace {\n          parent {\n            id\n          }\n          id\n        }\n      }\n      expectedDepartureTime\n      actualDepartureTime\n      aimedDepartureTime\n      serviceJourney {\n        id\n        line {\n          id\n          publicCode\n          transportMode\n        }        \n      }\n} query {bekkestua: stopPlaces(ids: [\"NSR:StopPlace:58281\"]) {\n    name\n    estimatedCalls(whiteListedModes: [rail,metro,tram,water], numberOfDepartures: 200, arrivalDeparture: departures, includeCancelledTrips: true, timeRange: 14400) {\n      ...estimatedCallsParts\n    }\n  } }"
        },
        headers: [{"ET-Client-Name", "kentare_homeview-dashboard"}]
      )

    req.body["data"]["bekkestua"] |> List.first() |> Map.get("estimatedCalls")
  end

  def extract_data_points(data) do
    data
    |> Enum.map(&extract_single_data_point/1)
  end

  def extract_single_data_point(%{
        "aimedDepartureTime" => aimedDepartureTime,
        "cancellation" => cancellation,
        "destinationDisplay" => %{"frontText" => name},
        "expectedDepartureTime" => expectedDepartureTime,
        "quay" => %{
          "publicCode" => platformNumber
        },
        "serviceJourney" => %{
          "line" => %{
            "publicCode" => number,
            "transportMode" => mode
          }
        }
      }) do
    %SingleStop{
      number: number,
      platformNumber: platformNumber,
      displayName: name,
      aimedDepartureTime: aimedDepartureTime,
      expectedDepartureTime: format_time(expectedDepartureTime),
      # expectedDepartureTime: expectedDepartureTime,
      cancelled: cancellation,
      mode: mode
    }
  end

  def format_time(time) do
    time
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.diff(DateTime.utc_now(), :seconds)
    |> case do
      x when x < 60 -> "Nå"
      x when x < 600 -> "#{x |> div(60)} min"
      _ -> format(time)
    end
  end

  def add_zero_to_time(time) do
    if time < 10 do
      "0#{time}"
    else
      time
    end
  end

  def format(datetime_string) do
    [_, time_string] = String.split(datetime_string, "T")
    [hour_string, minute_string | _] = String.split(time_string, ":")
    hour = String.to_integer(hour_string) |> add_zero_to_time()
    minute = String.to_integer(minute_string) |> add_zero_to_time()

    formatted_time = "#{hour}:#{minute}"

    formatted_time
  end

  def filter_by_platform_numbers(data, platform_numbers) do
    data
    |> Enum.filter(fn stop ->
      stop.platformNumber in platform_numbers
    end)
  end
end
