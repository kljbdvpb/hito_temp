# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

module Groups
  class MemberPaymentStatus
    AGE_CUTOFF_DATE = [8, 31].freeze

    class << self
      def cutoff_date
        now = Date.current
        year = if now >= Date.new(now.year, *AGE_CUTOFF_DATE)
                 now.year
               else
                 now.year - 1
               end

        Date.new(year, *AGE_CUTOFF_DATE)
      end
    end

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
      @normal_members ||= all_members_of_layer.count - discounted_members
    end

    def discounted_members
      @discounted_members ||= underage_members_with_two_siblings.count
    end

    private

    def all_members_of_layer
      Person.joins(:roles)
            .where(roles: {
                     group: @group.groups_in_same_layer,
                     type: ['Group::Ortsgruppe::Mitglied']
                   })
    end

    def members_with_siblings
      all_members_of_layer.where.not(family_key: nil).order(:family_key)
    end

    def complete_families(keys)
      Person.where(family_key: keys).order(:family_key, :birthday)
    end

    def underage_people_with_two_siblings(keys)
      complete_families(keys)
        .group_by(&:family_key)
        .map { |_key, family| family.drop(2).select { |person| 
          person.underage?(Groups::MemberPaymentStatus.cutoff_date)
        } }
        .flatten.compact
    end

    def underage_members_with_two_siblings
      keys = members_with_siblings.uniq.pluck(:family_key)

      underage_people_with_two_siblings(keys) & all_members_of_layer
    end
  end
end
