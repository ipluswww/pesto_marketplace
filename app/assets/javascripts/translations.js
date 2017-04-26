window.ST = window.ST || {};

/**
  Use translations in JavaScript
*/
(function(exports) {

  var store = {};

  exports.t = function(key, opts) {
    if(store[key] == null) {
      throw new Error("No translation loaded: " + key);
    }

    return _.template(store[key], opts || {});
  };

  exports.loadTranslations = function(translations) {
    _.extend(store, translations);
  };

})(window.ST);
