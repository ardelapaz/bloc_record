require 'sqlite3'
require 'bloc_record/schema'

module Persistence
    def self.included(base)
        base.extend(ClassMethods)
    end

    def save
        self.save! rescue false
    end

    def save!
        unless self.id
            self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
            BlocRecord::Utility.reload_obj(self)
            return true
          end
        fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")
    
        self.class.connection.execute <<-SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{self.id};
        SQL
    
        true
      end

      def update_attribute(attribute, value)
          self.class.update(self.id, { attribute => value })
      end

      def update_attributes(updates)
          self.class.update(self.id, updates)
      end

      def destroy
          self.class.destroy(self.id)
      end
    
    module ClassMethods
        def create(attrs)
            attrs = BlocRecord::Utility.convert_keys(attrs)
            attrs.delete "id"
            vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }
          
            connection.execute <<-SQL
              INSERT INTO #{table} (#{attributes.join ","})
              VALUES (#{vals.join ","});
            SQL
          
            data = Hash[attributes.zip attrs.values]
            data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
            new(data)
        end

        def update(ids, updates)
            if(ids.class == Array && updates.class == Array)
                for i in 0..updates.length - 1 do
                    update_one(ids[i], updates[i])
                end
            else
              update_one(ids, updates)
            end
            true
        end

        def update_one(ids, updates)
            if ids.class == Fixnum
              where_clause = "WHERE id = #{ids};"
            elsif ids.class == Array
              where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
            else
              where_clause = ";"
            end

            updates = BlocRecord::Utility.convert_keys(updates)
			      updates.delete "id"
			      updates_array = updates.map { |key, value| "#{key} = #{BlocRecord::Utility.sql_strings(value)}" }
          
            connection.execute <<-SQL
              UPDATE #{table}
              SET #{updates_array.join(", ")} 
              #{where_clause}
            SQL
        end

        def update_all(updates)
            update(nil, updates)
        end

        def destroy(*id)
            if id.length > 1
              where_clause = "WHERE id IN (#{id.join(",")});"
            else
              where_clause = "WHERE id = #{id.first};"
            end
          
            connection.execute <<-SQL
              DELETE FROM #{table} #{where_clause}
            SQL
          
            true
        end

        def destroy_all(conditions_hash=nil)
            if conditions_hash && !conditions_hash.empty?
                if conditions_hash.class == Hash
                    conditions_hash = BlocRecord::Utility.convert_keys(conditions_hash)
                    conditions = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
                    where_clause = "WHERE #{conditions}"
                elsif conditions_hash.class === Array
                    where_clause = conditions_hash.shift
                    params = conditions_hash
                elsif conditions_hash.class == String
                    where_clause = "WHERE #{conditions_hash}"
                else
                    where_clause = ""
                end
                sql = <<-SQL
                  DELETE FROM #{table}
                  #{where_clause};
                  SQL
                connection.execute(sql, params)
              true
            end
        end

          def method_missing(m, *args)
            s = m.split('_')[1, m.length - 1].join('_')
            update(s, *args)
        end
    end
end