
###########################################################################
#    Copyright (C) 2011-2012 by Greg Lawson
#    <GregLawson123@gmail.com>
#
# Copyright: See COPYING file that comes with this distribution
#
###########################################################################
# require 'app/models/global.rb'
module GenericTableHtml
  module ClassMethods
    # column order for default html generation
    def column_order
      ret = logical_primary_key
      ret += column_symbols - logical_primary_key - [:id]
      ret
    end # column_order

    def header_html(column_order = nil)
      if column_order.nil?
        column_order = self.column_order
      end # if
      ret = '<tr>'
      column_order.each do |header|
        ret += '<th>' + header.to_s.humanize + '</th>'
      end # each
      ret += '</tr>'
      ret
    end # header_html

    # Produce default HTML for ActiveRecord model
    def table_html(column_order = nil)
      if column_order.nil?
        column_order = self.column_order
      end # if
      ret = '<table>'
      ret += header_html(column_order)
      all.each do |row|
        ret += row.row_html(column_order)
      end # each
      ret += '</table>'
      ret
    end # table_html
  end # GenericTableHtml::ClassMethods
  # Calculate rails relative route to this record
  def rails_route(action = nil)
    route = self.class.name.tableize + '/' + self[:id].to_s
    if action.nil?
      return route
    else
      return route + '/' + action.to_s
    end # if
  end # rails_route

  def column_html(column_symbol)
    if self.class.foreign_key_names.map(&:to_sym).include?(column_symbol)
      return link_to(self[column_symbol].to_s, foreign_key_to_association(column_symbol).rails_route)
    else
      return self[column_symbol].to_s
    end # if
  end # column_html

  def row_html(column_order = nil)
    if column_order.nil?
      column_order = self.class.column_order
    end # if
    ret = '<tr>'
    column_order.each do |col|
      ret += '<td>' + column_html(col) + '</td>'
    end # each
    ret += '<td>' + link_to('Show', rails_route) + '</td>'
    ret += '<td>' + link_to('Edit', rails_route(:edit)) + '</td>'
    ret += '<td>' + link_to('Destroy', rails_route, confirm: 'Are you sure?', method: :delete) + '</td>'

    ret += '</tr>'
    ret
  end # row_html
end # GenericTableHtml
