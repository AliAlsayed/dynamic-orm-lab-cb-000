require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    column_names = []
    table_info.each do |h|
      column_names << h["name"]
    end
    column_names.compact
  end

  self.column_names.each do |name|
    attr_accessor name.to_sym
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "insert into students (#{col_names_for_insert}) values (#{values_for_insert});"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("select last_insert_rowid() from students;")[0][0]
  end

end
