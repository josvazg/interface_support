require_relative '../lib/interface_support'

# EmptyInterface implemented by anything, as there is no method to implement
module EmptyInterface
  extend InterfaceSupport::Interface
end

# SimpleCall specifies a single method with no args
module SimpleCall
  extend InterfaceSupport::Interface

  def simple_call; end
end

# Simple only implements SimpleCall
class Simple
  def simple_call
    puts 'simple_call !'
  end
end

# Buggy does not properly implement SimpleCall
class Buggy
  def simple_call(arg)
    puts "simple_call #{arg}!"
  end
end

# ComposedCalls interface includes and extends SimpleCall with a complex_call
module ComposedCalls
  include SimpleCall

  def complex_call(arg1, arg2: nil, arg3: false); end
end

# Inherited extends Simple to implement all ComposedCalls methods
class Inherited < Simple
  def complex_call(arg1, arg2: nil, arg3: false)
    puts "complex_call #{arg1} #{arg2} #{arg3}!"
  end
end

# Different has the methods requested by ComposedCalls
# but using different signatures
class Different < Buggy
  def complex_call(arg1)
    puts "complex_call #{arg1}!"
  end
end

describe InterfaceSupport do
  it 'any object implements the empty interface' do
    expect(InterfaceSupport.implements?(Object.new, EmptyInterface)).to eq true
  end

  it 'SimpleImplementation implements SimpleCall' do
    expect(InterfaceSupport.implements?(Simple.new, SimpleCall)).to eq true
  end

  it 'Object does NOT implement SimpleCall' do
    expect(
      InterfaceSupport.implements?(Object.new, SimpleCall)
    ).to eq false
  end

  it 'Buggy does NOT implement SimpleCall' do
    expect(InterfaceSupport.implements?(Buggy.new, SimpleCall)).to eq false
  end

  it 'Inherited implements ComposedCalls' do
    expect(
      InterfaceSupport.implements?(Inherited.new, ComposedCalls)
    ).to eq true
  end

  it 'Inherited ALSO implements SimpleCall' do
    expect(InterfaceSupport.implements?(Inherited.new, SimpleCall)).to eq true
  end

  it 'Simple does NOT implement ComposedCalls' do
    expect(InterfaceSupport.implements?(Simple.new, ComposedCalls)).to eq false
  end

  it 'Simple does NOT implement ComposedCalls' do
    expect(InterfaceSupport.implements?(Simple.new, ComposedCalls)).to eq false
  end

  it 'Different does NOT implement ComposedCalls' do
    expect(
      InterfaceSupport.implements?(Different.new, ComposedCalls)
    ).to eq false
  end
end
