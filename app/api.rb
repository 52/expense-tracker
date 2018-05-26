require "sinatra/base"
require "json"
require_relative "ledger"

module ExpenseTracker
  class API < Sinatra::Base
    def initialize ledger: Ledger.new
      @ledger = ledger
      super
    end

    post "/expenses" do
      expense = JSON.parse request.body.read
      response = @ledger.record expense

      if response.success?
        status 200
        JSON.generate "expense_id" => response.expense_id
      else
        status 422
        JSON.generate "error_message" => response.error_message
      end
    end

    get "/expenses/:date" do
      JSON.generate @ledger.expenses_on(params["date"])

    end
  end
end
