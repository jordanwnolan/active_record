class AttrAccessorObject
  def self.my_attr_accessor(*names)
    
    names.each do |name|
      define_method(name) do
        attributes[name]
      end

      define_method("#{name}=") do |arg|
        attributes[name] = arg
      end
    end
  end
end
