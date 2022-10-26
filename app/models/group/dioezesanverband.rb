# frozen_string_literal: true

#  Copyright (c) 2012-2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.


class Group::Dioezesanverband < ::Group
  self.layer = true
self.possible_children = [Group::DioezesanverbandAg]
  self.default_children = [
    Group::DioezesanverbandVorstand,
    Group::DioezesanverbandBuero,
    Group::DioezesanverbandKontakte
  ]

  children(*default_children, Group::Regionalverband)

  class Foerdermitglied < ::Role
    self.kind = :passive
    self.permissions = []
  end

  class ItSupport < ::Role
    self.permissions = [:admin, :impersonation, :layer_and_below_full]
  end

  roles Foerdermitglied, ItSupport
end
