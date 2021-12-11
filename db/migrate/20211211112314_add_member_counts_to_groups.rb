class AddMemberCountsToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :members_normal, :integer
    add_column :groups, :members_discounted, :integer
  end
end
