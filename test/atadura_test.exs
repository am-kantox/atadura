#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Atadura.Test do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Atadura

  test "scoping with modules" do
    status = :ok
    message = "¡Yay!"
    assert_raise(CompileError, ~r|undefined function|, fn ->
      defmodule WithoutBinding do
        @moduledoc false
        def response, do: [status: status, message: message]
      end
    end)
  end

  test "locals, attributes, sigils" do
    assert capture_io(fn ->
      defmodule WithBinding do
        @moduledoc false
        require Atadura
        Atadura.defmodule Test, status: :ok, message: "¡Yay!" do
          def response, do: [status: status, message: message]

          IO.inspect "#{status}: #{message}", label: "Message (local)"
          IO.inspect "#{@status}: #{@message}", label: "Message (attribute)"
          IO.inspect ~b|status message|, label: "Message (sigil)"
        end
      end
    end) == "Message (local): \"ok: ¡Yay!\"\nMessage (attribute): \"ok: ¡Yay!\"\nMessage (sigil): [:ok, \"¡Yay!\"]\n"

    assert capture_io(fn ->
      IO.inspect(Atadura.Test.WithBinding.Test.bindings, label: "Bindings")
    end) == "Bindings: [status: :ok, message: \"¡Yay!\"]\n"

    assert Atadura.Test.WithBinding.Test.Bindings.status == :ok
    assert Atadura.Test.WithBinding.Test.Bindings.message == "¡Yay!"
    assert Atadura.Test.WithBinding.Test.response == [status: :ok, message: "¡Yay!"]
  end
end
