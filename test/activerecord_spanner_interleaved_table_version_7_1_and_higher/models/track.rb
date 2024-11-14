# Copyright 2023 Google LLC
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

module TestInterleavedTables_7_1_AndHigher
  class Track < ActiveRecord::Base
    # self.primary_keys = :singerid, :albumid, :trackid

    if ActiveRecord::gem_version < Gem::Version.create('7.2.0')
      belongs_to :album, query_constraints: [:singerid, :albumid]
    else
      belongs_to :album, foreign_key: [:singerid, :albumid]
    end
    belongs_to :singer, foreign_key: :singerid

    def album=value
      super
      # Ensure the singer of this track is equal to the singer of the album that is set.
      self.singer = value&.singer
    end
  end
end
