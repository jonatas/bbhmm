module Core
  class Simplify
    def initialize(debts)
      @debts = debts.group_by { |debt| [debt.from, debt.to] }
    end

    def debts
      debts = squash_debts
      current_debts = []
      while head = debts.shift
        index = debts.find_index { |debt| head.from == debt.to && debt.from == head.to }

        unless index
          current_debts << head
          next
        end

        debt = debts.delete_at(index)

        next if head.amount == debt.amount

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

    def squash_debts
      @debts.transform_values { |debts| debts.map(&:amount).inject(&:+) }
            .map { |(from, to), amount| Debt.new(from, to, amount) }
    end
  end
end
