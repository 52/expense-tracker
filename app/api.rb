require "sinatra/base"
require "json"
require "ox"
require_relative "ledger"

module ExpenseTracker
  class API < Sinatra::Base
    def initialize ledger: Ledger.new
      @ledger = ledger
      super
    end

    post "/expenses" do
      if request.media_type == "application/json"
        expense = JSON.parse request.body.read
      elsif request.media_type == "text/xml"
        expense = Ox.load(request.body.read, mode: :hash)
        expense[:amount] = expense[:amount].to_f if expense.key?(:amount)
      else
        status 422
      end

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
