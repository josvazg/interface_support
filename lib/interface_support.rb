# InterfaceSupport bring Go like interfaces to Ruby, while still leveraging
# Ruby's native duck typing
module InterfaceSupport
  # Interface module is a marker to use in any interface declaration
  # Interfaces are expected to define hierarchies or compositions, but should
  # not be instantiated. Usage:
  # - For humans to read what an interface is called and what methods it contains.
  # - For code to check if an object implements that interface or not.
  module Interface
    # Empty Interface marker module
  end

  # Assertion that fails if obj's class doesn't implement all of interface
  # defined methods.
  # Use it on any object that is expected to implement interface.
  # @param obj [Object] object instance to test method implementation against
  #        an interface
  # @param interface [InterfaceSupport::Interface] listing the methods to be
  #        implemented
  # @raise exception if interface it NOT an InterfaceSupport::interface or
  #        obj's class it not implementing all methods from interface.
  def self.implements(obj, interface)
    assert_interface(interface)
    issues = interface_checks(obj, interface)
    return if issues.empty?
    raise "#{obj.class} fails to implement interface #{interface}:\n" +
          issues.join("\n")
  end

  # Test checking whether or not obj's class implements all of interface
  # defined methods.
  # Use it on any object to test if it implements interface.
  # @param obj [Object] object instance to test method implementation against
  #        an interface
  # @param interface [InterfaceSupport::Interface] listing the methods to be
  #        implemented
  # @return true if obj's class implements all methods defined by
  #         interface, and false otherwise.
  # @raise exception if interface it NOT an InterfaceSupport::Interface.
  def self.implements?(obj, interface)
    interface_checks(obj, interface).empty?
  end
  
  # Private class methods

  def self.interface_checks(obj, interface)
    assert_interface(interface)
    methods = interface.instance_methods - Object.public_methods
    issues = []
    methods.each do |method_name|
      unless obj.public_methods.include? method_name
        issues << "#{obj.class} does not implement "\
                  "#{interface}'s method #{method_name}"
        next
      end
      signature_checks(issues, obj,
                       interface.instance_method(method_name),
                       obj.method(method_name))
    end
    issues
  end

  def self.signature_checks(issues, obj, expected_method, actual_method)
    expected_parameters = expected_method.parameters
    actual_parameters = actual_method.parameters
    method_name = expected_method.name
    unless expected_parameters.size == actual_parameters.size
      issues << "#{obj.class}'s method #{method_name} expected to define "\
                "#{expected_parameters.size} parameters but defines "\
                "#{actual_parameters.size}"
      return
    end
    expected_parameters.each_with_index do |expected_param, i|
      issue = param_check(expected_param, i, actual_parameters)
      issues << issue if issue
    end
  end

  def self.param_check(expected_param, i, actual_parameters)
    param_required, param_name = actual_parameters[i]
    expected_required, expected_name = expected_param
    unless expected_name == param_name
      return "#{obj.class}'s method #{method_name} expected "\
             "parameter #{i} to be #{expected_name} but got #{param_name}"
    end
    return if expected_required == param_required
    "#{obj.class}'s method #{method_name} "\
    "parameter #{i} (#{param_name}) expected to be "\
    "#{expected_required == :req ? 'required' : 'optional'} "\
    "but is #{param_required == :req ? 'required' : 'optional'}"
  end

  def self.assert_interface(interface)
    expected_base = InterfaceSupport::Interface
    return if interface.is_a?(expected_base)
    # Ok also if any of the module ancestors is InterfaceSupport::Interface
    return if interface.ancestors.find { |a| a.is_a?(expected_base) }
    raise "interface must be an #{expected_base} "\
          "but #{interface} is not"
  end

  private_class_method :interface_checks,
                       :signature_checks,
                       :param_check,
                       :assert_interface
end
