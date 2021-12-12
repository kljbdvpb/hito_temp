# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

require 'spec_helper'
require 'csv'

describe Export::Tabular::Groups::List do

  let(:group) { groups(:nord) }

  let(:list) { group.self_and_descendants.without_deleted.includes(:contact) }
  let(:data) { described_class.csv(list) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

   its(:headers) do
     expected = [
       "Id",
       "Elterngruppe",
       "Name",
       "Kurzname",
       "Gruppentyp",
       "Haupt-E-Mail",
       "Adresse",
       "PLZ",
       "Ort",
       "Land",
       "Ebene",
       "Beschreibung",
       "normale Mitglieder",
       "vergünstigte Mitglieder"
     ]

     should match_array expected
     should eq expected
   end

   it 'has 4 items' do
     expect(subject.size).to eq(16)
   end

   context 'first row' do
     subject { csv[0] }

     its(['Id']) { should == group.id.to_s }
     its(['Elterngruppe']) { should == group.parent_id&.to_s }
     its(['Name']) { should == group.name }
     its(['Kurzname']) { should == group.short_name }
     its(['Gruppentyp']) { should == 'Regionalverband' }
     its(['Haupt-E-Mail']) { should == group.email }
     its(['Adresse']) { should == group.address }
     its(['PLZ']) { should == group.zip_code.to_s }
     its(['Ort']) { should == group.town }
     its(['Land']) { should == group.country_label }
     its(['Ebene']) { should == group.id.to_s }
     its(['normale Mitglieder']) { should be_blank }
     its(['vergünstigte Mitglieder']) { should be_blank }
   end

   context 'group with members' do
     subject { csv.find { |row| row['Name'] == group_with_members.name } }
     let(:group_with_members) { groups(:paderborn) }

     before do
       group_with_members.update!(
         members_normal: 23,
         members_discounted: 7
       )
     end

     its(['Gruppentyp']) { should == 'Ortsgruppe' }
     its(['normale Mitglieder']) { should == "23" }
     its(['vergünstigte Mitglieder']) { should == "7" }
   end
end
