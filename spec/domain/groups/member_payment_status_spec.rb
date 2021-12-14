# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

require 'spec_helper'

describe Groups::MemberPaymentStatus do
  subject(:nooper) { described_class.new(non_layer) }
  subject(:paderborn_status) { described_class.new(group) }

  let(:group) { groups(:paderborn) }
  let(:non_layer) { groups(:paderborn_vorstand)}

  it 'does nothing if group is not a layer' do
    expect(non_layer).to_not be_layer
    expect(nooper.update).to be_falsey
  end

  context 'with a group that has members without siblings' do
    before do
      10.times do
        Fabricate('Group::Ortsgruppe::Mitglied', group: group)
      end
    end

    it 'has assumptions' do
      expect(group.people.count).to eq 10
    end

    it 'all member are normal members' do
      expect do
        subject.update
      end.to change(group, :members_normal).to(10)
        .and change(group, :members_discounted).to(0)
    end
  end

  context 'with a group of only one family of 3 siblings' do
    before do
      tom   = Fabricate(:person, birthday: 20.years.ago, nickname: 'tom')
      olaf  = Fabricate(:person, birthday: 15.years.ago, nickname: 'olaf')
      peter = Fabricate(:person, birthday: 13.years.ago, nickname: 'peter')

      Fabricate(:family_member, person: tom, other: olaf, kind: 'sibling')
      Fabricate(:family_member, person: tom, other: peter, kind: 'sibling')

      Fabricate('Group::Ortsgruppe::Mitglied', person: tom, group: group)
      Fabricate('Group::Ortsgruppe::Mitglied', person: olaf, group: group)
      Fabricate('Group::Ortsgruppe::Mitglied', person: peter, group: group)

      [tom, olaf, peter].each(&:reload)
    end

    it 'has 3 members in total' do
      expect do
        subject.update
      end.to change { group.members_normal.to_i + group.members_discounted.to_i }.to(3)
    end

    it 'the 2 oldest siblings count as normal members' do
      expect do
        subject.update
      end.to change(group, :members_normal).to(2)
    end

    it 'the 1 youngest siblings counts as discounted member' do
      expect do
        subject.update
      end.to change(group, :members_discounted).to(1)
    end
  end

  context 'with a group of only one family of 2 siblings' do
    before do
      tom = Fabricate(:person)
      peter = Fabricate(:person)

      Fabricate(:family_member, person: tom, other: peter, kind: 'sibling')

      Fabricate('Group::Ortsgruppe::Mitglied', person: tom, group: group)
      Fabricate('Group::Ortsgruppe::Mitglied', person: peter, group: group)
    end

    it 'has assumptions' do
      expect(group.people.count).to eq 2
    end

    it 'all count as normal members' do
      expect do
        subject.update
      end.to change(group, :members_normal).to(2)
        .and change(group, :members_discounted).to(0)
    end
  end
end
