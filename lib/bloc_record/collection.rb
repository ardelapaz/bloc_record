module BlocRecord
    class Collection < Array
      def update_all(updates)
        ids = self.map(&:id)
        self.any? ? self.first.class.update(ids, updates) : false
      end
      def take()
      end
      def where()
      end
      def not()
      end
    end
  end