# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

module Groups
  class MemberPaymentStatus
    def initialize(group)
      @group = group
    end

    def update
      return false unless @group.layer?

      @group.update(
        members_normal: normal_members,
        members_discounted: discounted_members
      )
    end

    def normal_members
      @normal_members ||= 0
    end

    def discounted_members
      @discounted_members ||= 0
    end
  end
end
