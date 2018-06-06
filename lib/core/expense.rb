module Core
  # Expense is something we want to share among us
  class Expense < Struct.new(:description, :amount)
  end
end
