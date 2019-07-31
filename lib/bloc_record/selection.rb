require 'sqlite3'
 
 module Selection
  def find(*ids)
 
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end
   def find_one(id)
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE id = #{id};
     SQL
 
     init_object_from_row(row)
   end

   def find_by(attribute, value)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    rows_to_array(rows)
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def take(num=1)
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end

  def find_each(options = {})
    start = options[:start]
    batch_size = options[:batch_size]
    if start != nil && batch_size != nil
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        LIMIT #{batch_size} OFFSET #{start};
      SQL
    elsif start == nil && batch_size != nil
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        LIMIT #{batch_size};
      SQL
    elsif start != nil && batch_size == nil
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        OFFSET #{start};
      SQL
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table};
      SQL
    end

    row_array = rows_to_array(rows)
    yield(row_array)

  end

  def find_in_batches(start, batch_size)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      LIMIT #{batch_size}
      OFFSET #{start};
    SQL

    row_array = rows_to_array(rows)
    yield(row_array)
  end


  ########
   
   private

   def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end
 
   def rows_to_array(rows)
     rows.map { |row| new(Hash[columns.zip(row)]) }
   end  

   def method_missing(m, *args, &block)
    m = m.to_s
    if (m.match(/find_by/)) 
      s = m.split('_')[2, m.length - 1].join("_").to_sym
      find_by(s, *args)
    end
  end
end
