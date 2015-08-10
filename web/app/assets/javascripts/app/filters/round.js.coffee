window.ChaiBioTech.ngApp.filter 'round', [
  ->
    (input, numDigit) ->
      num = parseFloat(input)
      num.toFixed(numDigit)
]