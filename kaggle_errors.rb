# frozen_string_literal: true

# https://medium.com/analytics-vidhya/root-mean-square-log-error-rmse-vs-rmlse-935c6cc1802a

def rmsle(predictions, actuals)
  unless predictions.length == actuals.length
    return throw 'Predictions.length must be equal to actuals.length'
  end

  squared_errors = []
  i = 0
  while i < predictions.length
    actual = actuals[i]
    predicted = predictions[i]

    begin
      squared_errors << (Math.log(predicted + 1) - Math.log(actual + 1))**2
    rescue StandardError
      0
    end
    i += 1
  end

  Math.sqrt(squared_errors.sum / squared_errors.length.to_f)
end
