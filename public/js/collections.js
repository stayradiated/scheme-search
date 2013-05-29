
App.Collections.Colors = Backbone.Collection.extend({

  model: App.Models.Color,

  enabled: function() {
    return this.filter(function(model) {
      return model.get('enabled');
    });
  }

});
