module Core
  # It's a subset of a Expense
  class Share < Struct.new(:user, :to_pay, :paid)
  end

  # Expense is something we want to share among us
  class Expense < Struct.new(:description, :amount)
  end

  class Debt < Struct.new(:from, :to, :amount)
  end

  # The engine responsible for control the Shares of an Expense
  class Split
    attr_reader :expense, :shares

    def initialize(expense, users)
      @expense = expense
      @users = users
      @overrides = {}

      @shares = initialize_shares
    end

    def initialize_shares
      @users.map(&build_share_for)
    end

    def build_share_for
      ->(user) { Share.new(user, suggested_amount, 0) }
    end

    def split_also_with(*users)
      @users += users
      update_all_suggested_amounts
      @shares += users.map(&build_share_for)
    end

    def update_all_suggested_amounts
      @shares.each do |share|
        next if @overrides[share.user]
        share.to_pay = suggested_amount
      end
    end

    def suggested_amount
      (
        (expense.amount.to_f - total_overrided) /
        (@users.size - @overrides.size)
      ).round(2)
    end

    def add_payment(user, value)
      share_for(user).paid += value
    end

    def consider(user, pay_value:)
      @overrides[user] = pay_value
      share_for(user).to_pay = pay_value
      update_all_suggested_amounts
    end

    def missing_value
      expense.amount - paid
    end

    def paid
      sum(:paid)
    end

    def sum(attribute)
      @shares.map(&attribute).inject(:+)
    end

    def completed?
      paid >= expense.amount
    end

    def share_for(user)
      @shares.find { |s| s.user == user }
    end

    def total_overrided
      return 0 if @overrides.empty?

      @overrides.values.inject(:+)
    end

    def exclude(user)
      @overrides.delete(user)
      @users.delete(user)
      @shares.delete(share_for(user))
      update_all_suggested_amounts
    end

    def resolutor
      receivers = @shares.select { |e| e.paid > e.to_pay }
      payers = @shares.select { |e| e.paid < e.to_pay }.map(&:dup)
      debts = []

      receivers.each do |share|
        amount = share.paid - share.to_pay
        while amount > 0 && payers.any?
          payer = payers.first
          missing_value = payer.to_pay - payer.paid
          value =
            if missing_value >= amount
              payer.to_pay -= amount
              amount
            else
              payers.shift
              missing_value
            end

          debts << Debt.new(payer.user, share.user, value)
          amount -= value
        end
      end
      debts
    end
  end

  class Simplify
    def initialize(debts)
      @debts = debts.group_by { |debt| [debt.from, debt.to] }
    end

    def debts
      debts = group_the_same
      current_debts = []
      while head = debts.shift
        index = debts.find_index { |debt| head.from == debt.to && debt.from == head.to }

        current_debts << head && next unless index

        debt = debts.delete_at(index)
        base_debt, lower_debt = if head.amount > debt.amount
                                  [head, debt]
                                else
                                  [debt, head]
                                end

        debts << Core::Debt.new(
          base_debt.from, base_debt.to, base_debt.amount - lower_debt.amount
        )
      end
      current_debts
    end

    private

    def group_the_same
      @debts.transform_values { |debts| debts.map(&:amount).inject(&:+) }
            .map { |(from, to), amount| Debt.new(from, to, amount) }
    end
  end

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
