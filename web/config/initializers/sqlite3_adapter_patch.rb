module ActiveRecord
  module ConnectionAdapters
    class SQLite3Adapter < AbstractAdapter
      QUOTED_TRUE, QUOTED_FALSE = '1', '0'

      def quoted_true
        QUOTED_TRUE
      end

      def quoted_false
        QUOTED_FALSE
      end
    end
  end
end