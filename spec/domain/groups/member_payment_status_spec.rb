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

  context 'counts only members' do
    before do
      10.times do
        Fabricate('Group::Ortsgruppe::Mitglied', group: group)
      end
      2.times do
        Fabricate('Group::Ortsgruppe::Foerdermitglied', group: group)
      end
      3.times do
        Fabricate('Group::OrtsgruppeVorstand::Mitglied',
                  group: group.children.find_by(type: 'Group::OrtsgruppeVorstand'))
      end
    end

    it 'has assumptions' do
      expect(group.people.count).to eq 12
      all_members = Person.joins(:roles)
        .where(roles: { group: group.layer_group.self_and_descendants })

      expect(all_members.count).to eq 15

      expect(
        all_members.where({
          roles: { type: ['Group::Ortsgruppe::Mitglied']}
        }).count
      ).to eq 10
    end

    it 'all member are normal members' do
      expect do
        subject.update
      end.to change(group, :members_normal).to(10)
        .and change(group, :members_discounted).to(0)
    end
  end

  context 'with siblings in other groups' do
    let(:bonn) { groups(:bonn) }
    let(:paderborn) { group }
    subject(:bonn_status) { described_class.new(bonn)}

    before do
      tom   = Fabricate(:person, birthday: 20.years.ago, nickname: 'tom')
      olaf  = Fabricate(:person, birthday: 15.years.ago, nickname: 'olaf')
      peter = Fabricate(:person, birthday: 13.years.ago, nickname: 'peter')

      Fabricate(:family_member, person: tom, other: olaf, kind: 'sibling')
      Fabricate(:family_member, person: tom, other: peter, kind: 'sibling')

      Fabricate('Group::Ortsgruppe::Mitglied', person: tom, group: paderborn)
      Fabricate('Group::Ortsgruppe::Mitglied', person: olaf, group: paderborn)
      Fabricate('Group::Ortsgruppe::Mitglied', person: peter, group: bonn)

      [tom, olaf, peter].each(&:reload)
    end

    it 'has 2 and 1 members in total' do
      expect do
        paderborn_status.update
      end.to change { paderborn.members_normal.to_i + paderborn.members_discounted.to_i }.to(2)

      expect do
        bonn_status.update
      end.to change { bonn.members_normal.to_i + bonn.members_discounted.to_i }.to(1)
    end

    it 'the 2 oldest siblings count as normal members' do
      expect do
        paderborn_status.update
      end.to change(paderborn, :members_normal).to(2)
    end

    it 'the 1 youngest siblings counts as discounted member in its group' do
      expect do
        bonn_status.update
      end.to change(bonn, :members_discounted).to(1)
    end
  end
end
