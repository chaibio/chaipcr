window.ChaiBioTech.ngApp.filter 'round', [
  ->
    (input, numDigit) ->
      input = input || 0;
      num = parseFloat(input)
      num.toFixed(numDigit)
]