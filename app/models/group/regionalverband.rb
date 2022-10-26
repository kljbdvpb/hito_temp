# frozen_string_literal: true

#  Copyright (c) 2012-2021, Katholische Landjugendbewegung Paderborn. This file is part of
#  hitobito_kljb and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_kljb.


class Group::Regionalverband < ::Group
  self.layer = true
self.possible_children = [Group::RegionalverbandAg]
  self.default_children = [
    Group::RegionalverbandVorstand,
    Group::RegionalverbandKontakte
  ]

  children(*default_children, Group::Ortsgruppe)

  class Foerdermitglied < ::Role
    self.kind = :passive
    self.visible_from_above = false
    self.permissions = []
  end

  roles Foerdermitglied
end
