require_relative 'db_connection'
require_relative '02_sql_object'
require 'debugger'
module Searchable
  def where(params)
    columns = params.keys.map { |item| "#{item}" }
    values = params.values.map { |item| "#{item}" }

    h_doc = <<-SQL
      SELECT
      #{self.table_name}.*
      FROM
      #{self.table_name}
      WHERE
      #{ columns.map { |col| "#{self.table_name}.#{col} = ?" }.join(' AND ') }
    SQL

    parse_all(DBConnection.execute(h_doc,*values))
  end
end


class SQLObject
  extend Searchable
end
