module Core

  class Share < Struct.new(:user, :to_pay, :paid)
  end

  class Expense < Struct.new(:description, :amount)
  end

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
      -> (user) { Share.new(user, suggested_amount, 0) }
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
  end

  module_function
    def expense description: , amount: 0
      Expense.new(description, amount)
    end

    def split expense, users
      Split.new(expense, users)
    end
end
