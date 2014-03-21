class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      # p "making #{name} getter/setter"
      define_method(name) do
        attributes[name]
      end

      define_method("#{name}=") do |arg|
        # self.instance_variable_set("@#{name}", arg)
        attributes[name] = arg
      end
    end
  end
end
