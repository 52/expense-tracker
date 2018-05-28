require_relative "../config/sequel"

module ExpenseTracker
  RecordResult = Struct.new :success?, :expense_id, :error_message

  class Ledger
    def record expense
      %w(payee amount date).each do |key|
        unless expense.key? key
          error_message = "Invalid expense: \"#{key}\" is required"
          return RecordResult.new false, nil, error_message
        end
      end

      DB[:expenses].insert expense
      id = DB[:expenses].max :id
      RecordResult.new true, id, nil
    end

    def expenses_on date
      DB[:expenses].where(date: date).all
    end
  end
end
