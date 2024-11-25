defmodule ExSTARSDemoTest do
  use ExUnit.Case

  import ExSTARSDemo, only: [handle_response: 2]

  test "handle_response/2" do
    response = "System>term1 @gettime 2024-11-25 09:00:00"
    assert handle_response(response, "term1") == {:ok, ~U[2024-11-25 00:00:00Z], 32400}

    response = "Contecnano.ai.ch3>Userapp @GetValue 4.21"
    assert handle_response(response, "Userapp") == 4.21
  end
end
