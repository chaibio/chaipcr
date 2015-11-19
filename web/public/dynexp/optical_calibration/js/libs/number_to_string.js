// number to string, pluginized from http://stackoverflow.com/questions/5529934/javascript-numbers-to-words

window.num2str = function (num) {
    return window.num2str.convert(num);
}

window.num2str.ones = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
window.num2str.tens = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
window.num2str.teens = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];


window.num2str.convert_millions = function(num) {
    if (num >= 1000000) {
        return this.convert_millions(Math.floor(num / 1000000)) + " million " + this.convert_thousands(num % 1000000);
    }
    else {
        return this.convert_thousands(num);
    }
}

window.num2str.convert_thousands = function(num) {
    if (num >= 1000) {
        return this.convert_hundreds(Math.floor(num / 1000)) + " thousand " + this.convert_hundreds(num % 1000);
    }
    else {
        return this.convert_hundreds(num);
    }
}

window.num2str.convert_hundreds = function(num) {
    if (num > 99) {
        return this.ones[Math.floor(num / 100)] + " hundred " + this.convert_tens(num % 100);
    }
    else {
        return this.convert_tens(num);
    }
}

window.num2str.convert_tens = function(num) {
    if (num < 10) return this.ones[num];
    else if (num >= 10 && num < 20) return this.teens[num - 10];
    else {
        return this.tens[Math.floor(num / 10)] + " " + this.ones[num % 10];
    }
}

window.num2str.convert = function(num) {
    if (num == 0) return "zero";
    else return this.convert_millions(num);
}