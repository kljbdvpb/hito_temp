# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

module Kljb::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS -= [:nickname]
  end

  def underage?(cutoff_date = Time.zone.now.to_date)
    return false unless birthday?

    years(cutoff_date).presence < 18
  end
end
