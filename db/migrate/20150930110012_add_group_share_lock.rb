# rubocop:disable all
class AddGroupShareLock < ActiveRecord::Migration
  def change
    add_column :namespaces, :share_with_group_lock, :boolean, default: false
  end
end
