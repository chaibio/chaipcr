window.context = window.describe;
window.xcontext = window.xdescribe;

/* jasmine-fixture - 1.3.2
 * Makes injecting HTML snippets into the DOM easy & clean!
 * https://github.com/searls/jasmine-fixture
 */
(function() {
  var createHTMLBlock,
    __slice = [].slice;

  (function($) {
    var ewwSideEffects, jasmineFixture, originalAffix, originalJasmineDotFixture, originalJasmineFixture, root, _, _ref;
    root = (1, eval)('this');
    originalJasmineFixture = root.jasmineFixture;
    originalJasmineDotFixture = (_ref = root.jasmine) != null ? _ref.fixture : void 0;
    originalAffix = root.affix;
    _ = function(list) {
      return {
        inject: function(iterator, memo) {
          var item, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = list.length; _i < _len; _i++) {
            item = list[_i];
            _results.push(memo = iterator(memo, item));
          }
          return _results;
        }
      };
    };
    root.jasmineFixture = function($) {
      var $whatsTheRootOf, affix, create, jasmineFixture, noConflict;
      affix = function(selectorOptions) {
        return create.call(this, selectorOptions, true);
      };
      create = function(selectorOptions, attach) {
        var $top;
        $top = null;
        _(selectorOptions.split(/[ ](?![^\{]*\})(?=[^\]]*?(?:\[|$))/)).inject(function($parent, elementSelector) {
          var $el;
          if (elementSelector === ">") {
            return $parent;
          }
          $el = createHTMLBlock($, elementSelector);
          if (attach || $top) {
            $el.appendTo($parent);
          }
          $top || ($top = $el);
          return $el;
        }, $whatsTheRootOf(this));
        return $top;
      };
      noConflict = function() {
        var currentJasmineFixture, _ref1;
        currentJasmineFixture = jasmine.fixture;
        root.jasmineFixture = originalJasmineFixture;
        if ((_ref1 = root.jasmine) != null) {
          _ref1.fixture = originalJasmineDotFixture;
        }
        root.affix = originalAffix;
        return currentJasmineFixture;
      };
      $whatsTheRootOf = function(that) {
        if ((that != null ? that.jquery : void 0) != null) {
          return that;
        } else if ($('#jasmine_content').length > 0) {
          return $('#jasmine_content');
        } else {
          return $('<div id="jasmine_content"></div>').appendTo('body');
        }
      };
      jasmineFixture = {
        affix: affix,
        create: create,
        noConflict: noConflict
      };
      ewwSideEffects(jasmineFixture);
      return jasmineFixture;
    };
    ewwSideEffects = function(jasmineFixture) {
      var _ref1;
      if ((_ref1 = root.jasmine) != null) {
        _ref1.fixture = jasmineFixture;
      }
      $.fn.affix = root.affix = jasmineFixture.affix;
      return afterEach(function() {
        return $('#jasmine_content').remove();
      });
    };
    if ($) {
      return jasmineFixture = root.jasmineFixture($);
    } else {
      return root.affix = function() {
        var nowJQueryExists;
        nowJQueryExists = window.jQuery || window.$;
        if (nowJQueryExists != null) {
          jasmineFixture = root.jasmineFixture(nowJQueryExists);
          return affix.call.apply(affix, [this].concat(__slice.call(arguments)));
        } else {
          throw new Error("jasmine-fixture requires jQuery to be defined at window.jQuery or window.$");
        }
      };
    }
  })(window.jQuery || window.$);

  createHTMLBlock = (function() {
    var bindData, bindEvents, parseAttributes, parseClasses, parseContents, parseEnclosure, parseReferences, parseVariableScope, regAttr, regAttrDfn, regAttrs, regCBrace, regClass, regClasses, regData, regDatas, regEvent, regEvents, regExclamation, regId, regReference, regTag, regTagNotContent, regZenTagDfn;
    createHTMLBlock = function($, ZenObject, data, functions, indexes) {
      var ZenCode, arr, block, blockAttrs, blockClasses, blockHTML, blockId, blockTag, blocks, el, el2, els, forScope, indexName, inner, len, obj, origZenCode, paren, result, ret, zc, zo;
      if ($.isPlainObject(ZenObject)) {
        ZenCode = ZenObject.main;
      } else {
        ZenCode = ZenObject;
        ZenObject = {
          main: ZenCode
        };
      }
      origZenCode = ZenCode;
      if (indexes === undefined) {
        indexes = {};
      }
      if (ZenCode.charAt(0) === "!" || $.isArray(data)) {
        if ($.isArray(data)) {
          forScope = ZenCode;
        } else {
          obj = parseEnclosure(ZenCode, "!");
          obj = obj.substring(obj.indexOf(":") + 1, obj.length - 1);
          forScope = parseVariableScope(ZenCode);
        }
        while (forScope.charAt(0) === "@") {
          forScope = parseVariableScope("!for:!" + parseReferences(forScope, ZenObject));
        }
        zo = ZenObject;
        zo.main = forScope;
        el = $();
        if (ZenCode.substring(0, 5) === "!for:" || $.isArray(data)) {
          if (!$.isArray(data) && obj.indexOf(":") > 0) {
            indexName = obj.substring(0, obj.indexOf(":"));
            obj = obj.substr(obj.indexOf(":") + 1);
          }
          arr = ($.isArray(data) ? data : data[obj]);
          zc = zo.main;
          if ($.isArray(arr) || $.isPlainObject(arr)) {
            $.map(arr, function(value, index) {
              var next;
              zo.main = zc;
              if (indexName !== undefined) {
                indexes[indexName] = index;
              }
              if (!$.isPlainObject(value)) {
                value = {
                  value: value
                };
              }
              next = createHTMLBlock($, zo, value, functions, indexes);
              if (el.length !== 0) {
                return $.each(next, function(index, value) {
                  return el.push(value);
                });
              }
            });
          }
          if (!$.isArray(data)) {
            ZenCode = ZenCode.substr(obj.length + 6 + forScope.length);
          } else {
            ZenCode = "";
          }
        } else if (ZenCode.substring(0, 4) === "!if:") {
          result = parseContents("!" + obj + "!", data, indexes);
          if (result !== "undefined" || result !== "false" || result !== "") {
            el = createHTMLBlock($, zo, data, functions, indexes);
          }
          ZenCode = ZenCode.substr(obj.length + 5 + forScope.length);
        }
        ZenObject.main = ZenCode;
      } else if (ZenCode.charAt(0) === "(") {
        paren = parseEnclosure(ZenCode, "(", ")");
        inner = paren.substring(1, paren.length - 1);
        ZenCode = ZenCode.substr(paren.length);
        zo = ZenObject;
        zo.main = inner;
        el = createHTMLBlock($, zo, data, functions, indexes);
      } else {
        blocks = ZenCode.match(regZenTagDfn);
        block = blocks[0];
        if (block.length === 0) {
          return "";
        }
        if (block.indexOf("@") >= 0) {
          ZenCode = parseReferences(ZenCode, ZenObject);
          zo = ZenObject;
          zo.main = ZenCode;
          return createHTMLBlock($, zo, data, functions, indexes);
        }
        block = parseContents(block, data, indexes);
        blockClasses = parseClasses($, block);
        if (regId.test(block)) {
          blockId = regId.exec(block)[1];
        }
        blockAttrs = parseAttributes(block, data);
        blockTag = (block.charAt(0) === "{" ? "span" : "div");
        if (ZenCode.charAt(0) !== "#" && ZenCode.charAt(0) !== "." && ZenCode.charAt(0) !== "{") {
          blockTag = regTag.exec(block)[1];
        }
        if (block.search(regCBrace) !== -1) {
          blockHTML = block.match(regCBrace)[1];
        }
        blockAttrs = $.extend(blockAttrs, {
          id: blockId,
          "class": blockClasses,
          html: blockHTML
        });
        el = $("<" + blockTag + ">", blockAttrs);
        el.attr(blockAttrs);
        el = bindEvents(block, el, functions);
        el = bindData(block, el, data);
        ZenCode = ZenCode.substr(blocks[0].length);
        ZenObject.main = ZenCode;
      }
      if (ZenCode.length > 0) {
        if (ZenCode.charAt(0) === ">") {
          if (ZenCode.charAt(1) === "(") {
            zc = parseEnclosure(ZenCode.substr(1), "(", ")");
            ZenCode = ZenCode.substr(zc.length + 1);
          } else if (ZenCode.charAt(1) === "!") {
            obj = parseEnclosure(ZenCode.substr(1), "!");
            forScope = parseVariableScope(ZenCode.substr(1));
            zc = obj + forScope;
            ZenCode = ZenCode.substr(zc.length + 1);
          } else {
            len = Math.max(ZenCode.indexOf("+"), ZenCode.length);
            zc = ZenCode.substring(1, len);
            ZenCode = ZenCode.substr(len);
          }
          zo = ZenObject;
          zo.main = zc;
          els = $(createHTMLBlock($, zo, data, functions, indexes));
          els.appendTo(el);
        }
        if (ZenCode.charAt(0) === "+") {
          zo = ZenObject;
          zo.main = ZenCode.substr(1);
          el2 = createHTMLBlock($, zo, data, functions, indexes);
          $.each(el2, function(index, value) {
            return el.push(value);
          });
        }
      }
      ret = el;
      return ret;
    };
    bindData = function(ZenCode, el, data) {
      var datas, i, split;
      if (ZenCode.search(regDatas) === 0) {
        return el;
      }
      datas = ZenCode.match(regDatas);
      if (datas === null) {
        return el;
      }
      i = 0;
      while (i < datas.length) {
        split = regData.exec(datas[i]);
        if (split[3] === undefined) {
          $(el).data(split[1], data[split[1]]);
        } else {
          $(el).data(split[1], data[split[3]]);
        }
        i++;
      }
      return el;
    };
    bindEvents = function(ZenCode, el, functions) {
      var bindings, fn, i, split;
      if (ZenCode.search(regEvents) === 0) {
        return el;
      }
      bindings = ZenCode.match(regEvents);
      if (bindings === null) {
        return el;
      }
      i = 0;
      while (i < bindings.length) {
        split = regEvent.exec(bindings[i]);
        if (split[2] === undefined) {
          fn = functions[split[1]];
        } else {
          fn = functions[split[2]];
        }
        $(el).bind(split[1], fn);
        i++;
      }
      return el;
    };
    parseAttributes = function(ZenBlock, data) {
      var attrStrs, attrs, i, parts;
      if (ZenBlock.search(regAttrDfn) === -1) {
        return undefined;
      }
      attrStrs = ZenBlock.match(regAttrDfn);
      attrs = {};
      i = 0;
      while (i < attrStrs.length) {
        parts = regAttr.exec(attrStrs[i]);
        attrs[parts[1]] = "";
        if (parts[3] !== undefined) {
          attrs[parts[1]] = parseContents(parts[3], data);
        }
        i++;
      }
      return attrs;
    };
    parseClasses = function($, ZenBlock) {
      var classes, clsString, i;
      ZenBlock = ZenBlock.match(regTagNotContent)[0];
      if (ZenBlock.search(regClasses) === -1) {
        return undefined;
      }
      classes = ZenBlock.match(regClasses);
      clsString = "";
      i = 0;
      while (i < classes.length) {
        clsString += " " + regClass.exec(classes[i])[1];
        i++;
      }
      return $.trim(clsString);
    };
    parseContents = function(ZenBlock, data, indexes) {
      var html;
      if (indexes === undefined) {
        indexes = {};
      }
      html = ZenBlock;
      if (data === undefined) {
        return html;
      }
      while (regExclamation.test(html)) {
        html = html.replace(regExclamation, function(str, str2) {
          var begChar, fn, val;
          begChar = "";
          if (str.indexOf("!for:") > 0 || str.indexOf("!if:") > 0) {
            return str;
          }
          if (str.charAt(0) !== "!") {
            begChar = str.charAt(0);
            str = str.substring(2, str.length - 1);
          }
          fn = new Function("data", "indexes", "var r=undefined;" + "with(data){try{r=" + str + ";}catch(e){}}" + "with(indexes){try{if(r===undefined)r=" + str + ";}catch(e){}}" + "return r;");
          val = unescape(fn(data, indexes));
          return begChar + val;
        });
      }
      html = html.replace(/\\./g, function(str) {
        return str.charAt(1);
      });
      return unescape(html);
    };
    parseEnclosure = function(ZenCode, open, close, count) {
      var index, ret;
      if (close === undefined) {
        close = open;
      }
      index = 1;
      if (count === undefined) {
        count = (ZenCode.charAt(0) === open ? 1 : 0);
      }
      if (count === 0) {
        return;
      }
      while (count > 0 && index < ZenCode.length) {
        if (ZenCode.charAt(index) === close && ZenCode.charAt(index - 1) !== "\\") {
          count--;
        } else {
          if (ZenCode.charAt(index) === open && ZenCode.charAt(index - 1) !== "\\") {
            count++;
          }
        }
        index++;
      }
      ret = ZenCode.substring(0, index);
      return ret;
    };
    parseReferences = function(ZenCode, ZenObject) {
      ZenCode = ZenCode.replace(regReference, function(str) {
        var fn;
        str = str.substr(1);
        fn = new Function("objs", "var r=\"\";" + "with(objs){try{" + "r=" + str + ";" + "}catch(e){}}" + "return r;");
        return fn(ZenObject, parseReferences);
      });
      return ZenCode;
    };
    parseVariableScope = function(ZenCode) {
      var forCode, rest, tag;
      if (ZenCode.substring(0, 5) !== "!for:" && ZenCode.substring(0, 4) !== "!if:") {
        return undefined;
      }
      forCode = parseEnclosure(ZenCode, "!");
      ZenCode = ZenCode.substr(forCode.length);
      if (ZenCode.charAt(0) === "(") {
        return parseEnclosure(ZenCode, "(", ")");
      }
      tag = ZenCode.match(regZenTagDfn)[0];
      ZenCode = ZenCode.substr(tag.length);
      if (ZenCode.length === 0 || ZenCode.charAt(0) === "+") {
        return tag;
      } else if (ZenCode.charAt(0) === ">") {
        rest = "";
        rest = parseEnclosure(ZenCode.substr(1), "(", ")", 1);
        return tag + ">" + rest;
      }
      return undefined;
    };
    regZenTagDfn = /([#\.\@]?[\w-]+|\[([\w-!?=:"']+(="([^"]|\\")+")? {0,})+\]|\~[\w$]+=[\w$]+|&[\w$]+(=[\w$]+)?|[#\.\@]?!([^!]|\\!)+!){0,}(\{([^\}]|\\\})+\})?/i;
    regTag = /(\w+)/i;
    regId = /(?:^|\b)#([\w-!]+)/i;
    regTagNotContent = /((([#\.]?[\w-]+)?(\[([\w!]+(="([^"]|\\")+")? {0,})+\])?)+)/i;
    /*
     See lookahead syntax (?!) at https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp
    */

    regClasses = /(\.[\w-]+)(?!["\w])/g;
    regClass = /\.([\w-]+)/i;
    regReference = /(@[\w$_][\w$_\d]+)/i;
    regAttrDfn = /(\[([\w-!]+(="?([^"]|\\")+"?)? {0,})+\])/ig;
    regAttrs = /([\w-!]+(="([^"]|\\")+")?)/g;
    regAttr = /([\w-!]+)(="?((([\w]+(\[.*?\])+)|[^"\]]|\\")+)"?)?/i;
    regCBrace = /\{(([^\}]|\\\})+)\}/i;
    regExclamation = /(?:([^\\]|^))!([^!]|\\!)+!/g;
    regEvents = /\~[\w$]+(=[\w$]+)?/g;
    regEvent = /\~([\w$]+)=([\w$]+)/i;
    regDatas = /&[\w$]+(=[\w$]+)?/g;
    regData = /&([\w$]+)(=([\w$]+))?/i;
    return createHTMLBlock;
  })();

}).call(this);

/* jasmine-given - 2.6.3
 * Adds a Given-When-Then DSL to jasmine as an alternative style for specs
 * https://github.com/searls/jasmine-given
 */
/* jasmine-matcher-wrapper - 0.0.3
 * Wraps Jasmine 1.x matchers for use with Jasmine 2
 * https://github.com/testdouble/jasmine-matcher-wrapper
 */
(function() {
  var __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  (function(jasmine) {
    var comparatorFor, createMatcher;
    if (jasmine == null) {
      return typeof console !== "undefined" && console !== null ? console.warn("jasmine was not found. Skipping jasmine-matcher-wrapper. Verify your script load order.") : void 0;
    }
    if (jasmine.matcherWrapper != null) {
      return;
    }
    jasmine.matcherWrapper = {
      wrap: function(matchers) {
        var matcher, name, wrappedMatchers;
        if (jasmine.addMatchers == null) {
          return matchers;
        }
        wrappedMatchers = {};
        for (name in matchers) {
          if (!__hasProp.call(matchers, name)) continue;
          matcher = matchers[name];
          wrappedMatchers[name] = createMatcher(name, matcher);
        }
        return wrappedMatchers;
      }
    };
    createMatcher = function(name, matcher) {
      return function() {
        return {
          compare: comparatorFor(matcher, false),
          negativeCompare: comparatorFor(matcher, true)
        };
      };
    };
    return comparatorFor = function(matcher, isNot) {
      return function() {
        var actual, context, message, params, pass, _ref;
        actual = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        context = {
          actual: actual,
          isNot: isNot
        };
        pass = matcher.apply(context, params);
        if (isNot) {
          pass = !pass;
        }
        if (!pass) {
          message = (_ref = context.message) != null ? _ref.apply(context, params) : void 0;
        }
        return {
          pass: pass,
          message: message
        };
      };
    };
  })(jasmine || getJasmineRequireObj());

}).call(this);

(function() {
  var __slice = [].slice;

  (function(jasmine) {
    var Waterfall, additionalInsightsForErrorMessage, apparentReferenceError, attemptedEquality, cloneArray, comparisonInsight, currentSpec, declareJasmineSpec, deepEqualsNotice, doneWrapperFor, errorWithRemovedLines, evalInContextOfSpec, finalStatementFrom, getBlock, invariantList, mostRecentExpectations, mostRecentStacks, mostRecentlyUsed, o, root, stringifyExpectation, wasComparison, whenList, wrapAsExpectations;
    mostRecentlyUsed = null;
    root = (1, eval)('this');
    currentSpec = null;
    beforeEach(function() {
      return currentSpec = this;
    });
    root.Given = function() {
      mostRecentlyUsed = root.Given;
      return beforeEach(getBlock(arguments));
    };
    whenList = [];
    root.When = function() {
      var b;
      mostRecentlyUsed = root.When;
      b = getBlock(arguments);
      beforeEach(function() {
        return whenList.push(b);
      });
      return afterEach(function() {
        return whenList.pop();
      });
    };
    invariantList = [];
    root.Invariant = function() {
      var invariantBehavior;
      mostRecentlyUsed = root.Invariant;
      invariantBehavior = getBlock(arguments);
      beforeEach(function() {
        return invariantList.push(invariantBehavior);
      });
      return afterEach(function() {
        return invariantList.pop();
      });
    };
    getBlock = function(thing) {
      var assignResultTo, setupFunction;
      setupFunction = o(thing).firstThat(function(arg) {
        return o(arg).isFunction();
      });
      assignResultTo = o(thing).firstThat(function(arg) {
        return o(arg).isString();
      });
      return doneWrapperFor(setupFunction, function(done) {
        var context, result;
        context = currentSpec;
        result = setupFunction.call(context, done);
        if (assignResultTo) {
          if (!context[assignResultTo]) {
            return context[assignResultTo] = result;
          } else {
            throw new Error("Unfortunately, the variable '" + assignResultTo + "' is already assigned to: " + context[assignResultTo]);
          }
        }
      });
    };
    mostRecentExpectations = null;
    mostRecentStacks = null;
    declareJasmineSpec = function(specArgs, itFunction) {
      var expectationFunction, expectations, label, stacks;
      if (itFunction == null) {
        itFunction = it;
      }
      label = o(specArgs).firstThat(function(arg) {
        return o(arg).isString();
      });
      expectationFunction = o(specArgs).firstThat(function(arg) {
        return o(arg).isFunction();
      });
      mostRecentlyUsed = root.subsequentThen;
      mostRecentExpectations = expectations = [expectationFunction];
      mostRecentStacks = stacks = [errorWithRemovedLines("failed expectation", 3)];
      itFunction("then " + (label != null ? label : stringifyExpectation(expectations)), doneWrapperFor(expectationFunction, function(jasmineDone) {
        var userCommands;
        userCommands = [].concat(whenList, invariantList, wrapAsExpectations(expectations, stacks));
        return new Waterfall(userCommands, jasmineDone).flow();
      }));
      return {
        Then: subsequentThen,
        And: subsequentThen
      };
    };
    wrapAsExpectations = function(expectations, stacks) {
      var expectation, i, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = expectations.length; _i < _len; i = ++_i) {
        expectation = expectations[i];
        _results.push((function(expectation, i) {
          return doneWrapperFor(expectation, function(maybeDone) {
            return expect(expectation).not.toHaveReturnedFalseFromThen(currentSpec, i + 1, stacks[i], maybeDone);
          });
        })(expectation, i));
      }
      return _results;
    };
    doneWrapperFor = function(func, toWrap) {
      if (func.length === 0) {
        return function() {
          return toWrap();
        };
      } else {
        return function(done) {
          return toWrap(done);
        };
      }
    };
    root.Then = function() {
      return declareJasmineSpec(arguments);
    };
    root.Then.only = function() {
      return declareJasmineSpec(arguments, it.only);
    };
    root.subsequentThen = function(additionalExpectation) {
      mostRecentExpectations.push(additionalExpectation);
      mostRecentStacks.push(errorWithRemovedLines("failed expectation", 3));
      return this;
    };
    errorWithRemovedLines = function(msg, n) {
      var error, lines, stack, _ref;
      if (stack = new Error(msg).stack) {
        _ref = stack.split("\n"), error = _ref[0], lines = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
        return "" + error + "\n" + (lines.slice(n).join("\n"));
      }
    };
    mostRecentlyUsed = root.Given;
    root.And = function() {
      return mostRecentlyUsed.apply(this, jasmine.util.argsToArray(arguments));
    };
    o = function(thing) {
      return {
        isFunction: function() {
          return Object.prototype.toString.call(thing) === "[object Function]";
        },
        isString: function() {
          return Object.prototype.toString.call(thing) === "[object String]";
        },
        firstThat: function(test) {
          var i;
          i = 0;
          while (i < thing.length) {
            if (test(thing[i]) === true) {
              return thing[i];
            }
            i++;
          }
          return void 0;
        }
      };
    };
    Waterfall = (function() {
      function Waterfall(functions, finalCallback) {
        if (functions == null) {
          functions = [];
        }
        this.finalCallback = finalCallback != null ? finalCallback : function() {};
        this.functions = cloneArray(functions);
      }

      Waterfall.prototype.flow = function() {
        var func,
          _this = this;
        if (this.functions.length === 0) {
          return this.finalCallback();
        }
        func = this.functions.shift();
        if (func.length > 0) {
          return func(function() {
            return _this.flow();
          });
        } else {
          func();
          return this.flow();
        }
      };

      return Waterfall;

    })();
    cloneArray = function(a) {
      return a.slice(0);
    };
    jasmine._given = {
      matchers: {
        toHaveReturnedFalseFromThen: function(context, n, stackTrace, done) {
          var e, exception, result;
          result = false;
          exception = void 0;
          try {
            result = this.actual.call(context, done);
          } catch (_error) {
            e = _error;
            exception = e;
          }
          this.message = function() {
            var msg, stringyExpectation;
            stringyExpectation = stringifyExpectation(this.actual);
            msg = "Then clause" + (n > 1 ? " #" + n : "") + " `" + stringyExpectation + "` failed by ";
            if (exception) {
              msg += "throwing: " + exception.toString();
            } else {
              msg += "returning false";
            }
            msg += additionalInsightsForErrorMessage(stringyExpectation);
            if (stackTrace != null) {
              msg += "\n\n" + stackTrace;
            }
            return msg;
          };
          return result === false;
        }
      },
      __Waterfall__: Waterfall
    };
    stringifyExpectation = function(expectation) {
      var matches;
      matches = expectation.toString().replace(/\n/g, '').match(/function\s?\(.*\)\s?{\s*(return\s+)?(.*?)(;)?\s*}/i);
      if (matches && matches.length >= 3) {
        return matches[2].replace(/\s+/g, ' ');
      } else {
        return "";
      }
    };
    additionalInsightsForErrorMessage = function(expectationString) {
      var comparison, expectation;
      expectation = finalStatementFrom(expectationString);
      if (comparison = wasComparison(expectation)) {
        return comparisonInsight(expectation, comparison);
      } else {
        return "";
      }
    };
    finalStatementFrom = function(expectationString) {
      var multiStatement;
      if (multiStatement = expectationString.match(/.*return (.*)/)) {
        return multiStatement[multiStatement.length - 1];
      } else {
        return expectationString;
      }
    };
    wasComparison = function(expectation) {
      var comparator, comparison, left, right, s;
      if (comparison = expectation.match(/(.*) (===|!==|==|!=|>|>=|<|<=) (.*)/)) {
        s = comparison[0], left = comparison[1], comparator = comparison[2], right = comparison[3];
        return {
          left: left,
          comparator: comparator,
          right: right
        };
      }
    };
    comparisonInsight = function(expectation, comparison) {
      var left, msg, right;
      left = evalInContextOfSpec(comparison.left);
      right = evalInContextOfSpec(comparison.right);
      if (apparentReferenceError(left) && apparentReferenceError(right)) {
        return "";
      }
      msg = "\n\nThis comparison was detected:\n  " + expectation + "\n  " + left + " " + comparison.comparator + " " + right;
      if (attemptedEquality(left, right, comparison.comparator)) {
        msg += "\n\n" + (deepEqualsNotice(comparison.left, comparison.right));
      }
      return msg;
    };
    apparentReferenceError = function(result) {
      return /^<Error: "ReferenceError/.test(result);
    };
    evalInContextOfSpec = function(operand) {
      var e;
      try {
        return (function() {
          return eval(operand);
        }).call(currentSpec);
      } catch (_error) {
        e = _error;
        return "<Error: \"" + ((e != null ? typeof e.message === "function" ? e.message() : void 0 : void 0) || e) + "\">";
      }
    };
    attemptedEquality = function(left, right, comparator) {
      var _ref;
      if (!(comparator === "==" || comparator === "===")) {
        return false;
      }
      if (((_ref = jasmine.matchersUtil) != null ? _ref.equals : void 0) != null) {
        return jasmine.matchersUtil.equals(left, right);
      } else {
        return jasmine.getEnv().equals_(left, right);
      }
    };
    deepEqualsNotice = function(left, right) {
      return "However, these items are deeply equal! Try an expectation like this instead:\n  expect(" + left + ").toEqual(" + right + ")";
    };
    return beforeEach(function() {
      if (jasmine.addMatchers != null) {
        return jasmine.addMatchers(jasmine.matcherWrapper.wrap(jasmine._given.matchers));
      } else {
        return this.addMatchers(jasmine._given.matchers);
      }
    });
  })(jasmine);

}).call(this);

