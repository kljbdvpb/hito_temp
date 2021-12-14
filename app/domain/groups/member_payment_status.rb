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
      @normal_members ||= all_members.count - discounted_members
    end

    def discounted_members
      @discounted_members ||= underage_members_with_two_siblings.count
    end

    private

    def all_members
      @group.people
    end

    def members_with_siblings
      all_members.where.not(family_key: nil).order(:family_key, :birthday)
    end

    def underage_members_with_two_siblings
      all_members
        .group_by(&:family_key)
        .map { |_key, family| family.drop(2).select(&:underage?) }
        .flatten.compact
    end
  end
end
