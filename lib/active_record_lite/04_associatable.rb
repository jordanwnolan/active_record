require_relative '03_searchable'
require 'active_support/inflector'
require 'debugger'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    self.class_name.downcase << 's'
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]

    if self.foreign_key.nil?
      self.foreign_key = "#{name}_id".to_sym
    end
    if self.class_name.nil?
      self.class_name = "#{name}".capitalize
    end
    if self.primary_key.nil?
      self.primary_key = :id
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]

    if self.foreign_key.nil?
      self.foreign_key = "#{self_class_name.singularize.downcase}_id".to_sym
    end
    if self.class_name.nil?
      self.class_name = "#{name}".singularize.capitalize
    end
    if self.primary_key.nil?
      self.primary_key = :id
    end

    # ...
  end
end

module Associatable

  def belongs_to(name, options = {})
    options  = BelongsToOptions.new(name, options)

    define_method("#{name}") do 
      fk = options.send(:foreign_key)
      val = self.send(fk)
      id = options.send(:primary_key)
      options.model_class.where("#{id}" => "#{val}").first
    end

    assoc_options[name] = options
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, "#{self.table_name}", options)
    define_method("#{name}") do
      fk = options.send(:foreign_key)
      id = options.send(:primary_key)
      id_val = self.send(id)
      options.model_class.where("#{fk}" => "#{id_val}")
    end
  end

  def assoc_options
    @has_one_through_options ||= {}
  end

end

class SQLObject
  extend Associatable
end
