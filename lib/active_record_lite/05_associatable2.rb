require_relative '04_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      join_table = source_options.model_class.table_name
      thru_table = through_options.model_class.table_name

      h_doc = <<-SQL
        SELECT
        #{join_table}.*
        FROM
        #{thru_table}
        JOIN
        #{join_table}
        ON
        #{thru_table}.#{source_options.foreign_key} = #{join_table}.#{source_options.primary_key}
        WHERE
        #{thru_table}.id = ?
      SQL

      id_val = self.send(through_options.foreign_key)
      source_options.model_class.parse_all(DBConnection.execute(h_doc, id_val)).first
    end
  end
end
