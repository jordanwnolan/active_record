require_relative 'db_connection'
require_relative '00_attr_accessor_object'
require_relative '01_mass_object'
require 'active_support/inflector'

class SQLObject < MassObject

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    if @table_name.nil?
      table_name = self.to_s
      table_name = table_name.split /(?=[A-Z])/
      table_name = table_name.map(&:downcase).join('_') << 's'
    end
    @table_name ||= table_name
  end

  def self.columns
    h_doc = <<-SQL
    SELECT
    *
    FROM
    #{self.table_name}
    SQL

    column_names = DBConnection.execute2(h_doc)[0].map(&:to_sym)

    my_attr_accessor(*column_names) #set up getters/setters

    column_names.map { |col| col.to_sym}
  end

  def self.all
    #...
    h_doc = <<-SQL
      SELECT
      #{self.table_name}.*
      FROM
      #{self.table_name}
    SQL

    results = DBConnection.execute(h_doc)
    parse_all(results)
  end

  def self.find(id)
    h_doc = <<-SQL
      SELECT
      #{self.table_name}.*
      FROM
      #{self.table_name}
      WHERE
      #{self.table_name}.id = ?
    SQL

    self.new(DBConnection.execute(h_doc, id)[0])
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    # ...
    num_of_attributes = attributes.keys.length

    values = attribute_values

    question_marks = '?' * num_of_attributes
    question_marks = question_marks.split('').join(',')
    h_doc = <<-SQL
      INSERT INTO
      #{self.class.table_name} (#{attributes.keys.join(', ')})
      VALUES
      (#{question_marks})
    SQL

    DBConnection.execute(h_doc, values)

    self.id = DBConnection.instance.last_insert_row_id if self.id == nil
  end

  def initialize(params = {})
    # ...
    cols = self.class.columns

    params.each do |attr_name, val|

      raise "unknown attribute #{attr_name}" unless cols.include?(attr_name.to_sym)

    end
    super(params)
  end

  def save
    # ...
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    columns = attributes.keys
    values = attribute_values.dup

    id_key = columns.delete(:id)
    id_val = values.delete(attributes[id_key])
    values << id_val # move id to the end

    h_doc = <<-SQL
      UPDATE
      #{self.class.table_name}
      SET
      #{ columns.map { |col| "#{col} = ?" }.join(',') }
      WHERE
      id = ?
    SQL

    DBConnection.execute(h_doc,*values)
  end

  def attribute_values
    attributes.keys.map { |attribute| send(attribute) }
  end
end
