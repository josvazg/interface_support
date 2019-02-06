# Explicit Interface Support for Ruby

Comming from other languages with explicit interface support of some kind you might be missing it in your Ruby code. Or maybe you just want to improve readability, separation of concerns and isolation by enforcing more formal interfaces.

**Then this might be what you are looking for!**

## How to use

This **InterfaceSupport** module allows you to write Interface specifications in code like this:

```ruby
# Doc string goes here...
module ServiceWhatever
  extend InterfaceSupport::Interface

  # method_one doc string goes here
  def method_one; end

  # method_two doc string here
  def method_two(arg1, arg2); end
end
```

Interfaces are modules that extend **InterfaceSupport::interface**:
```ruby
module AnInterface
  extend InterfaceSupport::Interface
...
```

Or interfaces could include other interfaces:
```ruby
module CompositedInterface
  include AnInterface
...
```
* No need to also extend **InterfaceSupport::interface**.
* And **CompositedInterface** includes all methods from included interfaces plus the ones defined by it, if any.

Apart from allowing you to ***declare intentions*** in code, that would not be too useful without a way to also ***enforce them***. For that you have 2 helper methods within **InterfaceSupport::interface**:

```ruby
def implements(obj, interface)
...
def implements?(obj, interface)
```
The ***implements*** helper is an assertion that only succeeds when the passed object instance **obj** implements ALL methods defined in **interface**. That includes not just having the right method name, but also the right signature for parameters. If there are any violations to the interface, an exception is raised explaining all issues found. It can be used in unit tests or whenever the code following the assert expects **obj** will honor **interface**.

The ***implements?*** helper is a test that will return ***true*** ONLY if the passed object instance **obj** implements ALL defined in **interface** methods with correct signatures. It can be used to decide to use an **interface** on **obj** or not.

## Rationale

**InterfaceSupport** brings Go-like interfaces to Ruby, rather than other styles like Java Interfaces. The reasons are many:
* Go style interfaces play better with Ruby natural duck-typing.
* You don't need to pollute the code inheritance tree further with references to Interfaces.
* Not having to explicitly include in the definition that a class implements an interface allows to use interfaces discovered after the fact, without having to change code, specially if that code is from a 3rd party library.

Adding matching interface definition and calling implements is all it takes to start documenting and enforcing a particular interface.