/* jasmine-only - 0.1.1
 * Exclusivity spec helpers for jasmine: `describe.only` and `it.only`
 * https://github.com/davemo/jasmine-only
 */
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function(jasmine) {
    var describeOnly, env, itOnly, root;
    root = (1, eval)('this');
    env = jasmine.getEnv();
    describeOnly = function(description, specDefinitions) {
      var suite;
      suite = new jasmine.Suite(this, description, null, this.currentSuite);
      suite.exclusive_ = 1;
      this.exclusive_ = Math.max(this.exclusive_, 1);
      return this.describe_(suite, specDefinitions);
    };
    itOnly = function(description, func) {
      var spec;
      spec = this.it(description, func);
      spec.exclusive_ = 2;
      this.exclusive_ = 2;
      return spec;
    };
    env.exclusive_ = 0;
    env.describe = function(description, specDefinitions) {
      var suite;
      suite = new jasmine.Suite(this, description, null, this.currentSuite);
      return this.describe_(suite, specDefinitions);
    };
    env.describe_ = function(suite, specDefinitions) {
      var declarationError, e, parentSuite;
      parentSuite = this.currentSuite;
      if (parentSuite) {
        parentSuite.add(suite);
      } else {
        this.currentRunner_.add(suite);
      }
      this.currentSuite = suite;
      declarationError = null;
      try {
        specDefinitions.call(suite);
      } catch (_error) {
        e = _error;
        declarationError = e;
      }
      if (declarationError) {
        this.it("encountered a declaration exception", function() {
          throw declarationError;
        });
      }
      this.currentSuite = parentSuite;
      return suite;
    };
    env.specFilter = function(spec) {
      return this.exclusive_ <= spec.exclusive_;
    };
    env.describe.only = function() {
      return describeOnly.apply(env, arguments);
    };
    env.it.only = function() {
      return itOnly.apply(env, arguments);
    };
    root.describe.only = function(description, specDefinitions) {
      return env.describe.only(description, specDefinitions);
    };
    root.it.only = function(description, func) {
      return env.it.only(description, func);
    };
    root.iit = root.it.only;
    root.ddescribe = root.describe.only;
    jasmine.Spec = (function(_super) {
      __extends(Spec, _super);

      function Spec(env, suite, description) {
        this.exclusive_ = suite.exclusive_;
        Spec.__super__.constructor.call(this, env, suite, description);
      }

      return Spec;

    })(jasmine.Spec);
    return jasmine.Suite = (function(_super) {
      __extends(Suite, _super);

      function Suite(env, suite, specDefinitions, parentSuite) {
        this.exclusive_ = parentSuite && parentSuite.exclusive_ || 0;
        Suite.__super__.constructor.call(this, env, suite, specDefinitions, parentSuite);
      }

      return Suite;

    })(jasmine.Suite);
  })(jasmine);

}).call(this);

