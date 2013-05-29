
App.Models.Color = Backbone.Model.extend({

  defaults: {
    color: '#000000',
    enabled: true
  },

  toggle: function () {
    this.set('enabled', !this.get('enabled'));
  },

  toJSON: function() {
    return this.get('color');
  }

});
