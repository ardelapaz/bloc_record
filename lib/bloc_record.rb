module BlocRecord
    def self.connect_to(filename, dbm)
      @database_filename = filename
      @dbm = dbm
    end
  
    def self.database_filename
      @database_filename
    end

    def self.dbm
      @dbm
    end
  end