/* jasmine-stealth - 0.0.17
 * Makes Jasmine spies a bit more robust
 * https://github.com/searls/jasmine-stealth
 */
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function() {
    var Captor, fake, root, stubChainer, unfakes, whatToDoWhenTheSpyGetsCalled, _;
    root = (1, eval)('this');
    _ = function(obj) {
      return {
        each: function(iterator) {
          var item, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = obj.length; _i < _len; _i++) {
            item = obj[_i];
            _results.push(iterator(item));
          }
          return _results;
        },
        isFunction: function() {
          return Object.prototype.toString.call(obj) === "[object Function]";
        },
        isString: function() {
          return Object.prototype.toString.call(obj) === "[object String]";
        }
      };
    };
    root.spyOnConstructor = function(owner, classToFake, methodsToSpy) {
      var fakeClass, spies;
      if (methodsToSpy == null) {
        methodsToSpy = [];
      }
      if (_(methodsToSpy).isString()) {
        methodsToSpy = [methodsToSpy];
      }
      spies = {
        constructor: jasmine.createSpy("" + classToFake + "'s constructor")
      };
      fakeClass = (function() {
        function _Class() {
          spies.constructor.apply(this, arguments);
        }

        return _Class;

      })();
      _(methodsToSpy).each(function(methodName) {
        spies[methodName] = jasmine.createSpy("" + classToFake + "#" + methodName);
        return fakeClass.prototype[methodName] = function() {
          return spies[methodName].apply(this, arguments);
        };
      });
      fake(owner, classToFake, fakeClass);
      return spies;
    };
    unfakes = [];
    afterEach(function() {
      _(unfakes).each(function(u) {
        return u();
      });
      return unfakes = [];
    });
    fake = function(owner, thingToFake, newThing) {
      var originalThing;
      originalThing = owner[thingToFake];
      owner[thingToFake] = newThing;
      return unfakes.push(function() {
        return owner[thingToFake] = originalThing;
      });
    };
    root.stubFor = root.spyOn;
    jasmine.createStub = jasmine.createSpy;
    jasmine.createStubObj = function(baseName, stubbings) {
      var name, obj, stubbing;
      if (stubbings.constructor === Array) {
        return jasmine.createSpyObj(baseName, stubbings);
      } else {
        obj = {};
        for (name in stubbings) {
          stubbing = stubbings[name];
          obj[name] = jasmine.createSpy(baseName + "." + name);
          if (_(stubbing).isFunction()) {
            obj[name].andCallFake(stubbing);
          } else {
            obj[name].andReturn(stubbing);
          }
        }
        return obj;
      }
    };
    whatToDoWhenTheSpyGetsCalled = function(spy) {
      var matchesStub, priorPlan;
      matchesStub = function(stubbing, args, context) {
        switch (stubbing.type) {
          case "args":
            return jasmine.getEnv().equals_(stubbing.ifThis, jasmine.util.argsToArray(args));
          case "context":
            return jasmine.getEnv().equals_(stubbing.ifThis, context);
        }
      };
      priorPlan = spy.plan;
      return spy.andCallFake(function() {
        var i, stubbing;
        i = 0;
        while (i < spy._stealth_stubbings.length) {
          stubbing = spy._stealth_stubbings[i];
          if (matchesStub(stubbing, arguments, this)) {
            if (stubbing.satisfaction === "callFake") {
              return stubbing.thenThat.apply(stubbing, arguments);
            } else {
              return stubbing.thenThat;
            }
          }
          i++;
        }
        return priorPlan.apply(spy, arguments);
      });
    };
    jasmine.Spy.prototype.whenContext = function(context) {
      var spy;
      spy = this;
      spy._stealth_stubbings || (spy._stealth_stubbings = []);
      whatToDoWhenTheSpyGetsCalled(spy);
      return stubChainer(spy, "context", context);
    };
    jasmine.Spy.prototype.when = function() {
      var ifThis, spy;
      spy = this;
      ifThis = jasmine.util.argsToArray(arguments);
      spy._stealth_stubbings || (spy._stealth_stubbings = []);
      whatToDoWhenTheSpyGetsCalled(spy);
      return stubChainer(spy, "args", ifThis);
    };
    stubChainer = function(spy, type, ifThis) {
      var addStubbing;
      addStubbing = function(satisfaction) {
        return function(thenThat) {
          spy._stealth_stubbings.unshift({
            type: type,
            ifThis: ifThis,
            satisfaction: satisfaction,
            thenThat: thenThat
          });
          return spy;
        };
      };
      return {
        thenReturn: addStubbing("return"),
        thenCallFake: addStubbing("callFake")
      };
    };
    jasmine.Spy.prototype.mostRecentCallThat = function(callThat, context) {
      var i;
      i = this.calls.length - 1;
      while (i >= 0) {
        if (callThat.call(context || this, this.calls[i]) === true) {
          return this.calls[i];
        }
        i--;
      }
    };
    jasmine.Matchers.ArgThat = (function(_super) {
      __extends(ArgThat, _super);

      function ArgThat(matcher) {
        this.matcher = matcher;
      }

      ArgThat.prototype.jasmineMatches = function(actual) {
        return this.matcher(actual);
      };

      return ArgThat;

    })(jasmine.Matchers.Any);
    jasmine.Matchers.ArgThat.prototype.matches = jasmine.Matchers.ArgThat.prototype.jasmineMatches;
    jasmine.argThat = function(expected) {
      return new jasmine.Matchers.ArgThat(expected);
    };
    jasmine.Matchers.Capture = (function(_super) {
      __extends(Capture, _super);

      function Capture(captor) {
        this.captor = captor;
      }

      Capture.prototype.jasmineMatches = function(actual) {
        this.captor.value = actual;
        return true;
      };

      return Capture;

    })(jasmine.Matchers.Any);
    jasmine.Matchers.Capture.prototype.matches = jasmine.Matchers.Capture.prototype.jasmineMatches;
    Captor = (function() {
      function Captor() {}

      Captor.prototype.capture = function() {
        return new jasmine.Matchers.Capture(this);
      };

      return Captor;

    })();
    return jasmine.captor = function() {
      return new Captor();
    };
  })();

}).call(this);

describe(".helloText", function(){
  When(function(){ this.result = helloText(); });
  Then(function(){ expect(this.result).toEqual("Hello, World!"); });
});

//# sourceMappingURL=spec.js.map