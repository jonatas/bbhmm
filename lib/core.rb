# frozen_string_literal: true
require 'core/share'
require 'core/debt'
require 'core/expense'
require 'core/simplify'
require 'core/split'

module Core
  # The engine responsible for control the Shares of an Expense
  module_function

  def expense(description:, amount: 0)
    Expense.new(description, amount)
  end

  def split(expense, users)
    Split.new(expense, users)
  end

  def simplify(debts)
    Simplify.new(debts).debts
  end
end
