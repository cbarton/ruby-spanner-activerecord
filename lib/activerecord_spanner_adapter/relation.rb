# Copyright 2022 Google LLC
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

module ActiveRecord
  module CpkExtension
    def cpk_subquery stmt
      return super unless spanner_adapter?
      # The composite_primary_key gem will by default generate WHERE clauses using an IN clause with a multi-column
      # sub select, e.g.: SELECT * FROM my_table WHERE (id1, id2) IN (SELECT id1, id2 FROM my_table WHERE ...).
      # This is not supported in Cloud Spanner. Instead, composite_primary_key should generate an EXISTS clause.
      cpk_exists_subquery stmt
    end

    def insert_all! attributes, returning: nil, **_kwargs
      return super unless spanner_adapter?
      return super if active_transaction? && !buffered_mutations?

      # This might seem inefficient, but is actually not, as it is only buffering a mutation locally.
      # The mutations will be sent as one batch when the transaction is committed.
      if active_transaction?
        attributes.each do |record|
          model._insert_record connection, record
        end
      else
        transaction isolation: :buffered_mutations do
          attributes.each do |record|
            model._insert_record connection, record
          end
        end
      end
    end


    def upsert_all attributes, returning: nil, unique_by: nil, **_kwargs
      return super unless spanner_adapter?
      if active_transaction? && !buffered_mutations?
        raise NotImplementedError, "Cloud Spanner does not support upsert using DML. " \
                                   "Use upsert outside a transaction block or in a transaction " \
                                   "block with isolation: :buffered_mutations"
      end

      # This might seem inefficient, but is actually not, as it is only buffering a mutation locally.
      # The mutations will be sent as one batch when the transaction is committed.
      if active_transaction?
        attributes.each do |record|
          model._upsert_record record, returning
        end
      else
        transaction isolation: :buffered_mutations do
          attributes.each do |record|
            model._upsert_record record, returning
          end
        end
      end
    end
  end

  class Relation
    prepend CpkExtension
  end
end
