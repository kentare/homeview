defmodule Homeview.Transport.StopsTest do
  use Homeview.DataCase
  alias Homeview.Transport.Stops
  alias Homeview.Transport.SingleStop

  describe "extract_data" do
    test "extract single data point" do
      data = %{
        "actualDepartureTime" => nil,
        "aimedDepartureTime" => "2023-05-12T08:53:00+02:00",
        "cancellation" => false,
        "destinationDisplay" => %{"frontText" => "Mortensrud"},
        "expectedDepartureTime" => "2023-05-12T08:53:00+02:00",
        "quay" => %{
          "id" => "NSR:Quay:6824",
          "publicCode" => "1",
          "stopPlace" => %{
            "id" => "NSR:StopPlace:3808",
            "parent" => %{"id" => "NSR:StopPlace:58281"}
          }
        },
        "realtime" => true,
        "serviceJourney" => %{
          "id" => "RUT:ServiceJourney:3-173790-25022732",
          "line" => %{
            "id" => "RUT:Line:3",
            "publicCode" => "3",
            "transportMode" => "metro"
          }
        }
      }

      expected = %SingleStop{
        number: "3",
        platformNumber: "1",
        displayName: "Mortensrud",
        aimedDepartureTime: "2023-05-12T08:53:00+02:00",
        expectedDepartureTime: "2023-05-12T08:53:00+02:00",
        cancelled: false,
        mode: "metro"
      }

      assert Stops.extract_single_data_point(data) == expected
    end

    test "Extract all data points" do
      data = [
        %{
          "actualDepartureTime" => nil,
          "aimedDepartureTime" => "2023-05-12T08:53:00+02:00",
          "cancellation" => false,
          "destinationDisplay" => %{"frontText" => "Mortensrud"},
          "expectedDepartureTime" => "2023-05-12T08:53:00+02:00",
          "quay" => %{
            "id" => "NSR:Quay:6824",
            "publicCode" => "1",
            "stopPlace" => %{
              "id" => "NSR:StopPlace:3808",
              "parent" => %{"id" => "NSR:StopPlace:58281"}
            }
          },
          "realtime" => true,
          "serviceJourney" => %{
            "id" => "RUT:ServiceJourney:3-173790-25022732",
            "line" => %{
              "id" => "RUT:Line:3",
              "publicCode" => "3",
              "transportMode" => "metro"
            }
          }
        },
        %{
          "actualDepartureTime" => nil,
          "aimedDepartureTime" => "2023-05-12T08:57:00+02:00",
          "cancellation" => false,
          "destinationDisplay" => %{"frontText" => "Gullhaug"},
          "expectedDepartureTime" => "2023-05-12T08:57:00+02:00",
          "quay" => %{
            "id" => "NSR:Quay:6814",
            "publicCode" => "D",
            "stopPlace" => %{
              "id" => "NSR:StopPlace:3805",
              "parent" => %{"id" => "NSR:StopPlace:58281"}
            }
          },
          "realtime" => true,
          "serviceJourney" => %{
            "id" => "RUT:ServiceJourney:150-182133-26994899",
            "line" => %{
              "id" => "RUT:Line:150",
              "publicCode" => "150",
              "transportMode" => "bus"
            }
          }
        }
      ]

      expected = [
        %SingleStop{
          number: "3",
          platformNumber: "1",
          displayName: "Mortensrud",
          aimedDepartureTime: "2023-05-12T08:53:00+02:00",
          expectedDepartureTime: "2023-05-12T08:53:00+02:00",
          cancelled: false,
          mode: "metro"
        },
        %SingleStop{
          number: "150",
          platformNumber: "D",
          displayName: "Gullhaug",
          aimedDepartureTime: "2023-05-12T08:57:00+02:00",
          expectedDepartureTime: "2023-05-12T08:57:00+02:00",
          cancelled: false,
          mode: "bus"
        }
      ]

      assert Stops.extract_data_points(data) == expected
    end

    test "Filter by platform number" do
      data = [
        %SingleStop{
          number: "3",
          platformNumber: "1",
          displayName: "Mortensrud",
          aimedDepartureTime: "2023-05-12T08:53:00+02:00",
          expectedDepartureTime: "2023-05-12T08:53:00+02:00",
          cancelled: false,
          mode: "metro"
        },
        %SingleStop{
          number: "150",
          platformNumber: "D",
          displayName: "Gullhaug",
          aimedDepartureTime: "2023-05-12T08:57:00+02:00",
          expectedDepartureTime: "2023-05-12T08:57:00+02:00",
          cancelled: false,
          mode: "bus"
        }
      ]

      expected = [
        %SingleStop{
          number: "3",
          platformNumber: "1",
          displayName: "Mortensrud",
          aimedDepartureTime: "2023-05-12T08:53:00+02:00",
          expectedDepartureTime: "2023-05-12T08:53:00+02:00",
          cancelled: false,
          mode: "metro"
        }
      ]

      data = Stops.filter_by_platform_numbers(data, ["1"])

      assert data == expected
    end
  end
end

#  %{
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
#      %{
#        "actualDepartureTime" => nil,
#        "aimedDepartureTime" => "2023-05-12T08:57:00+02:00",
#        "cancellation" => false,
#        "destinationDisplay" => %{"frontText" => "Gullhaug"},
#        "expectedDepartureTime" => "2023-05-12T08:57:00+02:00",
#        "quay" => %{
#          "id" => "NSR:Quay:6814",
#          "publicCode" => "D",
#          "stopPlace" => %{
#            "id" => "NSR:StopPlace:3805",
#            "parent" => %{"id" => "NSR:StopPlace:58281"}
#          }
#        },
#        "realtime" => true,
#        "serviceJourney" => %{
#          "id" => "RUT:ServiceJourney:150-182133-26994899",
#          "line" => %{
#            "id" => "RUT:Line:150",
#            "publicCode" => "150",
#            "transportMode" => "bus"
#          }
#        }
#      },
