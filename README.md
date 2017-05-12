# Atadura

**Helper tiny module to provide easy binding support as `bind_quoted` does for `quote do`.**

## Installation

```elixir
def deps do
  [{:atadura, "~> 0.1"}]
end
```

## Usage

The module providing easy binding for meta-generated modules. Use it as:

#### Example

```elixir
require Atadura
Atadura.defmodule Circle, answer: 42, pi: 3.14 do
  def area(radius: r), do: 2.0 * pi * r
end
Circle.area(radius: 2)
#⇒ 12.56
```

_Drawback:_ the compilation of modules, defined with `Atadura` will generate
  warnings like:

    warning: variable "status" does not exist and is being expanded to "status()",
       please use parentheses to remove the ambiguity or change the variable name

I have no idea yet on how to suppress them, besides using `status()` for
calling binded variables. Sorry for that.

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

#### Examples

```elixir
defmodule WithBinding do
  require Atadura
  Atadura.defmodule DynamicModule, status: :ok, message: "¡Yay!" do
    def response, do: [status: status, message: message]

    IO.inspect message, label: "Message (local)"
#⇒         Message (local): "¡Yay!"
    IO.inspect @message, label: "Message (attribute)"
#⇒         Message (attribute): "¡Yay!"
    IO.inspect ~b|status message|, label: "Message (sigil)"
#⇒         Message (sigil): [:ok, "¡Yay!"]
  end
end

WithBinding.DynamicModule.Response
#⇒ [status: :ok, message: "¡Yay!"]
```

#### Populating attributes:

```elixir
require WithBinding.DynamicModule.Bindings
#⇒ WithBinding.DynamicModule.Bindings
WithBinding.DynamicModule.Bindings.bindings!
#⇒ [:ok, "¡Yay!"]
status
#⇒ :ok
```

## Documentation

The docs, although everything is written above in this `README`, can
be found at [https://hexdocs.pm/atadura](https://hexdocs.pm/atadura).
