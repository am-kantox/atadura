#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Atadura.Binder do
  @moduledoc false

  defmacro __using__(bindings) do
    [
      quote do
        bindings = unquote(bindings)
        defmacro __using__(_opts \\ []) do
          module = __MODULE__
          quote do
            require unquote(module), as: Bindings
            import unquote(module)
            # Bindings.bindings!
            Bindings.attributes!

            Module.add_doc(__MODULE__, 0, :def, {:version, 0}, [],
              ~s"""
              Returns a binding for this module, supplied when it was created.
              This module #{__MODULE__} was created with the following binding:

                  #{inspect Bindings.bindings}

              Enjoy!
              """)
            def bindings, do: Bindings.bindings
          end
        end
        defmacro bindings, do: unquote(bindings)
        defmacro bindings! do
          Enum.map(unquote(bindings), fn {attr, val} ->
            {:=, [], [{attr, [], nil}, val]}
          end)
        end
        defmacro attributes!() do
          Enum.map(unquote(bindings), fn {attr, val} ->
            quote do
              Module.register_attribute(__MODULE__, unquote(attr), accumulate: false)
              Module.put_attribute(__MODULE__, unquote(attr), unquote(val))
            end
          end)
        end
        defmacro sigil_b(keys, _modifiers) do
          bindings = unquote(bindings)
          {:<<>>, _, [key]} = keys
          case String.split(key, ~r/\s+/) do
            [key] when is_binary(key) ->
              quote do: unquote(bindings)[String.to_atom(unquote(key))]
            keys when is_list(keys) ->
              Enum.map(keys, fn key ->
                with bindings <- unquote(bindings),
                 do: quote do: unquote(bindings)[String.to_atom(unquote(key))]
              end)
          end
        end
      end |

      Enum.map(bindings, fn {attr, val} ->
        quote do
          def unquote(attr)(), do: unquote(val)
        end
      end)
    ]
  end
end
