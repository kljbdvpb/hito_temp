# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

class MemberPaymentStatusJob < RecurringJob
  private

  def perform_internal
    Group::Ortsgruppe.all.find_each do |group|
      Groups::MemberPaymentStatus.new(group).update
    end
  end

  def next_run
    Time.new(Time.zone.now.year.succ, 8, 31, 5, 0).in_time_zone
  end
end
