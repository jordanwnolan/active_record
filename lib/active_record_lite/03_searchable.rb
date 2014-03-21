require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    columns = params.keys

    h_doc = <<-SQL
      SELECT
      #{self.table_name}.*
      FROM
      #{self.table_name}
      WHERE
      #{columns.map { |col| "#{col} = ?" }.join(' AND ')}
    SQL

    parse_all(DBConnection.execute(h_doc,params.values))
  end
end


class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
