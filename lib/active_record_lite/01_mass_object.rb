# deprecated for Rails 4
require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.attributes
    # ...
    raise "must not call #attributes on MassObject directly" if self == MassObject
    @attributes ||= {}
  end

  def initialize(params = {})
    # ...
    # cols = self.class.columns
    # @attributes = {}
    params.each do |attr_name, val|
      # raise "unknown attribute #{attr_name}" unless cols.include?(attr_name)
      # attr_name = attr_name.to_sym
      self.send("#{attr_name}=".to_sym, val)
    end
  end

  def self.parse_all(results)
    # ...
    objects = results.map do |obj|
      self.new(obj)
    end

    objects
  end
end
