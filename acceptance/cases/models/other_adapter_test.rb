require "test_helper"
require "models/project"

module ActiveRecord
  module Model
    class OtherAdapterTest < SpannerAdapter::TestCase
      attr_accessor :customer

      def setup
        super

        ActiveRecord::Base.establish_connection sqlite_config
        create_tables_in_sqlite_schema
      end

      def teardown
        ActiveRecord::Base.establish_connection connector_config
        super
      end

      def test_sqlite_customer_create
        assert_equal 'sqlite', Project.connection.adapter_name.downcase
        assert_nothing_raised do
          Project.create plan_id: 1, system_id: 1
        end
        assert_equal 1, Project.count
      end
    end
  end
end
