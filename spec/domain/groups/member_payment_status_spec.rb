# frozen_string_literal: true

#  Copyright (c) 2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.

require 'spec_helper'

describe Groups::MemberPaymentStatus do
  subject(:nooper) { described_class.new(non_layer) }

  let(:non_layer) { groups(:paderborn_vorstand)}

  it 'does nothing if group is not a layer' do
    expect(non_layer).to_not be_layer
    expect(nooper.update).to be_falsey
  end
end
