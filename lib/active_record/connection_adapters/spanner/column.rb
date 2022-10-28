# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module Spanner
      class Column < ConnectionAdapters::Column
        def has_default?
          super && !default_function
        end
      end
    end
  end
end
