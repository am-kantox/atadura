#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

defmodule Atadura do
  @moduledoc """
  The module providing easy binding for meta-generated modules. Use it as:

  ## Example

      > require Atadura
      > Atadura.defmodule Circle, answer: 42, pi: 3.14 do
      >   def area(radius: r), do: 2.0 * pi * r
      > end
      > Circle.area(radius: 2)
      #⇒ 12.56

  _Drawback:_ the compilation of modules, defined with `Atadura` will generate
    warnings like:

      warning: variable "status" does not exist and is being expanded to "status()",
         please use parentheses to remove the ambiguity or change the variable name

  I have no idea yet on how to suppress them, besides using `status()` for
  calling binded variables. Sorry for that.
  """

  @bindings :Bindings

  @doc """
  To create a module with bindings, use `Atadura.defmodule` in place of
    plain old good `defmodule`. Whatever is passed as second parameter keyword
    list, will be available in the generated module in three different ways:

  - as local functions,
  - as module variables,
  - as `~b||` sigil.

  The module will be granted with `bindings` function, returning
    all the bindings as a keyword list.

  Also, a “nested” module will be created for the generated module. It is named
  `Parent.Module.FQName.Bindings`, and is exporting following macros:

  - `bindings!` to populate the bindings as local variables in the current context
  - `attributes!` to populate the bindings as module attributes in the current
    context (_NB:_ this macro is internally called to populate module attributes
    in the newly created module).

  ## Examples

      > defmodule WithBinding do
      >   require Atadura
      >   Atadura.defmodule DynamicModule, status: :ok, message: "¡Yay!" do
      >     def response, do: [status: status, message: message]
      >
      >     IO.inspect message, label: "Message (local)"
      #⇒         Message (local): "¡Yay!"
      >     IO.inspect @message, label: "Message (attribute)"
      #⇒         Message (attribute): "¡Yay!"
      >     IO.inspect ~b|status message|, label: "Message (sigil)"
      #⇒         Message (sigil): [:ok, "¡Yay!"]
      >   end
      > end

      > WithBinding.DynamicModule.Response
      #⇒ [status: :ok, message: "¡Yay!"]

  ## Populating attributes:

      > require WithBinding.DynamicModule.Bindings
      #⇒ WithBinding.DynamicModule.Bindings
      > WithBinding.DynamicModule.Bindings.bindings!
      #⇒ [:ok, "¡Yay!"]
      > status
      #⇒ :ok
  """
  defmacro defmodule(name, bindings \\ [], do_block)

  defmacro defmodule(name, [], do: block) do
    quote do: Kernel.defmodule(unquote(name), do: unquote(block))
  end

  defmacro defmodule(name, [], bindings_and_do) do
    block = Keyword.get(bindings_and_do, :do, nil)
    bindings = Keyword.delete(bindings_and_do, :do)
    quote do: Atadura.defmodule(unquote(name), unquote(bindings), do: unquote(block))
  end

  defmacro defmodule(name, bindings, do: block) do
    binding_module = case name do
                       {:__aliases__, line, names} ->
                         {:__aliases__, line,
                            :lists.reverse([@bindings | :lists.reverse(names)])}
                       {_, line, _} ->
                         {expr , _} = Code.eval_quoted(name)
                         {:__aliases__, line,
                            expr |> Module.split |> Enum.map(&String.to_atom/1)}
                     end

    quote do

      defmodule unquote(binding_module) do
        use Atadura.Binder, unquote(bindings)
      end

      defmodule unquote(name) do
        use unquote(binding_module)

        unquote(block)
      end

    end
  end
end
