window.ChaiBioTech.ngApp.filter 'round', [
  ->
    (input, numDigit) ->
      num = parseFloat(input)
      pow = Math.pow(10, parseInt(numDigit))

      Math.round(num * pow) / pow
]